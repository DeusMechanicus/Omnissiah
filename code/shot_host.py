#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram


select_shot_host_options_sql = 'SELECT id, optionid, hostuuid, idtype, ip, mac, weight, manufacturerid, devicetypeid, name, hostname, \
controllerid, idoncontroller, ipprefixid, vlan, roleid, ispublic, macvendorid FROM shot_host_option ORDER BY optionid;'
insert_tmp_shot_hosts = 'INSERT INTO tmp_shot_host (hostid, hostuuid, idtype, ip, mac, name, hostname, manufacturerid, devicetypeid, controllerid, \
idoncontroller, ipprefixid, vlan, roleid, ispublic, macvendorid, selectedid) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);'
insert_tmp_shot_host_options_map_sql = 'INSERT INTO tmp_shot_host_option_map (hostid, host_option_id) VALUES (%s, %s);'


def group_host_options(host_options, group_keys):
    host_groups = {}
    for group_key in group_keys:
        host_groups[group_key] = {}
    for id, host_option in host_options.items():
        for group_key in group_keys:
            value = host_option[group_key]
            if value is not None:
                if value not in host_groups[group_key]:
                    host_groups[group_key][value] = set()
                host_groups[group_key][value].add(id)
    return host_groups

def load_host_options(db, log):
    cur = db.cursor()
    cur.execute(select_shot_host_options_sql)
    host_options = {r[0]:{'id':r[0], 'optionid':r[1], 'hostuuid':r[2], 'idtype':r[3], 'ip':r[4], 'mac':r[5], 'weight':r[6],
        'manufacturerid':r[7], 'devicetypeid':r[8], 'name':r[9], 'hostname':r[10], 'controllerid':r[11], 'idoncontroller':r[12],
        'ipprefixid':r[13], 'vlan':r[14], 'roleid':r[15], 'ispublic':r[16], 'macvendorid':r[17]} for r in cur.fetchall()}
    cur.close()
    for id, ho in host_options.items():
        ho['idtype_hostuuid'] = str(ho['idtype']) + '/' + ho['hostuuid']
        if ho['ip'] is None or ho['mac'] is None:
            ho['ipmac'] = None
        else:
            ho['ipmac'] = ho['ip'] + '/' + ho['mac']
    host_groups = group_host_options(host_options, ['idtype_hostuuid', 'ipmac'])
    return host_options, host_groups

def find_best_option(host_options, ids):
    max_weight = 0
    max_id = None
    for id in ids:
        if host_options[id]['weight']>max_weight:
            max_weight = host_options[id]['weight']
            max_id = id
    return max_id

def process_host_options(host_options, host_groups):
    idsets = {}
    for group_key, host_group in host_groups.items():
        for id, ids in host_group.items():
            for hoid in ids:
                if hoid not in idsets:
                    idsets[hoid] = {hoid}
                idsets[hoid] = idsets[hoid] | ids
    intersection = True
    while intersection:
        intersection = False
        for id, ids in idsets.items():
            for hoid in ids:
                newids = ids | idsets[hoid]
                if ids!=newids:
                    ids = ids | idsets[hoid]
                    intersection = True
    shosts = {str(sorted(ids, key=int)):ids for id, ids in idsets.items()}
    hosts = {}
    i = 1
    for sids, ids in shosts.items():
        id = find_best_option(host_options, ids)
        hosts[i] = host_options[id].copy()
        hosts[i]['ids'] = ids
        hosts[i]['selectedid'] = id
        hosts[i]['strids'] = sids
        i += 1
    return hosts

def save_hosts(db, hosts, log):
    cur = db.cursor()
    hlist = []
    holist = []
    for id, host in hosts.items():
        hlist.append((id, host['hostuuid'], host['idtype'], host['ip'], host['mac'], host['name'], host['hostname'], host['manufacturerid'], host['devicetypeid'], 
            host['controllerid'], host['idoncontroller'], host['ipprefixid'], host['vlan'], host['roleid'], host['ispublic'], host['macvendorid'], host['selectedid']))
        for hoid in host['ids']:
            holist.append((id, hoid))
    if hlist:
        cur.executemany(insert_tmp_shot_hosts, hlist)
        db.commit
    if holist:
        cur.executemany(insert_tmp_shot_host_options_map_sql, holist)
        db.commit
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_shot_user, omni_unpwd.db_shot_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=[1, 2])
        host_options, host_groups = load_host_options(omnidb, program.log)
        hosts = process_host_options(host_options, host_groups)
        save_hosts(omnidb, hosts, program.log)
        omnidb.run_program_queries(stage=list(range(3, 10)))
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())