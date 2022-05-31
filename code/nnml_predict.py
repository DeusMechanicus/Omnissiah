#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import os
import torch
from torch.autograd import Variable
import numpy as np

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.msg import msg_model_file_notfound
from omnissiah.nnml import Manufacturers_NNet, Devicetypes_NNet


select_nnml_model_sql = "SELECT nnml_model.modelid, nnml_model.modeltypeid, nnml_model.model_filename, nnml_model.created FROM nnml_model \
INNER JOIN ref_nnml_modeltype ON nnml_model.modeltypeid=ref_nnml_modeltype.modeltypeid \
WHERE ref_nnml_modeltype.modeltype='{0}' ORDER BY nnml_model.created DESC;"
select_size_sql = 'SELECT COUNT(*) AS inout_size FROM nnml_model INNER JOIN {0} ON nnml_model.modelid={0}.modelid WHERE nnml_model.modelid={1};'
nnml_model_input_map = 'nnml_model_input_map'
nnml_model_manufacturer_map = 'nnml_model_manufacturer_map'
nnml_model_devicetype_map = 'nnml_model_devicetype_map'
select_nnml_ip_inputs = 'SELECT nnml_ip.ipid, nnml_model_input_map.inputnum, nnml_ip_input.value FROM nnml_ip \
INNER JOIN nnml_ip_input ON nnml_ip.ipid=nnml_ip_input.ipid \
INNER JOIN nnml_input ON nnml_ip_input.inputid=nnml_input.inputid \
INNER JOIN nnml_model_input_map ON nnml_model_input_map.modelid={0} AND nnml_input.input_typeid=nnml_model_input_map.input_typeid AND nnml_input.typeid=nnml_model_input_map.typeid;'
select_manufacturers_sql = 'SELECT outputnum, manufacturerid FROM nnml_model_manufacturer_map WHERE modelid={0};'
select_devicetypes_sql = 'SELECT outputnum, devicetypeid FROM nnml_model_devicetype_map WHERE modelid={0};'
update_tmp_nnml_ip_sql = 'UPDATE tmp_nnml_ip SET manufacturerid={0}, devicetypeid={1}, manufacturerid_value={2}, devicetypeid_value={3} WHERE ipid={4};'


def find_model(db, modeltype, log):
    cur = db.cursor()
    cur.execute(select_nnml_model_sql.format(modeltype))
    modelid = None
    for r in cur.fetchall():
        filename = r[2]
        if os.path.exists(r[2]):
            modelid = r[0]
            filename = r[2]
            break
    if modelid is None:
        log.error(msg_model_file_notfound)
        return None, None, None, None
    cur.execute(select_size_sql.format(nnml_model_input_map, str(modelid)))
    input_size = cur.fetchall()[0][0]
    if modeltype==omni_config.nnml_model_manufacturer:
        cur.execute(select_size_sql.format(nnml_model_manufacturer_map, str(modelid)))
        output_size = cur.fetchall()[0][0]
    elif modeltype==omni_config.nnml_model_devicetype:
        cur.execute(select_size_sql.format(nnml_model_devicetype_map, str(modelid)))
        output_size = cur.fetchall()[0][0]
    cur.close()
    return modelid, filename, input_size, output_size

def load_map(db, sql, modelid, log):
    cur = db.cursor()
    cur.execute(sql.format(str(modelid)))
    dbmap = {r[0]:r[1] for r in cur.fetchall()}
    cur.close()
    return dbmap

def load_data(db, modelid, input_size, log):
    ipid_map = {'id':{}, 'num':{}}
    cur = db.cursor()
    cur.execute(select_nnml_ip_inputs.format(str(modelid)))
    records = {}
    i = 0
    for r in cur.fetchall():
        if r[0] not in records:
            ipid_map['id'][r[0]] = i
            ipid_map['num'][i] = r[0]
            i += 1
            records[r[0]] = {}
        records[r[0]][r[1]] = r[2]
    cur.close()
    data = np.zeros((len(ipid_map['num']), input_size), dtype=float)
    for ipid, record in records.items():
        num = ipid_map['id'][ipid]
        for inputnum, value in record.items():
            data[num][inputnum] = value
    del records
    return data, ipid_map

def save_results(db, res_man, manufacturers, res_dt, devicetypes, ipid_map, log):
    records = {}
    result_manufacturers = res_man.detach().numpy()
    result_devicetypes = res_dt.detach().numpy()
    cur = db.cursor()
    for i in range(0, result_manufacturers.shape[0]):
        ipid = ipid_map['num'][i]
        num = np.argmax(result_manufacturers[i])
        records[ipid] = {'manufacturerid':manufacturers[num], 'manufacturerid_value':result_manufacturers[i][num]}
    for i in range(0, result_devicetypes.shape[0]):
        ipid = ipid_map['num'][i]
        num = np.argmax(result_devicetypes[i])
        if ipid in records:
            records[ipid]['devicetypeid'] = devicetypes[num]
            records[ipid]['devicetypeid_value'] = result_devicetypes[i][num]
        else:
            records[ipid] = {'devicetypeid':devicetypes[num], 'devicetypeid_value':result_devicetypes[i][num]}
    for ipid, rvalue in records.items():
        if 'manufacturerid' not in rvalue:
            rvalue['manufacturerid'] = None
        if 'devicetypeid' not in rvalue:
            rvalue['devicetypeid'] = None
        if 'manufacturerid_value' not in rvalue:
            rvalue['manufacturerid_value'] = None
        if 'devicetypeid_value' not in rvalue:
            rvalue['devicetypeid_value'] = None
    for ipid, rvalue in records.items():
        if rvalue['manufacturerid'] is not None or rvalue['devicetypeid'] is not None:
            manufacturerid = 'NULL' if rvalue['manufacturerid'] is None else str(rvalue['manufacturerid'])
            devicetypeid = 'NULL' if rvalue['devicetypeid'] is None else str(rvalue['devicetypeid'])
            manufacturerid_value = 'NULL' if rvalue['manufacturerid_value'] is None else str(rvalue['manufacturerid_value'])
            devicetypeid_value = 'NULL' if rvalue['devicetypeid_value'] is None else str(rvalue['devicetypeid_value'])
            cur.execute(update_tmp_nnml_ip_sql.format(manufacturerid, devicetypeid, manufacturerid_value, devicetypeid_value, str(ipid)))
            db.commit
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_nnml_user, omni_unpwd.db_nnml_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=[1,2])
        modelid_manufacturers, filename, input_size, output_size = find_model(omnidb, omni_config.nnml_model_manufacturer, program.log)
        if filename is None:
            omnidb.close()
            return 0
        model_manufacturers = Manufacturers_NNet(input_size, output_size)
        model_manufacturers.load_state_dict(torch.load(filename))
        model_manufacturers.eval()
        modelid_devicetypes, filename, input_size, output_size= find_model(omnidb, omni_config.nnml_model_devicetype, program.log)
        if filename is None:
            omnidb.close()
            return 0
        model_devicetypes = Devicetypes_NNet(input_size, output_size)
        model_devicetypes.load_state_dict(torch.load(filename))
        model_devicetypes.eval()
        manufacturers = load_map(omnidb, select_manufacturers_sql, modelid_manufacturers, program.log)
        devicetypes = load_map(omnidb, select_devicetypes_sql, modelid_devicetypes, program.log)
        data, ipid_map = load_data(omnidb, modelid_manufacturers, model_manufacturers.input_size, program.log)
        data = Variable(torch.from_numpy(data).float())
        result_manufacturers = model_manufacturers.forward(data)
        del data
        data, ipid_map = load_data(omnidb, modelid_devicetypes, model_devicetypes.input_size, program.log)
        data = Variable(torch.from_numpy(data).float())
        result_devicetypes = model_devicetypes.forward(data)
        save_results(omnidb, result_manufacturers, manufacturers, result_devicetypes, devicetypes, ipid_map, program.log)
        omnidb.run_program_queries(stage=[3,4])
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())