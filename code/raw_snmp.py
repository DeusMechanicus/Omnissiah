#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import nmap
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count
from easysnmp import Session

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.msg import msg_loaded_records, msg_db_added_records, msg_scan_snmp_oid_walk
from omnissiah.const import snmp_community_infoid
from omnissiah.util import split_dict, split_list, hex_from_octets

select_missed_communities_sql = "SELECT raw_scan_ip.ipid, raw_scan_script.value FROM raw_scan_ip INNER JOIN raw_scan_port ON raw_scan_ip.ipid=raw_scan_port.ipid \
INNER JOIN raw_scan_script ON raw_scan_port.portid=raw_scan_script.portid WHERE raw_scan_script.script='snmp-brute' AND \
raw_scan_ip.ipid NOT IN (SELECT ipid FROM raw_scan_ip_info WHERE infoid=1) AND raw_scan_script.value LIKE '% - Valid credentials%';"
insert_scan_infos_sql = 'INSERT INTO raw_scan_ip_info(ipid, infoid, value) VALUES (%s, %s, %s)';
select_snmp_communities_sql = "SELECT raw_scan_ip.ip, raw_scan_ip_info.value, raw_scan_ip.ipid, ref_ipprefix.siteid FROM raw_scan_ip \
INNER JOIN raw_scan_ip_info ON raw_scan_ip.ipid=raw_scan_ip_info.ipid \
INNER JOIN ref_scan_ip_info ON raw_scan_ip_info.infoid=ref_scan_ip_info.infoid \
LEFT JOIN ref_ipprefix ON raw_scan_ip.refid=ref_ipprefix.ipprefixid AND raw_scan_ip.sourceid=1 \
WHERE ref_scan_ip_info.info='snmp_community';"
select_ping_ipprefix_sql = 'SELECT DISTINCT ref_ipprefix.siteid, ref_ipprefix.startip, ref_ipprefix.netnum FROM raw_scan_ip \
LEFT JOIN ref_ipprefix ON raw_scan_ip.refid=ref_ipprefix.ipprefixid WHERE raw_scan_ip.sourceid=1 ORDER BY ref_ipprefix.siteid;'
select_oids_sql = 'SELECT oidid, name, oid, command, prescan FROM ref_scan_snmp_oid;'
insert_snmp_sql = 'INSERT INTO raw_snmp(ipid, oidid, oid, snmp_type, value, value_hex, vlan) VALUES (%s, %s, %s, %s, %s, %s, %s)';
select_vlan_oid_sql = "SELECT raw_scan_ip.ip, raw_snmp.oid FROM raw_snmp \
INNER JOIN ref_scan_snmp_oid ON raw_snmp.oidid=ref_scan_snmp_oid.oidid \
INNER JOIN raw_scan_ip ON raw_snmp.ipid=raw_scan_ip.ipid \
WHERE ref_scan_snmp_oid.name='vtpVlanState' AND raw_snmp.value='1' \
ORDER BY raw_scan_ip.ip;"


def add_missed_communities(db, log):
    cur = db.cursor()
    cur.execute(select_missed_communities_sql)
    vallist = []
    for r in cur.fetchall():
        for s in r[1].split('\n'):
            if 'valid credentials' in s.lower():
                vallist.append((r[0], snmp_community_infoid, s.split('-')[0].strip()))
                break
    if vallist:
        cur.executemany(insert_scan_infos_sql, vallist)
        db.commit()
    cur.close()

def select_snmp_ips(db, log):
    result = {}
    cur = db.cursor()
    cur.execute(select_snmp_communities_sql)
    for r in cur.fetchall():
        result[r[0]] = {'ip':r[0], 'community':r[1], 'ipid':r[2], 'siteid':r[3], 'ping':[], 'vlan':None}
    sites = {}
    cur.execute(select_ping_ipprefix_sql)
    for r in cur.fetchall():
        if r[0] not in sites:
            sites[r[0]] = []
        sites[r[0]].append({'startip':r[1], 'netnum':r[2]})
    for ip, vsnmp in result.items():
        if vsnmp['siteid'] in sites:
            for prefix in sites[vsnmp['siteid']]:
                hosts = prefix['startip'] + '/' + str(prefix['netnum'])
                timeout = omni_config.snmp_ping_timeout if prefix['netnum']>=24 else \
                    omni_config.snmp_ping_timeout*pow(2, 24-prefix['netnum'])
                vsnmp['ping'].append({'hosts':hosts, 'timeout':timeout})
    log.info(msg_loaded_records.format('SNMP hosts', len(result)))
    return result

def select_oids(db, log):
    result = {}
    cur = db.cursor()
    cur.execute(select_oids_sql)
    for r in cur.fetchall():
        result[r[0]] = {'oidid':r[0], 'name':r[1], 'oid':r[2], 'command':r[3], 'prescan':(True if r[4] else False)}
    cur.close()
    return result

def single_host_oid_walk(ip, oid, community, timeout, retries, log, bulk=True, pings=[], vlan=None):
    try:
        result = None
        if oid['prescan']:
            nmapscan = nmap.PortScanner()
            for ping in pings:
                try:
                    nmapscan.scan(hosts=ping['hosts'], arguments=omni_config.snmp_ping_scan, sudo=True,
                        timeout=ping['timeout'])
                except:
                    log.exception('Fatal error')
        session = Session(hostname=ip, community=community, version=2, timeout=timeout, retries=retries)
        if oid['command']=='walk':
            if bulk:
                result = session.bulkwalk(oid['oid'])
            else:
                result = session.walk(oid['oid'])
        elif oid['command']=='get':
            result = session.get(oid['oid'])
        if not isinstance(result, list):
            result = [result]
        result = {'ip':ip, 'oidid':oid['oidid'], 'vlan':vlan, 'snmp':result}
    except:
#        log.exception('Fatal error')
        result = None
    return result

def single_process_snmp_oid_walk(ips, oid, timeout, retries, threadsnum, log):
    results = []
    with ThreadPoolExecutor(max_workers=threadsnum) as executor:
        futures = []
        for ipinfo in ips:
            futures.append(executor.submit(single_host_oid_walk, ip=ipinfo['ip'], oid=oid, community=ipinfo['community'],
                timeout=timeout, retries=retries, log=log, bulk=True, pings=ipinfo['ping'], vlan=ipinfo['vlan']))
        for future in as_completed(futures):
            result = future.result()
            if result is not None:
                results.append(result)
        executor.shutdown(wait=False, cancel_futures=True)
    return results

def snmp_walk(ips, oids, cpusnum, log):
    walks = []
    if isinstance(ips, dict):
        pools = split_list(list(ips.values()), cpusnum)
    else:
        pools = split_list(ips, cpusnum)
    jobs = []
    for oidid, oid in oids.items():
        for pool in pools:
            jobs.append({'ips':pool, 'oid':oid, 'timeout':omni_config.snmp_timeout, 'retries':omni_config.snmp_retries, 
                'threadsnum':omni_config.snmp_threads, 'log':log})
    with ProcessPoolExecutor(max_workers=cpusnum) as executor:
        futures = []
        for job in jobs:
            futures.append(executor.submit(single_process_snmp_oid_walk, ips=job['ips'], oid=job['oid'], timeout=job['timeout'],
                retries=job['retries'], threadsnum=job['threadsnum'], log=job['log']))
        for future in as_completed(futures):
            result = future.result()
            walks.extend(result)
        executor.shutdown(wait=False, cancel_futures=True)
    return walks

def save_walks(db, ips, oids, walks, log):
    cur = db.cursor()
    vallist = []
    for walk in walks:
        for snmp in walk['snmp']:
            value = str(snmp.value)
            value_hex = hex_from_octets(snmp.value)
            oid = snmp.oid + '.' + snmp.oid_index if snmp.oid_index else snmp.oid
            value = value.replace('\x00', '')
            value = value[:omni_config.snmp_max_value_len]
            value_hex = value_hex[:omni_config.snmp_max_value_len*2]
            if value:
                vallist.append((ips[walk['ip']]['ipid'], walk['oidid'], oid, snmp.snmp_type, value, value_hex, walk['vlan']))
    if vallist:
        cur.executemany(insert_snmp_sql, vallist)
        db.commit()
        log.info(msg_db_added_records.format('raw_snmp', len(vallist)))

def select_vlan_ips(db, ips, log):
    result = []
    cur = db.cursor()
    cur.execute(select_vlan_oid_sql)
    for r in cur.fetchall():
        record = ips[r[0]].copy()
        record['vlan'] = int(r[1].split('.')[-1])
        record['community'] = record['community'] + '@' + str(record['vlan'])
        result.append(record)
    log.info(msg_loaded_records.format('SNMP hosts and vlans', len(result)))
    return result


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        add_missed_communities(omnidb, program.log)
        ips = select_snmp_ips(omnidb, program.log)
        oids = select_oids(omnidb, program.log)
        omnidb.close()
        cpusnum = omni_config.scan_processes_num if omni_config.scan_processes_num else cpu_count() // 2 - 1
        cpusnum = cpusnum if cpusnum>0 else 1
        walks = snmp_walk(ips, oids, cpusnum, program.log)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_walks(omnidb, ips, oids, walks, program.log)
        omnidb.run_program_queries(stage=2)
        ips_vlan = select_vlan_ips(omnidb, ips, program.log)
        omnidb.close()
        oids_vlan = {k:v for k,v in oids.items() if v['name'] in [omni_const.oid_macaddrtable_name, omni_const.oid_macporttable_name]}
        if oids_vlan:
            walks = snmp_walk(ips_vlan, oids_vlan, cpusnum, program.log)
        else:
            walks = None
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        if walks:
            save_walks(omnidb, ips, oids, walks, program.log)
        omnidb.run_program_queries(stage=3)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())