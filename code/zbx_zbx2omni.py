#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import json

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.zbx import ZbxAPI


proxies_output = ['host', 'name']
maintenances_output = ['name', 'maintenance_type', 'active_since', 'active_till']
hosts_output = ['host', 'name', 'description', 'flags', 'inventory_mode', 'ipmi_authtype', 'ipmi_password', 'ipmi_privilege',
            'ipmi_username', 'maintenance_from', 'maintenance_status', 'maintenance_type', 'maintenanceid', 'proxy_hostid',
            'status', 'tls_connect', 'tls_accept', 'tls_issuer', 'tls_subject', 'lastaccess']
hstgrp_output = ['name', 'internal', 'flags']
macros_output = ['hostmacroid', 'macro', 'value', 'description', 'type']
tags_output = ['hosttagid', 'tag', 'value']
items_output = ['itemid', 'delay', 'hostid', 'interfaceid', 'key_', 'name', 'type', 'url', 'value_type', 'allow_traps', 'authtype', 'description', 'error',
'flags', 'follow_redirects', 'headers', 'history', 'http_proxy', 'inventory_link', 'ipmi_sensor', 'jmx_endpoint', 'logtimefmt', 'master_itemid', 'output_format',
'params', 'parameters', 'password', 'post_type', 'posts', 'privatekey', 'publickey', 'query_fields', 'request_method', 'retrieve_mode', 'snmp_oid', 'ssl_cert_file',
'ssl_key_file', 'ssl_key_password', 'state', 'status', 'status_codes', 'templateid', 'timeout', 'trapper_hosts', 'trends', 'units', 'username', 'valuemapid',
'verify_host', 'verify_peer', 'state', 'error']
triggers_output = ['triggerid', 'description', 'expression', 'event_name', 'opdata', 'comments', 'error', 'flags', 'priority', 'state', 'status', 'templateid',
'type', 'url', 'value', 'recovery_mode', 'recovery_expression', 'correlation_mode', 'correlation_tag', 'manual_close', 'lastchange']
history_output = ['itemid', 'lastclock', 'lastns', 'lastvalue']
insert_zbx_proxies_sql = 'INSERT INTO tmp_zbx_zbx_proxies (proxyid, proxy, name) VALUES (%s, %s, %s);'
insert_zbx_maintenances_sql = 'INSERT INTO tmp_zbx_zbx_maintenances (maintenanceid, name, maintenance_type, active_since, active_till) VALUES (%s, %s, %s, %s, %s);'
insert_zbx_hosts_sql = 'INSERT INTO tmp_zbx_zbx_hosts (hostid, proxy_hostid, host, status, ipmi_authtype, ipmi_privilege, ipmi_username, ipmi_password, \
maintenanceid, maintenance_status, maintenance_type, maintenance_from, name, flags, description, tls_connect, tls_accept, tls_issuer, tls_subject, lastaccess) \
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);'
insert_zbx_hstgrp_sql = 'INSERT INTO tmp_zbx_zbx_hstgrp (groupid, name, internal, flags) VALUES (%s, %s, %s, %s);'
insert_zbx_hosts_groups_sql = 'INSERT INTO tmp_zbx_zbx_hosts_groups (hostid, groupid) VALUES (%s, %s);'
insert_zbx_hosts_templates_sql = 'INSERT INTO tmp_zbx_zbx_hosts_templates (hostid, templateid) VALUES (%s, %s);'
insert_zbx_interface_sql = 'INSERT INTO tmp_zbx_zbx_interface (interfaceid, hostid, main, type, useip, ip, dns, port, available, error, errors_from, \
disable_until, version, bulk, community, securityname, securitylevel, authpassphrase, privpassphrase, authprotocol, privprotocol, contextname) \
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);'
insert_zbx_hostmacro_sql = 'INSERT INTO tmp_zbx_zbx_hostmacro (hostmacroid, hostid, macro, value, description, type) VALUES (%s, %s, %s, %s, %s, %s);'
insert_zbx_host_tag_sql = 'INSERT INTO tmp_zbx_zbx_host_tag (hostid, tag, value) VALUES (%s, %s, %s);'
insert_zbx_host_inventory_sql = 'INSERT INTO tmp_zbx_zbx_host_inventory (hostid, inventory_mode, {0}) VALUES (%s, %s, {1});'
insert_zbx_items_sql = 'INSERT INTO tmp_zbx_zbx_items (itemid, type, snmp_oid, hostid, name, key_, delay, history, trends, status, value_type, \
trapper_hosts, units, logtimefmt, templateid, valuemapid, params, ipmi_sensor, authtype, username, password, publickey, privatekey, flags, \
interfaceid, description, inventory_link, jmx_endpoint, master_itemid, timeout, url, query_fields, posts, status_codes, follow_redirects, \
post_type, http_proxy, headers, retrieve_mode, request_method, output_format, ssl_cert_file, ssl_key_file, ssl_key_password, verify_peer, \
verify_host, allow_traps, state, error) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, \
%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);'
insert_zbx_triggers_sql = 'INSERT INTO tmp_zbx_zbx_triggers (triggerid, hostid, expression, description, url, status, value, priority, lastchange, \
comments, error, templateid, type, state, flags, recovery_mode, recovery_expression, correlation_mode, correlation_tag, manual_close, opdata, \
event_name) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);'
insert_zbx_histories_sql = 'INSERT INTO {0} (itemid, clock, ns, value) VALUES (%s, %s, %s, %s);'
truncate_tmp_bigintid_sql = 'TRUNCATE TABLE tmp_bigintid;'
truncate_tmp_bigintid1_sql = 'TRUNCATE TABLE tmp_bigintid1;'
select_items_oldhistory_sql = 'SELECT itemid FROM {0} GROUP BY itemid HAVING COUNT(*)>{1};'
insert_items_oldhistory_sql = 'INSERT INTO tmp_bigintid (id) VALUES (%s);'
select_historyid_oldhistory_sql = 'SELECT historyid, itemid, clock, ns FROM {0} WHERE EXISTS (SELECT NULL FROM tmp_bigintid WHERE tmp_bigintid.id={0}.itemid) \
ORDER BY itemid, clock DESC, ns DESC;'
insert_historyid_oldhistory_sql = 'INSERT INTO tmp_bigintid1 (id) VALUES (%s);'
delete_oldhistory_sql = 'DELETE FROM {0} WHERE EXISTS (SELECT NULL FROM tmp_bigintid1 WHERE tmp_bigintid1.id={0}.historyid);'
zbx_histories = {0:{'table':'zbx_zbx_history', 'table_tmp':'tmp_zbx_zbx_history', 'value':'float'},
1:{'table':'zbx_zbx_history_str', 'table_tmp':'tmp_zbx_zbx_history_str', 'value':'str'},
2:{'table':'zbx_zbx_history_log', 'table_tmp':'tmp_zbx_zbx_history_log', 'value':'str'},
3:{'table':'zbx_zbx_history_uint', 'table_tmp':'tmp_zbx_zbx_history_uint', 'value':'int'},
4:{'table':'zbx_zbx_history_text', 'table_tmp':'tmp_zbx_zbx_history_text', 'value':'str'}}


def process_zabbix(hosts, items):
    for h in hosts:
        h['maintenanceid'] = None if h['maintenanceid']=='0' else h['maintenanceid']
        h['proxy_hostid'] = None if h['proxy_hostid']=='0' else h['proxy_hostid']
    for i in items:
        i['templateid'] = None if i['templateid']=='0' else i['templateid']
        i['interfaceid'] = None if i['interfaceid']=='0' else i['interfaceid']
        i['master_itemid'] = None if i['master_itemid']=='0' else i['master_itemid']
        if i['query_fields']:
            i['query_fields'] = json.dumps(i['query_fields'])
        else:
            i['query_fields'] = ''
        if i['headers']:
            i['headers'] = '/n'.join([k+': '+v for k,v in i['headers'].items()])
        else:
            i['headers'] = ''

def save_zabbix(db, log, proxies, maintenances, hosts, hstgrps, interfaces, items, histories):
    cur = db.cursor()
    vallist = [(int(r['proxyid']), r['host'], r['name']) for r in proxies]
    if vallist:
        cur.executemany(insert_zbx_proxies_sql, vallist)
        db.commit()
    vallist = [(int(r['maintenanceid']), r['name'], int(r['maintenance_type']), int(r['active_since']), int(r['active_till']))\
        for r in maintenances]
    if vallist:
        cur.executemany(insert_zbx_maintenances_sql, vallist)
        db.commit()
    vallist = [(int(r['hostid']), (None if r['proxy_hostid'] is None else int(r['proxy_hostid'])), r['host'], int(r['status']),\
         int(r['ipmi_authtype']), int(r['ipmi_privilege']), r['ipmi_username'], r['ipmi_password'],\
        (None if r['maintenanceid'] is None else int(r['maintenanceid'])), int(r['maintenance_status']), int(r['maintenance_type']),\
        int(r['maintenance_from']), r['name'], int(r['flags']), r['description'], int(r['tls_connect']),\
        int(r['tls_accept']), r['tls_issuer'], r['tls_subject'], int(r['lastaccess'])) for r in hosts]
    if vallist:
        cur.executemany(insert_zbx_hosts_sql, vallist)
        db.commit()
    vallist = [(int(r['groupid']), r['name'], int(r['internal']), int(r['flags'])) for r in hstgrps]
    if vallist:
        cur.executemany(insert_zbx_hstgrp_sql, vallist)
        db.commit()
    host_groups = []
    host_templates = []
    host_macros = []
    host_tags = []
    host_triggers = []
    inventory_fields = set()
    for host in hosts:
        hostid = int(host['hostid'])
        for group in host['groups']:
            host_groups.append((hostid, int(group['groupid'])))
        for template in host['parentTemplates']:
            host_templates.append((hostid, int(template['templateid'])))
        for macro in host['macros']:
            host_macros.append((int(macro['hostmacroid']), hostid, macro['macro'], macro.get('value', None), 
                macro['description'], int(macro['type'])))
        for tag in host['tags']:
            host_tags.append((hostid, tag['tag'], tag['value']))
        for field in host['inventory']:
            inventory_fields.add(field)
        for trigger in host['triggers']:
            host_triggers.append((int(trigger['triggerid']), hostid, trigger['expression'], trigger['description'], trigger['url'], 
                int(trigger['status']), int(trigger['value']), int(trigger['priority']), int(trigger['lastchange']), trigger['comments'], trigger['error'],
                int(trigger['templateid']), int(trigger['type']), int(trigger['state']), int(trigger['flags']), int(trigger['recovery_mode']),
                trigger['recovery_expression'], int(trigger['correlation_mode']), trigger['correlation_tag'], int(trigger['manual_close']),
                trigger['opdata'], trigger['event_name']))
    if host_groups:
        cur.executemany(insert_zbx_hosts_groups_sql, host_groups)
        db.commit()
    if host_templates:
        cur.executemany(insert_zbx_hosts_templates_sql, host_templates)
        db.commit()
    if host_macros:
        cur.executemany(insert_zbx_hostmacro_sql, host_macros)
        db.commit()
    if host_tags:
        cur.executemany(insert_zbx_host_tag_sql, host_tags)
        db.commit()
    if host_triggers:
        cur.executemany(insert_zbx_triggers_sql, host_triggers)
        db.commit()
    if inventory_fields:
        vallist = []
        for host in hosts:
            inventory = {f:'' for f in inventory_fields}
            if host['inventory']:
                for field, value in host['inventory'].items():
                    inventory[field] = value
                l = [int(host['hostid']), int(host['inventory_mode'])]
                l.extend(list(inventory.values()))
                vallist.append(tuple(l))
        sql = insert_zbx_host_inventory_sql.format(','.join(inventory_fields), ('%s, '*len(inventory_fields))[:-2])
        if vallist:
            cur.executemany(sql, vallist)
            db.commit()
    vallist = []
    for interface in interfaces:
        details = {'version':None, 'bulk':None, 'community':None, 'securityname':None, 'securitylevel':None, 'authpassphrase':None, 
            'privpassphrase':None, 'authprotocol':None, 'privprotocol':None, 'contextname':None}
        if interface['details']:
            for k,v in interface['details'].items():
                if v is not None:
                    if k in {'version', 'bulk', 'securitylevel', 'authprotocol', 'privprotocol'}:
                        details[k] = int(v)
                    else:
                       details[k] = v
        vallist.append((int(interface['interfaceid']), int(interface['hostid']), int(interface['main']), int(interface['type']), int(interface['useip']),
            interface['ip'], interface['dns'], interface['port'], int(interface['available']), interface['error'], int(interface['errors_from']),
            int(interface['disable_until']), details['version'], details['bulk'], details['community'], details['securityname'], details['securitylevel'],
            details['authpassphrase'], details['privpassphrase'], details['authprotocol'], details['privprotocol'], details['contextname']))
    if vallist:
        cur.executemany(insert_zbx_interface_sql, vallist)
        db.commit()
    vallist = [(int(r['itemid']), int(r['type']), r['snmp_oid'], int(r['hostid']), r['name'], r['key_'], r['delay'], r['history'], r['trends'], int(r['status']),
        int(r['value_type']), r['trapper_hosts'], r['units'], r['logtimefmt'], (None if r['templateid'] is None else int(r['templateid'])), int(r['valuemapid']),
        r['params'], r['ipmi_sensor'], int(r['authtype']), r['username'], r['password'], r['publickey'], r['privatekey'], int(r['flags']),
        (None if r['interfaceid'] is None else int(r['interfaceid'])), r['description'], int(r['inventory_link']), r['jmx_endpoint'],
        (None if r['master_itemid'] is None else int(r['master_itemid'])), r['timeout'], r['url'], r['query_fields'], r['posts'], r['status_codes'],
        int(r['follow_redirects']), int(r['post_type']), r['http_proxy'], r['headers'], int(r['retrieve_mode']), int(r['request_method']),
        int(r['output_format']), r['ssl_cert_file'], r['ssl_key_file'], r['ssl_key_password'], int(r['verify_peer']), int(r['verify_host']),
        int(r['allow_traps']), int(r['state']), r['error']) for r in items]
    if vallist:
        cur.executemany(insert_zbx_items_sql, vallist)
        db.commit()
    for hid, history in histories.items():
        vallist = []
        for r in history:
            if zbx_histories[hid]['value']=='int':
                v = int(r['lastvalue'])
            elif zbx_histories[hid]['value']=='float':
                v = float(r['lastvalue'])
            else:
                v = r['lastvalue']
            vallist.append((r['itemid'], r['lastclock'], r['lastns'], v))
        if vallist:
            cur.executemany(insert_zbx_histories_sql.format(zbx_histories[hid]['table_tmp']), vallist)
            db.commit()
    cur.close()

def get_history(zapi, items):
    histories = {hid:[] for hid in zbx_histories}
    itemids = {}
    for hid in histories:
        itemids[hid] = [r['itemid'] for r in items if int(r['value_type'])==hid]
    for hid, history in histories.items():
        pools = [itemids[hid][i:i + omni_config.zbx_item_pool_size] for i in range(0, len(itemids[hid]), omni_config.zbx_item_pool_size)]
        for pool in pools:
            history.extend(zapi.item.get(output=history_output, itemids=pool))
    return histories

def delete_old_history(db, log):
    cur = db.cursor()
    max_records = int(db.find_parameter('zbx_history_records', None))
    for hid, table in zbx_histories.items():
        cur.execute(truncate_tmp_bigintid_sql)
        db.commit()
        cur.execute(select_items_oldhistory_sql.format(table['table'], str(max_records)))
        vallist = [(r[0],) for r in cur.fetchall()]
        if vallist:
            cur.executemany(insert_items_oldhistory_sql, vallist)
            db.commit()
            cur.execute(select_historyid_oldhistory_sql.format(table['table']))
            vallist = []
            itemid = 0
            rec_count = 0
            for r in cur.fetchall():
                if r[1]!=itemid:
                    itemid = r[1]
                    rec_count = 1
                else:
                    rec_count += 1
                if rec_count>max_records:
                    vallist.append((r[0],))
            if vallist:
                cur.execute(truncate_tmp_bigintid1_sql)
                db.commit()
                cur.executemany(insert_historyid_oldhistory_sql.format(table['table']), vallist)
                db.commit()
                cur.execute(delete_oldhistory_sql.format(table['table']))
                db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        zapi = ZbxAPI(omni_config.zabbix_url, omni_unpwd.zbx_userpasstoken, program.log, mode='ro')
        proxies = zapi.proxy.get(output=proxies_output)
        maintenances = zapi.maintenance.get(output=maintenances_output)
        hstgrps = zapi.hostgroup.get(output=hstgrp_output)
        hosts = zapi.host.get(output=hosts_output, templated_hosts=1, selectGroups=1, selectParentTemplates=1, selectMacros=macros_output,
            selectTags='extend', selectInventory='extend', selectTriggers=triggers_output)
        interfaces = zapi.hostinterface.get()
        items = zapi.item.get(output=items_output)
        histories = get_history(zapi, items)
        process_zabbix(hosts, items)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_zbx_user, omni_unpwd.db_zbx_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=[1, 2])
        save_zabbix (omnidb, program.log, proxies, maintenances, hosts, hstgrps, interfaces, items, histories)
        omnidb.run_program_queries(stage=list(range(3,7)))
        delete_old_history(omnidb, program.log)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())
