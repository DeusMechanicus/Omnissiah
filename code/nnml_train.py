#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import os
import torch
from torch.autograd import Variable
import numpy as np
from datetime import datetime

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.nnml import Manufacturers_NNet, Devicetypes_NNet


select_inputs_sql = "SELECT inputid, input_typeid, typeid FROM nnml_train_input ORDER BY input_typeid, typeid;"
select_manufacturers_sql = "SELECT DISTINCT ref_manufacturer.manufacturerid FROM ref_manufacturer \
INNER JOIN nnml_train_ip ON ref_manufacturer.manufacturerid=nnml_train_ip.manufacturerid \
ORDER BY ref_manufacturer.manufacturerid;"
select_devicetypes_sql = "SELECT DISTINCT ref_devicetype.devicetypeid FROM ref_devicetype \
INNER JOIN nnml_train_ip ON ref_devicetype.devicetypeid=nnml_train_ip.devicetypeid;"
select_parent_devicetypes_sql = 'SELECT DISTINCT parentid FROM ref_devicetype WHERE parentid IS NOT NULL AND parentid<>0 AND devicetypeid in ({0});'
select_devicetype_parent_sql = 'SELECT devicetypeid, parentid FROM ref_devicetype WHERE parentid IS NOT NULL AND parentid<>0 AND devicetypeid in ({0});'
max_parent_iterations = 10
select_manufacturers_data_sql = 'SELECT nnml_train_ip.ipid, nnml_train_ip_input.inputid, nnml_train_ip_input.value, nnml_train_ip.manufacturerid \
FROM nnml_train_ip_input INNER JOIN nnml_train_ip ON nnml_train_ip_input.ipid=nnml_train_ip.ipid \
WHERE nnml_train_ip.manufacturerid IS NOT NULL ORDER BY nnml_train_ip.ipid;'
select_devicetypes_data_sql = 'SELECT nnml_train_ip.ipid, nnml_train_ip_input.inputid, nnml_train_ip_input.value, nnml_train_ip.devicetypeid \
FROM nnml_train_ip_input INNER JOIN nnml_train_ip ON nnml_train_ip_input.ipid=nnml_train_ip.ipid \
WHERE nnml_train_ip.devicetypeid IS NOT NULL ORDER BY nnml_train_ip.ipid;'
select_modeltypeid_sql = "SELECT modeltypeid FROM ref_nnml_modeltype WHERE modeltype='{0}';"
insert_nnml_model_sql = 'INSERT INTO nnml_model (modeltypeid, model_filename) VALUES (%s, %s) RETURNING modelid;'
insert_manufacturer_map_sql = 'INSERT INTO nnml_model_manufacturer_map (modelid, outputnum, manufacturerid) VALUES (%s, %s, %s);'
insert_devicetype_map_sql = 'INSERT INTO nnml_model_devicetype_map (modelid, outputnum, devicetypeid) VALUES (%s, %s, %s);'
insert_input_map_sql = 'INSERT INTO nnml_model_input_map (modelid, inputnum, input_typeid, typeid) VALUES (%s, %s, %s, %s);'
select_max_nnml_model_records_sql = "SELECT value FROM cfg_parameter WHERE parameter='max_nnml_model_records' AND tablename='';"
truncate_tmp_intid_sql = 'TRUNCATE TABLE tmp_intid;'
select_modeltypeids_sql = 'SELECT modeltypeid FROM ref_nnml_modeltype;'
insert_modelids_sql = 'INSERT INTO tmp_intid (id) SELECT modelid FROM nnml_model WHERE modeltypeid={0} ORDER BY created DESC LIMIT {1};'
select_files_to_delete_sql = 'SELECT DISTINCT model_filename FROM nnml_model WHERE NOT EXISTS (SELECT NULL FROM tmp_intid WHERE tmp_intid.id=nnml_model.modelid);'


def load_inputs (db, log):
    inputs = {'inputid':{0:{'id':0, 'num':0, 'input_typeid':0, 'typeid':0}}, 
        'inputnum':{0:{'id':0, 'num':0, 'input_typeid':0, 'typeid':0}}}
    cur = db.cursor()
    cur.execute(select_inputs_sql)
    i = 1
    for r in cur.fetchall():
        v = {'id':r[0], 'num':i, 'input_typeid':r[1], 'typeid':r[2]}
        inputs['inputid'][r[0]] = v
        inputs['inputnum'][i] = v
        i += 1
    cur.close()
    return inputs

def load_manufacturers (db, log):
    manufacturers = {'id':{0:0}, 'num':{0:0}}
    cur = db.cursor()
    cur.execute(select_manufacturers_sql)
    i = 1
    for r in cur.fetchall():
        if r[0]:
            manufacturers['id'][r[0]] = i
            manufacturers['num'][i] = r[0]
            i += 1
    cur.close()
    return manufacturers

def load_devicetypes(db, log):
    devicetypes = {'id':{0:0}, 'num':{0:0}, 'parents':{}}
    cur = db.cursor()
    cur.execute(select_devicetypes_sql)
    dtset = set([r[0] for r in cur.fetchall()])
    newidsset = dtset
    for i in range(0, max_parent_iterations):
         cur.execute(select_parent_devicetypes_sql.format(','.join([str(s) for s in newidsset])))
         newidsset = set([r[0] for r in cur.fetchall()]) - dtset
         if not newidsset:
             break
         dtset = dtset | newidsset
    dtset = set(sorted(dtset))
    i = 1
    for devicetypeid in dtset:
        if devicetypeid:
            devicetypes['id'][devicetypeid] = i
            devicetypes['num'][i] = devicetypeid
            i += 1
    cur.execute(select_devicetype_parent_sql.format(','.join([str(s) for s in dtset])))
    for r in cur.fetchall():
        devicetypes['parents'][r[0]] = {'id':r[1], 'set':set([r[1]])}
    cur.close()
    for i in range(0, max_parent_iterations):
        for devicetypeid, vparent in devicetypes['parents'].items():
            if vparent['id'] in devicetypes['parents']:
                vparent['set'] = vparent['set'] | devicetypes['parents'][vparent['id']]['set']
    return devicetypes

def load_data(db, sql, inputs, outputs, log):
    cur = db.cursor()
    cur.execute(sql)
    records = {}
    for r in cur.fetchall():
        if r[0] not in records:
            records[r[0]] = {'labelid':r[3], 'inputs':{}}
        records[r[0]]['inputs'][r[1]] = r[2]
    cur.close()
    data = np.zeros((len(records), len(inputs['inputid'])), dtype=float)
    labels = np.zeros((len(records), len(outputs['id'])), dtype=float)
    i = 0
    for ipid, record in records.items():
        id = record['labelid']
        numid = outputs['id'][id]
        labels[i][numid] = 1.0
#        if 'parents' in outputs:
#            if id in outputs['parents']:
#                for parentid in outputs['parents'][id]['set']:
#                    numid = outputs['id'][parentid]
#                    labels[i][numid] = 1.0
        for inputid, value in record['inputs'].items():
            id = inputs['inputid'][inputid]['num']
            data[i][id] = value
        i += 1
    del records
    return data, labels

def save_model(db, output_sql, model, inputs, outputs, log):
    if isinstance(model, Manufacturers_NNet):
        modeltype = omni_config.nnml_model_manufacturer
        filename = 'manufacturer'
    elif isinstance(model, Devicetypes_NNet):
        modeltype = omni_config.nnml_model_devicetype
        filename = 'devicetype'
    else:
        return
    filename = omni_config.nnml_model_filename.format(omni_config.nnml_models_path, filename, datetime.now().strftime('%Y%m%d%H%M%S'))
    torch.save(model.state_dict(), filename)
    cur = db.cursor()
    cur.execute(select_modeltypeid_sql.format(modeltype))
    modeltypeid = cur.fetchall()[0][0]
    cur.close()
    cur = db.cursor()
    cur.execute(insert_nnml_model_sql, (modeltypeid, filename))
    modelid = cur.fetchall()[0][0]
    vallist = []
    for onum, ovalue in outputs['num'].items():
        vallist.append((modelid, onum, ovalue))
    if vallist:
        cur.executemany(output_sql, vallist)
        db.commit()
    vallist = []
    for inum, ivalue in inputs['inputnum'].items():
        vallist.append((modelid, inum, ivalue['input_typeid'], ivalue['typeid']))
    if vallist:
        cur.executemany(insert_input_map_sql, vallist)
        db.commit()
    cur.close()

def prepare_model_tables(db, log):
    cur = db.cursor()
    cur.execute(truncate_tmp_intid_sql)
    db.commit()
    cur.execute(select_max_nnml_model_records_sql)
    max_nnml_model_records = int(cur.fetchall()[0][0])
    cur.execute(select_modeltypeids_sql)
    modeltypeids = [r[0] for r in cur.fetchall()]
    for id in modeltypeids:
        sql = insert_modelids_sql.format(str(id), str(max_nnml_model_records))
        cur.execute(sql)
        db.commit()
    cur.execute(select_files_to_delete_sql)
    files_to_delete = set([r[0] for r in cur.fetchall()])
    cur.close()
    return files_to_delete

def delete_model_files(files_to_delete, log):
    model_path = os.path.join(omni_config.nnml_models_path, '')
    for fn in files_to_delete:
        path = os.path.join(os.path.dirname(fn), '')
        if path==model_path:
            try:
                os.remove(fn)
            except:
                log.exception('Fatal error')


def main():
#    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_nnml_user, omni_unpwd.db_nnml_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        inputs = load_inputs(omnidb, program.log)
        manufacturers = load_manufacturers(omnidb, program.log)
        devicetypes = load_devicetypes(omnidb, program.log)
        data, labels = load_data(omnidb, select_manufacturers_data_sql, inputs, manufacturers, program.log)
        omnidb.close()
        data = Variable(torch.from_numpy(data).float())
        labels = Variable(torch.from_numpy(labels).float())
        model_manufacturers = Manufacturers_NNet(data.shape[1], labels.shape[1])
        model_manufacturers.train_model(data, labels)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_nnml_user, omni_unpwd.db_nnml_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_model(omnidb, insert_manufacturer_map_sql, model_manufacturers, inputs, manufacturers, program.log)
        del data
        del labels
        data, labels = load_data(omnidb, select_devicetypes_data_sql, inputs, devicetypes, program.log)
        omnidb.close()
        data = Variable(torch.from_numpy(data).float())
        labels = Variable(torch.from_numpy(labels).float())
        model_devicetypes = Devicetypes_NNet(data.shape[1], labels.shape[1])
        model_devicetypes.train_model(data, labels)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_nnml_user, omni_unpwd.db_nnml_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_model(omnidb, insert_devicetype_map_sql, model_devicetypes, inputs, devicetypes, program.log)
        omnidb.run_program_queries(stage=1)
        files_to_delete = prepare_model_tables(omnidb, program.log)
        omnidb.run_program_queries(stage=2)
        delete_model_files(files_to_delete, program.log)
        omnidb.close()
        exitcode = 0
#    except:
#        program.log.exception('Fatal error')
#    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())