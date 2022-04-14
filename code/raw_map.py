#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import time
import nmap
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.msg import msg_loaded_records, msg_prepared_for_scanning, msg_scan_ip_found, msg_db_added_records, msg_scan_snmp_oid_walk, msg_error_insert_values
from omnissiah.const import arp_oid
from omnissiah.util import split_dict, split_list


select_ips_sql = 'SELECT ip, ipid, sourceid, refid FROM raw_scan_ip;'
insert_scan_ports_sql = 'INSERT INTO raw_scan_port (type, port, ipid, state, reason) VALUES (%s, %s, %s, %s, %s);'
select_ip_port_sql = "SELECT DISTINCT ipid, type, port, state, reason FROM raw_scan_port WHERE {0} ORDER BY ipid, type, port, state, reason;"
insert_scan_scripts_sql = 'INSERT INTO raw_scan_script (portid, script, value) VALUES (%s, %s, %s);'
select_scan_portid_sql = "SELECT portid FROM raw_scan_port WHERE ipid={0} AND type='{1}' AND port={2};"
select_ip_port_forservices_sql = "SELECT DISTINCT raw_scan_port.ipid, raw_scan_port.type, raw_scan_port.port FROM raw_scan_port \
LEFT JOIN raw_scan_script ON raw_scan_port.portid=raw_scan_script.portid WHERE \
(raw_scan_port.state='open' OR (raw_scan_script.id IS NOT NULL AND raw_scan_script.value<>'ERROR: Script execution failed (use -d to debug)')) \
{0} ORDER BY raw_scan_port.ipid, raw_scan_port.type, raw_scan_port.port;"
insert_scan_services_sql = 'INSERT INTO raw_scan_service (portid, product, version, extrainfo, conf, cpe, servicefp, name, method) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);'
insert_scan_osportused_sql = 'INSERT INTO raw_scan_osportused (ipid, state, proto, port) VALUES (%s, %s, %s, %s);'
insert_scan_osmatch_sql = 'INSERT INTO raw_scan_osmatch (ipid, name, accuracy, line) VALUES (%s, %s, %s, %s) RETURNING osmatchid;'
insert_scan_osclass_sql = 'INSERT INTO raw_scan_osclass (osmatchid, type, vendor, osfamily, osgen, accuracy, cpe) VALUES (%s, %s, %s, %s, %s, %s, %s);'


def select_ips(db, log):
    result={}
    cur = db.cursor()
    cur.execute(select_ips_sql)
    records = cur.fetchall()
    for r in records:
        result[r[0]] = {'id':r[1], 'sourceid':r[1], 'refid':r[2]}
    cur.close()
    log.info(msg_loaded_records.format('ip addresses', len(result)))
    return result

def single_pool_scan(hosts, arguments, sudo, timeout, log):
    try:
        nmapscan = nmap.PortScanner()
        result = nmapscan.scan(hosts=hosts, arguments=arguments, sudo=sudo, timeout=timeout)
    except:
        log.exception('Fatal error')
        result = None
    return result

def single_process_scan(ips, threadsnum, arguments, timeout, log):
    results = []
    pools = split_dict(ips, omni_config.map_ip_scope_size)
    with ThreadPoolExecutor(max_workers=threadsnum) as executor:
        futures = []
        for pool in pools:
            futures.append(executor.submit(single_pool_scan, hosts=' '.join(pool), arguments=arguments,
                sudo=True, timeout=timeout, log=log))
        for future in as_completed(futures):
            result = future.result()
            if result is not None:
                results.append(result)
        executor.shutdown(wait=False, cancel_futures=True)
    return results

def scan_ips(scanlist, ips, cpusnum, log):
    scans = {}
    if ips is not None:
        if type(ips) is dict:
            pools = split_dict(ips, cpusnum)
        else:
            pools = split_dict(dict.fromkeys(ips, None), cpusnum)
    jobs = []
    for scan in scanlist:
        if ips is None:
            if type(ips) is dict:
                pools = split_dict(scan['ips'], cpusnum)
            else:
                pools = split_dict(dict.fromkeys(scan['ips'], None), cpusnum)
        for pool in pools:
            jobs.append({'ips':pool, 'threadsnum':scan['threadsnum'], 'arguments':scan['arguments'], 'timeout':scan['timeout']+60})
    results = []
    with ProcessPoolExecutor(max_workers=cpusnum) as executor:
        futures = []
        for job in jobs:
            futures.append(executor.submit(single_process_scan, ips=job['ips'], threadsnum=job['threadsnum'], \
                arguments=job['arguments'], timeout=job['timeout'], log=log))
        for future in as_completed(futures):
            result = future.result()
            results.extend(result)
        executor.shutdown(wait=False, cancel_futures=True)
    for result in results:
        for ip, vscan in result['scan'].items():
            if not ip in scans:
                scans[ip] = []
            scans[ip].append(vscan)
    return scans

def save_scans(db, ips, scans, log):
    cur = db.cursor()
    recnum = 0
    for ip, scanlist in scans.items():
        vallist = []
        for scan in scanlist:
            if 'tcp' in scan:
                for port, vport in scan['tcp'].items():
                    vallist.append(('tcp', port, ips[ip]['id'], vport['state'], vport['reason']))
            if 'udp' in scan:
                for port, vport in scan['udp'].items():
                    vallist.append(('udp', port, ips[ip]['id'], vport['state'], vport['reason']))
            if scan['status']['reason']=='echo-reply':
                vallist.append(('icmp', 0, ips[ip]['id'], scan['status']['state'], scan['status']['reason']))
        if vallist:
            cur.executemany(insert_scan_ports_sql, vallist)
            db.commit()
            recnum += len(vallist)
    log.info(msg_db_added_records.format('raw_scan_port', recnum))
    cur.close()

def build_nmap_scan_ports(tcp, udp):
    result = '-sS ' if tcp else ''
    result = result + ('-sU ' if udp else '')
    if tcp or udp:
        result = result + '-p'
    if tcp:
        result = result + 'T:' + ','.join([str(p) for p in tcp])
        if udp:
            result = result + ','
    if udp:
        result = result + 'U:' + ','.join([str(p) for p in udp])
    return result

def select_script_ips(db, log):
    scripts = []
    ipids = {}
    cur = db.cursor()
    cur.execute(select_ips_sql)
    for r in cur.fetchall():
        ipids[r[1]] = r[0]
    for script in omni_config.nmap_script_list:
        ipports = {}
        cur.execute(select_ip_port_sql.format(script['filter']))
        for r in cur.fetchall():
            ip = ipids[r[0]]
            if ip not in ipports:
                ipports[ip] = {'tcp':[], 'udp':[], 'ports':None}
            ipports[ip][r[1]].append(r[2])
        for ip, ports in ipports.items():
            ports['ports'] = build_nmap_scan_ports(ports['tcp'], ports['udp'])
        scanports = {}
        for ip, ports in ipports.items():
            if ports['ports']:
                if ports['ports'] not in scanports:
                    scanports[ports['ports']] = []
                scanports[ports['ports']].append(ip)
        for scanport, ips in scanports.items():
            scripts.append({'threadsnum':script['threadsnum'], 'timeout':script['timeout'],
                'arguments':script['arguments'] + ' ' + scanport, 'ips':ips})
    cur.close()
    return scripts

def build_script_vallist(db, ipid, porttype, scan):
    result = []
    if porttype in scan:
        cur = db.cursor()
        for port, vport in scan[porttype].items():
            if 'script' in vport:
                cur.execute(select_scan_portid_sql.format(ipid, porttype, port))
                portid = cur.fetchone()
                if not portid:
                    vallist = [(porttype, port, ipid, vport['state'], vport['reason'])]
                    cur.executemany(insert_scan_ports_sql, vallist)
                    db.commit()
                    cur.execute(select_scan_portid_sql.format(ipid, porttype, port))
                    portid = cur.fetchone()
                if portid:
                    portid = portid[0]
                    for script, vscript in vport['script'].items():
                        result.append((portid, script, vscript[:omni_config.nmap_max_script_value_len]))
        cur.close()
    return result

def save_scripts(db, ips, scans, log):
    cur = db.cursor()
    recnum = 0
    for ip, scanlist in scans.items():
        vallist = []
        for scan in scanlist:
            vallist.extend(build_script_vallist(db, ips[ip]['id'], 'tcp', scan))
            vallist.extend(build_script_vallist(db, ips[ip]['id'], 'udp', scan))
        if vallist:
            try:
                cur.executemany(insert_scan_scripts_sql, vallist)
                db.commit()
                recnum += len(vallist)
            except:
                log.error(msg_error_insert_values.format('raw_scan_script', str(vallist)))
                db.close()
                time.sleep(omni_config.nmap_db_reconnect_delay)
                db.open()
                cur = db.cursor()
                for v in vallist:
                    cur.execute(insert_scan_scripts_sql, v)
                    db.commit()
                    recnum += 1
    log.info(msg_db_added_records.format('raw_scan_script', recnum))
    cur.close()

def select_services_ips(db, log):
    services = []
    ipids = {}
    cur = db.cursor()
    cur.execute(select_ips_sql)
    for r in cur.fetchall():
        ipids[r[1]] = r[0]
    pfilter = ''
    for ptype, pvalues in omni_config.nmap_service_ports.items():
        if pvalues:
            if pfilter:
                pfilter = pfilter + ' OR '
            pfilter = pfilter + "(raw_scan_port.type='" + ptype + "' AND raw_scan_port.port IN (" + ','.join([str(p) for p in pvalues]) + '))'
    if pfilter:
        pfilter = 'AND (' + pfilter + ')'
    cur.execute(select_ip_port_forservices_sql.format(pfilter))
    ipports = {}
    for r in cur.fetchall():
        ip = ipids[r[0]]
        if ip not in ipports:
            ipports[ip] = {}
        intensity = omni_config.nmap_service_ports[r[1]][r[2]]['intensity']
        timeout = omni_config.nmap_service_ports[r[1]][r[2]]['timeout']
        if intensity not in ipports[ip]:
            ipports[ip][intensity] = {'tcp':[], 'udp':[], 'arguments':None, 'timeout':0}
        ipports[ip][intensity][r[1]].append(r[2])
        ipports[ip][intensity]['timeout'] += timeout
    cur.close()
    for ip, intensities in ipports.items():
        for intensity, ports in intensities.items():
            ports['arguments'] = omni_config.nmap_service_arguments.format(str(ports['timeout']), str(intensity),
                build_nmap_scan_ports(ports['tcp'], ports['udp']))
    scanports = {}
    for ip, intensities in ipports.items():
        for intensity, ports in intensities.items():
            if ports['arguments']:
                if ports['arguments'] not in scanports:
                    scanports[ports['arguments']] = {'timeout':ports['timeout']+60, 'ips':[]}
            scanports[ports['arguments']]['ips'].append(ip)
    for scanport, ips in scanports.items():
        services.append({'threadsnum':omni_config.nmap_service_arguments_threadsnum, 'timeout':ips['timeout'],
            'arguments':scanport, 'ips':ips['ips']})
    return services

def build_service_vallist(db, ipid, porttype, scan):
    result = []
    if porttype in scan:
        cur = db.cursor()
        for port, vport in scan[porttype].items():
            product = vport.get('product') if vport.get('product', None) else None
            version = vport.get('version') if vport.get('version', None) else None
            extrainfo = vport.get('extrainfo') if  vport.get('extrainfo', None) else None
            conf = vport.get('conf') if vport.get('conf', None) else None
            cpe = vport.get('cpe') if vport.get('cpe', None) else None
            servicefp = vport.get('servicefp') if vport.get('servicefp', None) else None
            name = vport.get('name') if vport.get('name', None) else None
            method = vport.get('method') if vport.get('method', None) else None
            if product or version or extrainfo or cpe or servicefp:
                cur.execute(select_scan_portid_sql.format(ipid, porttype, port))
                portid = cur.fetchone()
                if not portid:
                    vallist = [(porttype, port, ipid, vport['state'], vport['reason'])]
                    cur.executemany(insert_scan_ports_sql, vallist)
                    db.commit()
                    cur.execute(select_scan_portid_sql.format(ipid, porttype, port))
                    portid = cur.fetchone()
                if portid:
                    portid = portid[0]
                    conf = int(conf) if conf is not None else None
                    servicefp = servicefp[:omni_config.nmap_max_service_servicefp_len] if servicefp is not None else None
                    result.append((portid, product, version, extrainfo, conf, cpe, servicefp, name, method))
        cur.close()
    return result

def save_services(db, ips, scans, log):
    cur = db.cursor()
    recnum = 0
    for ip, scanlist in scans.items():
        vallist = []
        for scan in scanlist:
            vallist.extend(build_service_vallist(db, ips[ip]['id'], 'tcp', scan))
            vallist.extend(build_service_vallist(db, ips[ip]['id'], 'udp', scan))
        if vallist:
            cur.executemany(insert_scan_services_sql, vallist)
            db.commit()
            recnum += len(vallist)
    log.info(msg_db_added_records.format('raw_scan_service', recnum))
    cur.close()

def select_osdetect_ips(db, log):
    osdetects = []
    ipids = {}
    cur = db.cursor()
    cur.execute(select_ips_sql)
    for r in cur.fetchall():
        ipids[r[1]] = r[0]
    cur.execute(select_ip_port_sql.format(omni_config.nmap_os_filter))
    ipports = {}
    for r in cur.fetchall():
        ip = ipids[r[0]]
        if ip not in ipports:
            ipports[ip] = {'tcp':[], 'udp':[], 'ports':None}
        ipports[ip][r[1]].append(r[2])
    cur.close()
    for ip, ports in ipports.items():
        ports['ports'] = build_nmap_scan_ports(ports['tcp'], ports['udp'])
    scanports = {}
    for ip, ports in ipports.items():
        if ports['ports']:
            if ports['ports'] not in scanports:
                scanports[ports['ports']] = []
            scanports[ports['ports']].append(ip)
    for scanport, ips in scanports.items():
        osdetects.append({'threadsnum':omni_config.nmap_os_arguments_threadsnum, 'timeout':omni_config.nmap_os_timeout,
            'arguments':omni_config.nmap_os_arguments + ' ' + scanport, 'ips':ips})
    return osdetects

def save_osdetects(db, ips, scans, log):
    cur = db.cursor()
    osmatchnum = 0
    osclassnum = 0
    for ip, scanlist in scans.items():
        portused_list = []
        osclass_list = []
        for scan in scanlist:
            portused = scan.get('portused', [])
            for port in portused:
                portused_list.append((ips[ip]['id'], port['state'], port['proto'], port['portid']))
            osmatches = scan.get('osmatch', [])
            for osmatch in osmatches:
                cur.execute(insert_scan_osmatch_sql, (ips[ip]['id'], osmatch['name'], osmatch['accuracy'], osmatch.get('line', None)))
                last_osid = cur.fetchone()[0]
                osmatchnum += 1
                osclasses = osmatch.get('osclass', [])
                for osclass in osclasses:
                    cpe = osclass.get('cpe', [])
                    cpe = cpe[0] if cpe else None
                    osclass_list.append((last_osid, osclass['type'], osclass['vendor'], osclass['osfamily'], osclass['osgen'],
                        osclass['accuracy'], cpe))
        if portused_list:
            cur.executemany(insert_scan_osportused_sql, portused_list)
            db.commit()
        if osclass_list:
            cur.executemany(insert_scan_osclass_sql, osclass_list)
            db.commit()
            osclassnum += len(osclass_list)
    log.info(msg_db_added_records.format('raw_scan_osmatch', osmatchnum))
    log.info(msg_db_added_records.format('raw_scan_osclass', osclassnum))
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        ips = select_ips(omnidb, program.log)
        cpusnum = omni_config.scan_processes_num if omni_config.scan_processes_num else cpu_count() // 2 - 1
        cpusnum = cpusnum if cpusnum>0 else 1
        omnidb.close()
        scans = {}
        scans = scan_ips(omni_config.nmap_map_list, ips, cpusnum, program.log)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_scans(omnidb, ips, scans, program.log)
        omnidb.run_program_queries(stage=2)
        scripts = select_script_ips(omnidb, program.log)
        omnidb.close()
        scans = scan_ips(scripts, None, cpusnum, program.log)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_scripts(omnidb, ips, scans, program.log)
        omnidb.run_program_queries(stage=3)
        services = select_services_ips(omnidb, program.log)
        omnidb.close()
        scans = scan_ips(services, None, cpusnum, program.log)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_services(omnidb, ips, scans, program.log)
        omnidb.run_program_queries(stage=4)
        osdetects = select_osdetect_ips(omnidb, program.log)
        omnidb.close()
        scans = scan_ips(osdetects, None, cpusnum, program.log)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        save_osdetects(omnidb, ips, scans, program.log)
        omnidb.run_program_queries(stage=5)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())