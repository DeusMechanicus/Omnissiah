#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
from ipaddress import ip_network, ip_address, summarize_address_range
import nmap
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count
from easysnmp import Session

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.msg import msg_loaded_records, msg_prepared_for_scanning, msg_scan_ip_found, msg_db_added_records, msg_scan_snmp_oid_walk
from omnissiah.const import arp_oid
from omnissiah.util import split_dict, split_list, ip_from_oid, hex_from_octets


sourceid_prefix = 1
sourceid_range = 2
sourceid_address = 3
select_ipprefix_sql = 'SELECT ref_ipprefix.ipprefixid, ref_ipprefix.startip, ref_ipprefix.netnum, ref_subnet_role.subnet_role_alias, ref_ipprefix.vlanid, ref_vlan.description \
FROM ref_ipprefix INNER JOIN ref_site ON ref_ipprefix.siteid=ref_site.siteid LEFT JOIN ref_vlan ON ref_ipprefix.vlanid=ref_vlan.vlanid \
LEFT JOIN ref_subnet_role ON (ref_ipprefix.roleid IS NOT NULL AND ref_ipprefix.roleid=ref_subnet_role.subnet_roleid) OR \
(ref_ipprefix.roleid IS NULL AND ref_vlan.roleid=ref_subnet_role.subnet_roleid) \
WHERE ref_ipprefix.active=1 AND ref_site.active=1 AND (ref_ipprefix.vlanid IS NULL OR ref_vlan.active=1) {0};'
select_iprange_sql = 'SELECT ref_iprange.iprangeid, ref_iprange.startip, ref_iprange.endip, ref_subnet_role.subnet_role_alias FROM ref_iprange \
LEFT JOIN ref_subnet_role ON ref_iprange.roleid=ref_subnet_role.subnet_roleid WHERE ref_iprange.active=1 {0};'
insert_scans_sql = 'INSERT INTO raw_scan_ip (ip, sourceid, refid) VALUES (%s, %s, %s);'
insert_scan_infos_sql = "INSERT INTO raw_scan_ip_info(ipid, infoid, value) SELECT raw_scan_ip.ipid, ref_scan_ip_info.infoid, '{0}' FROM raw_scan_ip \
INNER JOIN ref_scan_ip_info ON ref_scan_ip_info.info='{1}' WHERE raw_scan_ip.ip='{2}';"
select_snmp_communities = "SELECT raw_scan_ip.ip, raw_scan_ip_info.value, raw_scan_ip.ipid FROM raw_scan_ip INNER JOIN raw_scan_ip_info ON raw_scan_ip.ipid=raw_scan_ip_info.ipid \
INNER JOIN ref_scan_ip_info ON raw_scan_ip_info.infoid=ref_scan_ip_info.infoid WHERE ref_scan_ip_info.info='snmp_community';"
insert_scans_arp_sql = 'INSERT INTO raw_scan_arp (ip, routerid, mac) VALUES (%s, %s, %s);'
insert_scans_dhcp_sql = 'INSERT INTO raw_scan_dhcp (ip, routerid, mac) VALUES (%s, %s, %s);'
select_ping_ipprefix_sql = 'SELECT raw_scan_ip.ip, ref_ipprefix.startip, ref_ipprefix.netnum FROM raw_scan_ip \
INNER JOIN ref_ipprefix AS rip ON raw_scan_ip.refid=rip.ipprefixid AND raw_scan_ip.sourceid=1 \
INNER JOIN ref_site ON rip.siteid=ref_site.siteid \
INNER JOIN ref_ipprefix ON ref_site.siteid=ref_ipprefix.siteid \
LEFT JOIN ref_vlan ON ref_ipprefix.vlanid=ref_vlan.vlanid \
LEFT JOIN ref_subnet_role ON (ref_ipprefix.roleid IS NOT NULL AND ref_ipprefix.roleid=ref_subnet_role.subnet_roleid) OR (ref_ipprefix.roleid IS NULL AND ref_vlan.roleid=ref_subnet_role.subnet_roleid) \
WHERE ref_ipprefix.active=1 AND (ref_ipprefix.vlanid IS NULL OR ref_vlan.active=1);'
select_ping_iprange_sql = 'SELECT raw_scan_ip.ip, ref_iprange.startipnum, ref_iprange.endipnum FROM raw_scan_ip \
INNER JOIN ref_iprange ON raw_scan_ip.refid=ref_iprange.iprangeid AND raw_scan_ip.sourceid=2;'
select_arpdhcp_sql = "SELECT DISTINCT ip FROM (SELECT ip FROM raw_scan_arp WHERE ip<>'0.0.0.0' AND mac NOT IN ('', '000000000000', 'FFFFFFFFFFFF') \
UNION SELECT ip FROM raw_scan_dhcp WHERE ip<>'0.0.0.0') AS ipmac WHERE ipmac.ip NOT IN (SELECT ip FROM raw_scan_ip);"


def select_ips(db, log):
    result={'prefix':[], 'range':[], 'address':[]}
    cur = db.cursor()
    cur.execute(select_ipprefix_sql.format(omni_config.scan_subnet_ipprefix_filter))
    records = cur.fetchall()
    result['prefix'] = [ {'id':r[0], 'subnet':r[1], 'netnum':r[2], 'role':r[3], 'vlanid':r[4]} for r in records ]
    log.info(msg_loaded_records.format('prefixes', len(result['prefix'])))
    cur.execute(select_iprange_sql.format(omni_config.scan_subnet_iprange_filter))
    records = cur.fetchall()
    result['range'] = [ {'id':r[0], 'startip':r[1], 'endip':r[2], 'role':r[3]} for r in records ]
    log.info(msg_loaded_records.format('ranges', len(result['range'])))
    result['address'] = []
    cur.close()
    return result

def prefixes_subnet_of(prefix, prefixes):
    subnet = prefixes[prefix]['subnet']
    result = []
    for iprefix, vprefix in prefixes.items():
        if prefix!=iprefix and vprefix['subnet'].subnet_of(subnet):
            result.append(iprefix)
    return result

def prefixes_supernet_of(prefix, prefixes):
    subnet = prefixes[prefix]['subnet']
    result = []
    for iprefix, vprefix in prefixes.items():
        if prefix!=iprefix and vprefix['subnet'].supernet_of(subnet):
            result.append(iprefix)
    return result

def prepare_ips(ips, log):
    prefixes = {}
    addresses = {}
    prefixes_temp = {}
    for prefix in ips['prefix']:
        newprefix = prefix['subnet'] + '/' + str(prefix['netnum'])
        newsubnet = ip_network(newprefix, strict=False)
        newprefix = str(newsubnet)
        if newprefix not in prefixes:
            prefixes_temp[newprefix] = {'refid':prefix['id'], 'sourceid':omni_const.ip_sourceid_prefix, 'subnet':newsubnet,
                'role':prefix['role'], 'vlan_linked':False if prefix['vlanid'] is None else True}
    log.info(msg_prepared_for_scanning.format('subnets', len(prefixes_temp)))
    for iprefix, vprefix in prefixes_temp.items():
        subnet_of = prefixes_subnet_of(iprefix, prefixes_temp)
        supernet_of = prefixes_supernet_of(iprefix, prefixes_temp)
        addprefix = True
        if not (supernet_of or subnet_of):
            pass
        elif (supernet_of and not subnet_of):
            if vprefix['vlan_linked']:
                for prefix in supernet_of:
                    if prefixes_temp[prefix]['vlan_linked']:
                        addprefix = False
                        break
            else:
                addprefix = False
        elif (not supernet_of and subnet_of):
            if not vprefix['vlan_linked']:
                for prefix in subnet_of:
                    if prefixes_temp[prefix]['vlan_linked']:
                        addprefix = False
                        break
        else:
            if vprefix['vlan_linked']:
                for prefix in supernet_of:
                    if prefixes_temp[prefix]['vlan_linked']:
                        addprefix = False
                        break
            else:
                addprefix = False
            if addprefix:
                for prefix in subnet_of:
                    if prefixes_temp[prefix]['vlan_linked']:
                        addprefix = False
                        break
        if addprefix:
            prefixes[iprefix] = vprefix
    log.info(msg_prepared_for_scanning.format('filtered subnets', len(prefixes)))

    for rng in ips['range']:
        startip = ip_address(rng['startip'])
        endip = ip_address(rng['endip'])
        for ipnum in range(int(startip), int(endip)+1):
            newipaddr = ip_address(ipnum)
            newip = str(newipaddr)
            if newip not in addresses:
                for iprefix, vprefix in prefixes.items():
                    if newipaddr in vprefix['subnet']:
                        newip = None
                        break
            if newip:
                addresses[newip] = {'refid':rng['id'], 'sourceid':omni_const.ip_sourceid_range,
                    'subnet':ip_network(newip), 'ipaddr':newipaddr, 'role':rng['role'], 'addrrole':None}
    for ip in ips['address']:
        newip = ip['ip']
        if newip not in addresses:
            newipaddr = ip_address(newip)
            for iprefix, vprefix in prefixes.items():
                if newipaddr in vprefix['subnet']:
                    newip = None
                    break
            if newip:
                addresses[newip] = {'refid':ip['id'], 'sourceid':omni_const.ip_sourceid_address,
                    'subnet':ip_network(newip), 'ipaddr':newipaddr, 'role':None, 'addrrole':ip['addrrole']}
    log.info(msg_prepared_for_scanning.format('addresses', len(addresses)))
    return {'prefixes':prefixes, 'addresses':addresses}

def single_prefix_scan(hosts, prefix_info, arguments, sudo, timeout, log):
    try:
        nmapscan = nmap.PortScanner()
        result = nmapscan.scan(hosts=hosts, arguments=arguments, sudo=sudo, timeout=timeout)
        result['prefix'] = prefix_info
    except:
        log.exception('Fatal error')
        result = None
    return result

def single_process_prefix_scan(ips, isprefix, threadsnum, arguments, timeout, log):
    results = []
    with ThreadPoolExecutor(max_workers=threadsnum) as executor:
        futures = []
        for prefix, prefix_info in ips.items():
            if isprefix:
                if prefix_info['subnet'].prefixlen>=24:
                    subnet_timeout = timeout
                else:
                    subnet_timeout = timeout*pow(2, 24-prefix_info['subnet'].prefixlen)
                prefix_info = {'sourceid':prefix_info['sourceid'], 'refid':prefix_info['refid']}
            else:
                subnet_timeout = timeout
                prefix_info = None
            subnet_timeout += 60
            futures.append(executor.submit(single_prefix_scan, hosts=prefix, prefix_info=prefix_info,
                arguments=arguments, sudo=True, timeout=subnet_timeout, log=log))
        for future in as_completed(futures):
            result = future.result()
            if result is not None:
                results.append(result)
        executor.shutdown(wait=False, cancel_futures=True)
    return results

def ifipup(scan):
    if scan['status']['state']=='up':
        if scan['status']['reason'] in ['echo-reply', 'open', 'udp-response', 'syn-ack', 'proto-unreach', 'reset', 'tcp-response']:
            return True
        if 'tcp' in scan:
            for port, result in scan['tcp'].items():
                if result['state']=='open' and result['reason']=='tcp-response':
                    return True
        if 'udp' in scan:
            for port, result in scan['udp'].items():
                if result['state']=='open' and result['reason']=='udp-response':
                    return True
    return False

def scan_prefixes(ips, cpusnum, log):
    scans = {}
    pools = split_dict(ips, cpusnum)
    for scan in omni_config.nmap_scan_list:
        results = []
        with ProcessPoolExecutor(max_workers=cpusnum) as executor:
            futures = []
            for pool in pools:
                futures.append(executor.submit(single_process_prefix_scan, ips=pool, isprefix=True,
                    threadsnum=scan['threadsnum'], arguments=scan['arguments'], timeout=scan['timeout'], log=log))
            for future in as_completed(futures):
                result = future.result()
                results.extend(result)
            executor.shutdown(wait=False, cancel_futures=True)
        for result in results:
            for ip, vscan in result['scan'].items():
                if ifipup(vscan):
                    if not ip in scans:
                        scans[ip] = {'sourceid':result['prefix']['sourceid'], 'refid':result['prefix']['refid'], 'info':{}}
                    if scan['info'] is not None:
                        scans[ip]['info'][scan['info']] = vscan
    log.info(msg_scan_ip_found.format('prefix', len(scans)))
    return scans

def scan_rangeip(ips, cpusnum, log):
    scans = {}
    pools = split_dict(ips, cpusnum)
    for scan in omni_config.nmap_scan_list:
        results = []
        with ProcessPoolExecutor(max_workers=cpusnum) as executor:
            futures = []
            for pool in pools:
                scopes = split_dict(pool, omni_config.scan_rangeip_scope_size)
                ips = {}
                for scope in scopes:
                    ips[' '.join(scope)] = None
                futures.append(executor.submit(single_process_prefix_scan, ips=ips, isprefix=False,
                    threadsnum=scan['threadsnum'], arguments=scan['arguments'], timeout=scan['timeout'], log=log))
            for future in as_completed(futures):
                result = future.result()
                results.extend(result)
            executor.shutdown(wait=False, cancel_futures=True)
        for result in results:
            for ip, vscan in result['scan'].items():
                if ifipup(vscan):
                    if not ip in scans:
                        scans[ip] = {'sourceid':ips[ip]['sourceid'], 'refid':ips[ip]['refid'], 'info':{}}
                    if scan['info'] is not None:
                        scans[ip]['info'][scan['info']] = vscan
    log.info(msg_scan_ip_found.format('range', len(scans)))
    return scans

def save_scans(db, scans, log):
    cur = db.cursor()
    vallist = []
    for ip, scan in scans.items():
        vallist.append((ip, scan['sourceid'], scan['refid']))
    if vallist:
        cur.executemany(insert_scans_sql, vallist)
        log.info(msg_db_added_records.format('raw_scan_ip', len(vallist)))
        db.commit()
    recnum = 0
    for ip, scan in scans.items():
        if 'snmp_community' in scan['info']:
            try:
                community = scan['info']['snmp_community']['udp'][161]['script']['snmp-brute']
            except:
                community = None
            if community:
                for s in community.split('\n'):
                    if 'valid credentials' in s.lower():
                        community = s.split('-')[0].strip()
                        cur.execute(insert_scan_infos_sql.format(community, 'snmp_community', ip))
                        db.commit()
                        recnum += 1
                        break
    if recnum:
        log.info(msg_db_added_records.format('raw_scan_ip_info', recnum))
    cur.close()

def select_snmp_ips(db, ips, log):
    cur = db.cursor()
    cur.execute(select_snmp_communities)
    records = cur.fetchall()
    result = {}
    for r in records:
        result[r[0]] = {'community':r[1], 'ipid':r[2], 'ping':[]}
    cur.execute(select_ping_ipprefix_sql)
    records = cur.fetchall()
    prefixes = {}
    for r in records:
        if r[0] not in prefixes:
            prefixes[r[0]] = []
        prefixes[r[0]].append({'startip':r[1], 'netnum':r[2]})
    cur.execute(select_ping_iprange_sql)
    records = cur.fetchall()
    addresses = {}
    for r in records:
        if r[0] not in addresses:
            addresses[r[0]] = []
        for ipnum in range(r[1], r[2]+1):
            addresses[r[0]].append(str(ip_address(ipnum)))
    cur.close()
    for ip, vsnmp in result.items():
        if ip in prefixes:
            for prefix in prefixes[ip]:
                hosts = prefix['startip'] + '/' + str(prefix['netnum'])
                if hosts in ips['prefixes']:
                    timeout = omni_config.snmp_ping_timeout if prefix['netnum']>=24 else \
                        omni_config.snmp_ping_timeout*pow(2, 24-prefix['netnum'])
                    vsnmp['ping'].append({'hosts':hosts, 'timeout':timeout})
        addrs = []
        if ip in addresses:
            for address in addresses[ip]:
                if address in ips['addresses']:
                    addrs.append(address)
            pools = split_list(addrs, 256)
            for pool in pools:
                vsnmp['ping'].append({'hosts':' '.join(pool), 'timeout':timeout})
    log.info(msg_loaded_records.format('SNMP hosts', len(result)))
    return result

def single_host_oid_walk(ip, oid, community, timeout, retries, log, bulk=True, pings=[]):
    try:
        result = {}
        if oid==arp_oid:
            nmapscan = nmap.PortScanner()
            for ping in pings:
                try:
                    nmapscan.scan(hosts=ping['hosts'], arguments=omni_config.snmp_ping_scan, sudo=True,
                        timeout=ping['timeout'])
                except:
                    log.exception('Fatal error')
                    pass
        session = Session(hostname=ip, community=community, version=2,
                    timeout=timeout, retries=retries)
        if bulk:
            result[ip] = session.bulkwalk(oid)
        else:
            result[ip] = session.walk(oid)
    except:
        result = None
    return result

def single_process_host_oid_walk(ips, oid, timeout, retries, threadsnum, log):
    results = {}
    with ThreadPoolExecutor(max_workers=threadsnum) as executor:
        futures = []
        for ip, ipinfo in ips.items():
            futures.append(executor.submit(single_host_oid_walk, ip=ip, oid=oid, community=ipinfo['community'],
                timeout=timeout, retries=retries, log=log, bulk=True, pings=ipinfo['ping']))
        for future in as_completed(futures):
            result = future.result()
            if result is not None:
                results.update(result)
        executor.shutdown(wait=False, cancel_futures=True)
    return results

def host_oid_walk(ips, oids, cpusnum, log):
    walks = {}
    pools = split_dict(ips, cpusnum)
    if not isinstance(oids, list):
        oids = [oids]
    for oid in oids:
        walks[oid] = {}
        with ProcessPoolExecutor(max_workers=cpusnum) as executor:
            futures = []
            for pool in pools:
                futures.append(executor.submit(single_process_host_oid_walk, ips=pool, oid=oid, timeout=omni_config.snmp_timeout,
                    retries=omni_config.snmp_retries, threadsnum=omni_config.snmp_threads, log=log))
            for future in as_completed(futures):
                result = future.result()
                walks[oid].update(result)
            executor.shutdown(wait=False, cancel_futures=True)
        log.info(msg_scan_snmp_oid_walk.format(oid, len(walks[oid]), sum(len(l) for i, l in walks[oid].items())))
    return walks

def save_walks(db, ips, walks, log):
    cur = db.cursor()
    arplist = []
    dhcplist = []
    for oid, oidwalks in walks.items():
        for routerip, walk in oidwalks.items():
            if oid==arp_oid:
                for value in walk:
                    ip = ip_from_oid(value.oid)
                    mac = hex_from_octets(value.value)
                    if ip and len(mac)==12:
                        arplist.append((ip, ips[routerip]['ipid'], mac))
            elif oid in omni_const.dhcp_oids:
                for value in walk:
                    ip = ip_from_oid(value.oid)
                    mac = hex_from_octets(value.value)
                    if ip and len(mac)==12:
                        dhcplist.append((ip, ips[routerip]['ipid'], mac))
    if arplist:
        cur.executemany(insert_scans_arp_sql, arplist)
        log.info(msg_db_added_records.format('raw_scan_arp', len(arplist)))
        db.commit()
    if dhcplist:
        cur.executemany(insert_scans_dhcp_sql, dhcplist)
        log.info(msg_db_added_records.format('raw_scan_dhcp', len(dhcplist)))
        db.commit()
    cur.close()

def add_arpdhcp_to_scan(db, ips, log):
    cur = db.cursor()
    cur.execute(select_arpdhcp_sql)
    vallist = []
    ip = cur.fetchone()
    while ip is not None:
        ip = ip[0]
        if ip in ips['addresses']:
            vallist.append((ip, ips['addresses'][ip]['sourceid'], ips['addresses'][ip]['refid']))
        else:
            ipaddr = ip_address(ip)
            for prefix, vprefix in ips['prefixes'].items():
                if ipaddr in vprefix['subnet']:
                    vallist.append((ip, vprefix['sourceid'], vprefix['refid']))
                    break
        ip = cur.fetchone()
    if vallist:
        cur.executemany(insert_scans_sql, vallist)
        log.info(msg_db_added_records.format('raw_scan_ip', len(vallist)))
        db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        ips = select_ips(omnidb, program.log)
        ips = prepare_ips(ips, program.log)
        cpusnum = omni_config.scan_processes_num if omni_config.scan_processes_num else cpu_count() // 2 - 1
        cpusnum = cpusnum if cpusnum>0 else 1
        omnidb.close()
        scans = {}
        scans = scan_prefixes(ips['prefixes'], cpusnum, program.log)
        scans.update(scan_rangeip(ips['addresses'], cpusnum, program.log))
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_scans(omnidb, scans, program.log)
        omnidb.run_program_queries(stage=2)
        snmp_ips = select_snmp_ips(omnidb, ips, program.log)
        oids = omni_const.dhcp_oids.copy()
        oids.append(arp_oid)
        walks = host_oid_walk(snmp_ips, oids, cpusnum, program.log)
        save_walks(omnidb, snmp_ips, walks, program.log)
        add_arpdhcp_to_scan(omnidb, ips, program.log)
        omnidb.run_program_queries(stage=3)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())