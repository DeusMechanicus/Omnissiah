#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram


select_host_sql = 'SELECT hostid, hostuuid, idtype, ip, mac, manufacturerid, devicetypeid FROM {0} ORDER BY hostid;'
update_main_host_pk_sql = 'UPDATE main_host SET hostuuid={0}, idtype={1} WHERE hostid={3};'
delete_main_host_sql = 'DELETE FROM main_host WHERE hostid IN ({0});'


def group_hosts(hosts, group_keys):
    host_groups = {}
    for group_key in group_keys:
        host_groups[group_key] = {}
    for id, host in hosts.items():
        for group_key in group_keys:
            value = host[group_key]
            if value is not None:
                if value not in host_groups[group_key]:
                    host_groups[group_key][value] = set()
                host_groups[group_key][value].add(id)
    return host_groups

def load_hosts(db, table, log):
    cur = db.cursor()
    cur.execute(select_host_sql.format(table))
    hosts = {r[0]:{'hostid':r[0], 'hostuuid':r[1], 'idtype':r[2], 'ip':r[3], 'mac':r[4], 'manufacturerid':r[5],
        'devicetypeid':r[6]} for r in cur.fetchall()}
    cur.close()
    for hostid, host in hosts.items():
        host['idtype_hostuuid'] = str(host['idtype']) + '/' + host['hostuuid']
        if host['ip'] is None or host['mac'] is None:
            host['ipmac'] = None
        else:
            host['ipmac'] = host['ip'] + '/' + host['mac']
    host_groups = group_hosts(hosts, ['idtype_hostuuid', 'ipmac'])
    return hosts, host_groups

def process_hosts(db, shot_hosts, main_hosts, shot_host_groups, main_host_groups):
    host_relations = {'shot':{}, 'main':{}}
    for shotid, shot_host in shot_hosts.items():
        for group_key in shot_host_groups:
            key = shot_host[group_key]
            if key is not None:
                if key in main_host_groups[group_key]:
                    if shotid not in host_relations['shot']:
                        host_relations['shot'][shotid] = set()
                    host_relations['shot'][shotid] = host_relations['shot'][shotid] | main_host_groups[group_key][key]
                    for mainid in main_host_groups[group_key][key]:
                        if mainid not in  host_relations['main']:
                            host_relations['main'][mainid] = set()
                        host_relations['main'][mainid].add(shotid)
    shot_relations = {}
    for shotid, relation in host_relations['shot'].items():
        if len(relation)==1:
            mainid = next(iter(relation))
            if shot_hosts[shotid]['hostuuid']!=main_hosts[mainid]['hostuuid'] or \
               shot_hosts[shotid]['idtype']!=main_hosts[mainid]['idtype']:
                shot_relations[shotid] = relation
        else:
            shot_relations[shotid] = relation
    cur = db.cursor()
    for shotid, relation in shot_relations.items():
        ids = list(relation)
        mainid = ids[0]
        ids = ids[1:]
        if len(relation)==1:
            try:
                cur.execute(update_main_host_pk_sql.format(shot_hosts[shotid]['hostuuid'], str(shot_hosts[shotid]['idtype']), str(mainid)))
                db.commit()
            except:
                pass
        else:
            try:
                ids = str(ids)[1:-1]
                cur.execute(delete_main_host_sql.format(ids))
                db.commit()
                cur.execute(update_main_host_pk_sql.format(shot_hosts[shotid]['hostuuid'], str(shot_hosts[shotid]['idtype']), str(mainid)))
                db.commit()
            except:
                pass
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_main_user, omni_unpwd.db_main_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=[1,2])
        shot_hosts, shot_host_groups = load_hosts(omnidb, 'shot_host', program.log)
        main_hosts, main_host_groups = load_hosts(omnidb, 'main_host', program.log)
        process_hosts(omnidb, shot_hosts, main_hosts, shot_host_groups, main_host_groups)
        omnidb.run_program_queries(stage=list(range(3,10)))
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())