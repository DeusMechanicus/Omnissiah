#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.util import union_list_of_sets

select_site_ip_if_sql = 'SELECT src_if.siteid, src_if.device, src_ip.ipid FROM src_if INNER JOIN src_ip ON src_if.siteid=src_ip.siteid AND src_if.ip=src_ip.ip \
WHERE src_if.siteid IS NOT NULL;'
select_site_mac_sql = 'SELECT siteid, mac, ipid FROM src_ip WHERE siteid IS NOT NULL AND mac IS NOT NULL AND (siteid, mac) IN (SELECT siteid, mac FROM src_ip \
WHERE siteid IS NOT NULL AND mac IS NOT NULL GROUP BY siteid, mac HAVING COUNT(*)>1);'
select_site_prefix_mac_sql = {'mariadb':'SELECT src_ip.siteid, src_ip.ipid, si.ipid FROM src_ip \
INNER JOIN src_ip AS si ON src_ip.siteid=si.siteid AND src_ip.ipprefixid<>si.ipprefixid \
WHERE src_ip.siteid IS NOT NULL AND src_ip.ipprefixid IS NOT NULL AND \
src_ip.macnum IS NOT NULL AND si.macnum IS NOT NULL AND ABS(CAST(src_ip.macnum AS INTEGER)-CAST(si.macnum AS INTEGER))<16',
'pgsql':'SELECT src_ip.siteid, src_ip.ipid, si.ipid FROM src_ip \
INNER JOIN src_ip AS si ON src_ip.siteid=si.siteid AND src_ip.ipprefixid<>si.ipprefixid \
WHERE src_ip.siteid IS NOT NULL AND src_ip.ipprefixid IS NOT NULL AND \
src_ip.macnum IS NOT NULL AND si.macnum IS NOT NULL AND ABS(src_ip.macnum-si.macnum)<16;'};
select_site_hostname_router_sql = "SELECT src_ip.siteid, src_ip_info.value, src_ip.ipid FROM src_ip \
INNER JOIN src_ip_info ON src_ip.ipid=src_ip_info.ipid \
INNER JOIN ref_scan_ip_info ON src_ip_info.infoid=ref_scan_ip_info.infoid \
INNER JOIN src_scan_ip ON src_ip.ip=src_scan_ip.ip \
INNER JOIN src_snmp_router ON src_scan_ip.ipid=src_snmp_router.routerid \
WHERE ref_scan_ip_info.info='name' AND src_snmp_router.ipforwarding IS NOT NULL AND src_snmp_router.ipforwarding=1;"
select_src_ip_sql = 'SELECT src_ip.ipid, src_ip.ip, ref_subnet_role.subnet_role_alias FROM src_ip \
LEFT JOIN ref_subnet_role ON src_ip.roleid=ref_subnet_role.subnet_roleid \
ORDER BY src_ip.ispublic, src_ip.ip;'
update_tmp_src_ip_sql = 'UPDATE tmp_src_ip SET parent_ipid=%s WHERE ip=%s;'


def find_2keys_ipids(db, sql):
    result = []
    dups = {}
    cur = db.cursor()
    cur.execute(sql)
    for r in cur.fetchall():
        if r[0] not in dups:
            dups[r[0]] = {}
        if r[1] not in dups[r[0]]:
            dups[r[0]][r[1]] = set()
        dups[r[0]][r[1]].add(r[2])
    cur.close()
    for key1, values1 in dups.items():
        for ket2, values2 in values1.items():
            if len(values2)>1:
                result.append(values2)
    result = union_list_of_sets(result)
    return result

def find_site_prefix_mac_ipids(db):
    result = []
    dups = {}
    cur = db.cursor()
    cur.execute(select_site_prefix_mac_sql[omni_config.dbtype])
    for r in cur.fetchall():
        if r[0] not in dups:
            dups[r[0]] = {}
        if r[1] not in dups[r[0]]:
            dups[r[0]][r[1]] = {r[1]}
        dups[r[0]][r[1]].add(r[2])
    cur.close()
    for siteid, ipids1 in dups.items():
        for ipid, ipids2 in ipids1.items():
            result.append(ipids2)
    result = union_list_of_sets(result)
    return result

def find_duplicates(db, log):
    result = {}
    result['site_ip_if'] = find_2keys_ipids(db, select_site_ip_if_sql)
    result['site_mac'] = find_2keys_ipids(db, select_site_mac_sql)
    result['site_prefix_mac'] = find_site_prefix_mac_ipids(db)
    result['site_hostname_router'] = find_2keys_ipids(db, select_site_hostname_router_sql)
    return result

def save_duplicates(db, dups, log):
    ips = {}
    aggr_dups = []
    cur = db.cursor()
    cur.execute(select_src_ip_sql)
    i = 0
    for r in cur.fetchall():
        ips[r[0]] = {'ipid':r[0], 'ip':r[1], 'role':r[2], 'index':i}
        i += 1
    for k, ipids in dups.items():
        aggr_dups.extend(ipids)
    aggr_dups = union_list_of_sets(aggr_dups)
    vallist = []
    for ipids in aggr_dups:
        main_ipid = None
        ipids_list = [ips[k] for k in ipids]
        ipids_list = sorted(ipids_list, key=lambda d: d['index'])
        for ipid in ipids_list:
            if ipid['role'] in omni_config.mgmt_roles:
                main_ipid = ipid['ipid']
                break
        if not main_ipid:
            main_ipid = ipids_list[0]['ipid']
        ipids.remove(main_ipid)
        for ipid in ipids:
            vallist.append((main_ipid, ips[ipid]['ip']))
    if vallist:
        cur.executemany(update_tmp_src_ip_sql, vallist)
        db.commit()
    cur.close()
    return


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_src_user, omni_unpwd.db_src_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        for stage in range(13):
            omnidb.run_program_queries(stage=stage)
        dups = find_duplicates(omnidb, program.log)
        save_duplicates(omnidb, dups, program.log)
        omnidb.run_program_queries(stage=13)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())