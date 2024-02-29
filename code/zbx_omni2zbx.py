#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.zbx import ZbxAPI, DBOmniZbx



select_ref_zbx_omni_map_sql = 'SELECT mapid, omni_table, omni_field, zbx_table, zbx_field FROM ref_zbx_omni_map;'
select_zbx_omni_map_sql = 'SELECT mapid, typeid, omniid, zbxid FROM zbx_omni_map;'
wrong_records_queries = {'delete':{'triggers':["SELECT zbx_zbx_triggers.triggerid FROM zbx_zbx_triggers INNER JOIN zbx_omni_map ON \
zbx_zbx_triggers.hostid=zbx_omni_map.zbxid INNER JOIN ref_zbx_omni_map ON zbx_omni_map.typeid=ref_zbx_omni_map.mapid WHERE \
ref_zbx_omni_map.zbx_table='zbx_zbx_hosts' AND (zbx_zbx_triggers.templateid IS NULL OR zbx_zbx_triggers.templateid=0);"],
'items':["SELECT zbx_zbx_items.itemid FROM zbx_zbx_items INNER JOIN zbx_omni_map ON zbx_zbx_items.hostid=zbx_omni_map.zbxid \
INNER JOIN ref_zbx_omni_map ON zbx_omni_map.typeid=ref_zbx_omni_map.mapid WHERE ref_zbx_omni_map.zbx_table='zbx_zbx_hosts' AND \
(zbx_zbx_items.templateid IS NULL OR zbx_zbx_items.templateid=0);"]}}
src_tables = {'proxies':{'omni':None, 'zbx':'zbx_zbx_proxies', 'keys':{'proxyid':True}},
'maintenances':{'omni':'zbx_omni_maintenances', 'zbx':'zbx_zbx_maintenances', 'keys':{'maintenanceid':True}},
'hosts':{'omni':'zbx_omni_hosts', 'zbx':'zbx_zbx_hosts', 'keys':{'hostid':True}},
'hstgrp':{'omni':'zbx_omni_hstgrp', 'zbx':'zbx_zbx_hstgrp', 'keys':{'groupid':True, 'name':True}},
'hosts_templates':{'omni':'zbx_omni_hosts_templates', 'zbx':'zbx_zbx_hosts_templates', 'keys':{'hosttemplateid':True, 'hostid':False}},
'hosts_groups':{'omni':'zbx_omni_hosts_groups', 'zbx':'zbx_zbx_hosts_groups', 'keys':{'hostgroupid':True, 'hostid':False}},
'interface':{'omni':'zbx_omni_interface', 'zbx':'zbx_zbx_interface', 'keys':{'interfaceid':True, 'hostid':False}},
'hostmacro':{'omni':'zbx_omni_hostmacro', 'zbx':'zbx_zbx_hostmacro', 'keys':{'hostmacroid':True, 'hostid':False}},
'host_tag':{'omni':'zbx_omni_host_tag', 'zbx':'zbx_zbx_host_tag', 'keys':{'hosttagid':True, 'hostid':False}},
'host_inventory':{'omni':'zbx_omni_host_inventory', 'zbx':'zbx_zbx_host_inventory', 'keys':{'hostid':True}}}


def load_table_with_names(db, sql, log):
    result = []
    cur = db.cursor()
    cur.execute(sql)
    names = {}
    i = 0
    for d in cur.description:
        names[i] = d[0]
        i += 1
    for r in cur.fetchall():
        result.append({n:r[i] for i, n in names.items()})
    cur.close()
    return result

def build_keys(table, keys):
    result = {k:{} for k in keys}
    for r in table:
        for k, unique in keys.items():
            if unique:
                result[k][r[k]] = r
            else:
                if r[k] not in result[k]:
                    result[k][r[k]] = []
                result[k][r[k]].append(r)
    return result

def load_dbdata(db, log):
    cur = db.cursor()
    cur.execute(select_ref_zbx_omni_map_sql)
    refmap = {r[0]:{'mapid':r[0], 'omni_table':r[1], 'omni_field':r[2], 'zbx_table':r[3], 'zbx_field':r[4]} for r in cur.fetchall()}
    cur.execute(select_zbx_omni_map_sql)
    idmaps = {'mapid':{}, 'typeid':{}}
    for typeid in refmap:
        idmaps['typeid'][typeid] = {'omni':{}, 'zbx':{}}
    for r in cur.fetchall():
        v = {'mapid':r[0], 'typeid':r[1], 'omniid':r[2], 'zbxid':r[3]}
        idmaps['mapid'][v['mapid']] = v
        idmaps['typeid'][v['typeid']]['omni'][v['omniid']] = v
        idmaps['typeid'][v['typeid']]['zbx'][v['zbxid']] = v
    wrong_records = {}
    for action, entities in wrong_records_queries.items():
        wrong_records[action] = {}
        for entity, queries in entities.items():
            wrong_records[action][entity] = set()
            for query in queries:
                cur.execute(query)
                wrong_records[action][entity] = wrong_records[action][entity] | set([r[0] for r in cur.fetchall()])
    omni_tables = {}
    zbx_tables = {}
    for table, source in src_tables.items():
        omni_tables[table] = {'table':[], 'keys':{}}
        zbx_tables[table] = {'table':[], 'keys':{}}
        if source['omni']:
            omni_tables[table]['table'] = load_table_with_names(db, 'SELECT * FROM {0};'.format(source['omni']), log)
        if source['zbx']:
            zbx_tables[table]['table'] = load_table_with_names(db, 'SELECT * FROM {0};'.format(source['zbx']), log)
        omni_tables[table]['keys'] = build_keys(omni_tables[table]['table'], source['keys'])
        zbx_tables[table]['keys'] = build_keys(zbx_tables[table]['table'], source['keys'])
    cur.close()
    return DBOmniZbx(refmap, idmaps, wrong_records, omni_tables, zbx_tables)

def fix_wrong_records (zapi, db, wrong_records, log):
    for action, entities in wrong_records.items():
        for entity, idset in entities.items():
            for entityid in idset:
                if action=='delete':
                    if entity=='triggers':
                        zapi.trigger_delete(entityid, ignore_error=True)
                    elif entity=='items':
                        zapi.item_delete(entityid, ignore_error=True)

def build_create_delete_actions(omni_table, zbx_table, entity, idfield, omni_map, zbx_map):
    actions = []
    for record in zbx_table:
        zbxid = record[idfield]
        if zbxid in zbx_map:
            if zbx_map[zbxid]['omniid'] is None:
                actions.append({'action':'delete', 'entity':entity, 'map':zbx_map[zbxid]})
    for record in omni_table:
        omniid = record[idfield]
        if omniid in omni_map:
            if omni_map[omniid]['zbxid'] is None:
                actions.append({'action':'create', 'entity':entity, 'map':omni_map[omniid]})
    return actions

def compare_maintenances(omni_record, zbx_record, dbdata):
    return omni_record['name']==zbx_record['name'] and omni_record['maintenance_type']==zbx_record['maintenance_type'] and \
        omni_record['active_since']==zbx_record['active_since'] and omni_record['active_till']==zbx_record['active_till']

def compare_hstgrp(omni_record, zbx_record, dbdata):
    return omni_record['name']==zbx_record['name']

def compare_hosts(omni_record, zbx_record, dbdata):
    isequal = omni_record['proxy_hostid']==zbx_record['proxy_hostid'] and omni_record['host']==zbx_record['host'] and \
    omni_record['status']==zbx_record['status'] and omni_record['name']==zbx_record['name'] and omni_record['description']==zbx_record['description'] and \
    omni_record['ipmi_authtype']==zbx_record['ipmi_authtype'] and omni_record['ipmi_privilege']==zbx_record['ipmi_privilege'] and \
    omni_record['ipmi_username']==zbx_record['ipmi_username'] and omni_record['ipmi_password']==zbx_record['ipmi_password'] and \
    omni_record['tls_connect']==zbx_record['tls_connect'] and omni_record['tls_accept']==zbx_record['tls_accept']
    if not isequal:
        return False
    zbx_hostid = zbx_record['hostid']
    omni_hostid = omni_record['hostid']
    zbx_inventory = dbdata.keys.host_inventory.zbx['hostid'].get(zbx_hostid, None)
    omni_inventory = dbdata.keys.host_inventory.omni['hostid'].get(omni_hostid, None)
    if (zbx_inventory is None and omni_inventory is not None) or (zbx_inventory is not None and omni_inventory is None):
        return False
    if zbx_inventory and omni_inventory:
        if omni_inventory['inventory_mode']!=zbx_inventory['inventory_mode']:
            return False
        for field, zbx_value in zbx_inventory.items():
            if field!='hostid' and field!='inventory_mode':
                omni_value = omni_inventory[field]
                if omni_value!=zbx_value and omni_value:
                    return False
    zbx_tags = dbdata.keys.host_tag.zbx['hostid'].get(zbx_hostid, [])
    omni_tags = dbdata.keys.host_tag.omni['hostid'].get(omni_hostid, [])
    zbx_tags_dict = {}
    for tag in zbx_tags:
        if tag['tag'] not in zbx_tags_dict:
            zbx_tags_dict[tag['tag']] = []
        zbx_tags_dict[tag['tag']].append(tag['value'])
    for tag in omni_tags:
        if tag['tag'] not in zbx_tags_dict:
            return False
        if len(zbx_tags_dict[tag['tag']])>1:
            return False
        if tag['value']!=zbx_tags_dict[tag['tag']][0]:
            return False
    zbx_groups = dbdata.keys.hosts_groups.zbx['hostid'].get(zbx_hostid, [])
    zbx_groupids = {r['groupid'] for r in zbx_groups}
    omni_groups = dbdata.keys.hosts_groups.omni['hostid'].get(omni_hostid, [])
    omni_groupids = set()
    for group in omni_groups:
        rmap = dbdata.maps.hstgrp.omni.get(group['groupid'], None)
        if rmap is not None:
            if rmap['zbxid'] is not None:
                 omni_groupids.add(rmap['zbxid'])
    if not (omni_groupids==zbx_groupids):
        return False
    zbx_templates = dbdata.keys.hosts_templates.zbx['hostid'].get(zbx_hostid, [])
    zbx_templates = {r['templateid'] for r in zbx_templates}
    omni_templates = dbdata.keys.hosts_templates.omni['hostid'].get(omni_hostid, [])
    omni_templates = {r['templateid'] for r in omni_templates}
    if not (zbx_templates==omni_templates):
        return False
    return True

def compare_interface(omni_record, zbx_record, dbdata):
    rmap = dbdata.maps.hosts.zbx.get(zbx_record['hostid'], None)
    if rmap is None:
        return None
    hostid = rmap['omniid'] if rmap['omniid'] is not None else 0
    if hostid != omni_record['hostid']:
        return False
    isequal = omni_record['main']==zbx_record['main'] and omni_record['type']==zbx_record['type'] and omni_record['useip']==zbx_record['useip'] and \
        omni_record['ip']==zbx_record['ip'] and omni_record['dns']==zbx_record['dns'] and omni_record['port']==zbx_record['port']
    if isequal and omni_record['type']==2:
        isequal = omni_record['version']==zbx_record['version'] and omni_record['bulk']==zbx_record['bulk']
        if isequal and omni_record['version']==3:
            isequal = isequal and omni_record['securityname']==zbx_record['securityname'] and omni_record['securitylevel']==zbx_record['securitylevel'] and \
                omni_record['authpassphrase']==zbx_record['authpassphrase'] and omni_record['privpassphrase']==zbx_record['privpassphrase'] and \
                omni_record['authprotocol']==zbx_record['authprotocol'] and omni_record['privprotocol']==zbx_record['privprotocol'] and \
                omni_record['contextname']==zbx_record['contextname']
        elif isequal:
            isequal = isequal and omni_record['community']==zbx_record['community']
    return isequal

def compare_hostmacro(omni_record, zbx_record, dbdata):
    rmap = dbdata.maps.hosts.zbx.get(zbx_record['hostid'], None)
    if rmap is None:
        return None
    hostid = rmap['omniid'] if rmap['omniid'] is not None else 0
    if hostid != omni_record['hostid']:
        return False
    isequal = omni_record['macro']==zbx_record['macro'] and omni_record['value']==zbx_record['value'] and omni_record['type']==zbx_record['type'] and \
        omni_record['description']==zbx_record['description']
    return isequal

def build_update_actions(zbx_map, omni_table, zbx_table, entity, dbdata, compare_function):
    actions = []
    for zbxid, rmap in zbx_map.items():
        omniid = rmap['omniid']
        if omniid:
            omni_record = omni_table.get(omniid, None)
            zbx_record = zbx_table.get(zbxid, None)
            if omni_record and zbx_record:
                compare = compare_function(omni_record, zbx_record, dbdata)
                if compare is not None and not compare:
                    actions.append({'action':'update', 'entity':entity, 'map':rmap})
    return actions

def build_actions(dbdata):
    actions = []
    actions.extend(build_create_delete_actions(dbdata.tables.hstgrp.omni, dbdata.tables.hstgrp.zbx,
        'hstgrp', 'groupid', dbdata.maps.hstgrp.omni, dbdata.maps.hstgrp.zbx))
    actions.extend(build_create_delete_actions(dbdata.tables.maintenances.omni, dbdata.tables.maintenances.zbx,
        'maintenances', 'maintenanceid', dbdata.maps.maintenances.omni, dbdata.maps.maintenances.zbx))
    host_actions = build_create_delete_actions(dbdata.tables.hosts.omni, dbdata.tables.hosts.zbx,
        'hosts', 'hostid', dbdata.maps.hosts.omni, dbdata.maps.hosts.zbx)
    interface_actions = build_create_delete_actions(dbdata.tables.interface.omni, dbdata.tables.interface.zbx,
        'interface', 'interfaceid', dbdata.maps.interface.omni, dbdata.maps.interface.zbx)
    hostmacro_actions = build_create_delete_actions(dbdata.tables.hostmacro.omni, dbdata.tables.hostmacro.zbx,
        'hostmacro', 'hostmacroid', dbdata.maps.hostmacro.omni, dbdata.maps.hostmacro.zbx)

    omni_interface_set = set()
    zbx_interface_set = set()
    omni_hostmacro_set = set()
    zbx_hostmacro_set = set()
    for action in host_actions:
        omniid = action['map']['omniid']
        zbxid = action['map']['zbxid']
        actions.append(action)
        if action['action']=='delete':
            interfaces = dbdata.keys.interface.zbx['hostid'].get(zbxid, [])
            zbx_interface_set = zbx_interface_set | set(i['interfaceid'] for i in interfaces)
            hostmacros = dbdata.keys.hostmacro.zbx['hostid'].get(zbxid, [])
            zbx_hostmacro_set = zbx_hostmacro_set | set(hm['hostmacroid'] for hm in hostmacros)
        elif action['action']=='create':
            ifs = dbdata.keys.interface.omni['hostid'].get(omniid, [])
            interfaces = [i for i in ifs if i['main']==1]
            interfaces.extend([i for i in ifs if i['main']==0])
            action['interfaces'] = []
            for interface in interfaces:
                interfaceid = interface['interfaceid']
                if interfaceid in dbdata.maps.interface.omni:
                    if dbdata.maps.interface.omni[interfaceid]['zbxid'] is None:
                        action['interfaces'].append(interface)
                    else:
                        actions.append({'action':'update', 'entity':'interface', 'map':dbdata.maps.interface.omni[interfaceid]})
                omni_interface_set.add(interfaceid)
            hostmacros = dbdata.keys.hostmacro.omni['hostid'].get(omniid, [])
            for hostmacro in hostmacros:
                hostmacroid = hostmacro['hostmacroid']
                if hostmacroid in dbdata.maps.hostmacro.omni:
                    if dbdata.maps.hostmacro.omni[hostmacroid]['zbxid'] is None:
                        hmaction = 'create'
                    else:
                        hmaction = 'update'
                    actions.append({'action':hmaction, 'entity':'hostmacro', 'map':dbdata.maps.hostmacro.omni[hostmacroid]})
                omni_hostmacro_set.add(hostmacroid)

    delete_actions = [a for a in interface_actions if a['action']=='delete']
    create_actions = [a for a in interface_actions if a['action']=='create']
    main_actions = []
    notmain_actions = []
    for action in delete_actions:
        zbxid = action['map']['zbxid']
        if zbxid not in zbx_interface_set:
            interface = dbdata.keys.interface.zbx['interfaceid'][zbxid]
            if interface['main']==1:
                main_actions.append(action)
            else:
                notmain_actions.append(action)
    actions.extend(notmain_actions)
    actions.extend(main_actions)
    main_actions = []
    notmain_actions = []
    for action in create_actions:
        omniid = action['map']['omniid']
        if omniid not in omni_interface_set:
            interface = dbdata.keys.interface.omni['interfaceid'][omniid]
            if interface['main']==1:
                main_actions.append(action)
            else:
                notmain_actions.append(action)
    actions.extend(main_actions)
    actions.extend(notmain_actions)

    for action in hostmacro_actions:
        omniid = action['map']['omniid']
        zbxid = action['map']['zbxid']
        if action['action']=='delete':
            if zbxid not in zbx_hostmacro_set:
                actions.append(action)
        elif action['action']=='create':
            if omniid not in omni_hostmacro_set:
                actions.append(action)

    actions.extend( build_update_actions(dbdata.maps.hstgrp.zbx, dbdata.keys.hstgrp.omni['groupid'],
        dbdata.keys.hstgrp.zbx['groupid'], 'hstgrp', dbdata, compare_hstgrp))
    actions.extend(build_update_actions(dbdata.maps.maintenances.zbx, dbdata.keys.maintenances.omni['maintenanceid'],
        dbdata.keys.maintenances.zbx['maintenanceid'], 'maintenances', dbdata, compare_maintenances))
    host_actions = build_update_actions(dbdata.maps.hosts.zbx, dbdata.keys.hosts.omni['hostid'],
        dbdata.keys.hosts.zbx['hostid'], 'hosts', dbdata, compare_hosts)
    interface_actions = build_update_actions(dbdata.maps.interface.zbx, dbdata.keys.interface.omni['interfaceid'],
        dbdata.keys.interface.zbx['interfaceid'], 'interface', dbdata, compare_interface)
    hostmacro_actions = build_update_actions(dbdata.maps.hostmacro.zbx, dbdata.keys.hostmacro.omni['hostmacroid'],
        dbdata.keys.hostmacro.zbx['hostmacroid'], 'hostmacro', dbdata, compare_hostmacro)

    zbx_interface_set = set()
    zbx_hostmacro_set = set()
    zbx_updated_interfaces = {a['map']['zbxid'] for a in interface_actions}
    zbx_updated_hostmacros = {a['map']['zbxid'] for a in hostmacro_actions}
    for action in host_actions:
        omniid = action['map']['omniid']
        zbxid = action['map']['zbxid']
        actions.append(action)
        interfaces = dbdata.keys.interface.zbx['hostid'].get(zbxid, [])
        zbx_interface_set = zbx_interface_set | set(i['interfaceid'] for i in interfaces)
        hostmacros = dbdata.keys.hostmacro.zbx['hostid'].get(zbxid, [])
        zbx_hostmacro_set = zbx_hostmacro_set | set(hm['hostmacroid'] for hm in hostmacros)
        for interface in interfaces:
            if interface['interfaceid'] in zbx_updated_interfaces:
                actions.append({'action':'update', 'entity':'interface', 'map':dbdata.maps.interface.zbx[interface['interfaceid']]})
        for hostmacro in hostmacros:
            if hostmacro['hostmacroid'] in zbx_updated_hostmacros:
                actions.append({'action':'update', 'entity':'hostmacro', 'map':dbdata.maps.hostmacro.zbx[hostmacro['hostmacroid']]})
    actions.extend([a for a in interface_actions if a['map']['zbxid'] not in zbx_interface_set])
    actions.extend([a for a in hostmacro_actions if a['map']['zbxid'] not in zbx_hostmacro_set])
    return(actions)

def run_actions(zapi, db, actions, dbdata, log):
    cur = db.cursor()
    maintenance_groupid = dbdata.keys.hstgrp.zbx['name'].get(omni_config.zbx_omnissiah_maintenance_group, None)
    maintenance_groupid = None if maintenance_groupid is None else maintenance_groupid['groupid']
    for action in actions:
        result = None
        map_record = action['map']
        entity = action['entity']
        omniid = map_record['omniid']
        zbxid = map_record['zbxid']
        omni_record = None
        zbx_record = None
        if omniid is not None:
            key = next(iter(dbdata.omni_tables[entity]['keys']))
            omni_record = dbdata.omni_tables[entity]['keys'][key][omniid]
        if zbxid is not None:
            key = next(iter(dbdata.zbx_tables[entity]['keys']))
            zbx_record = dbdata.zbx_tables[entity]['keys'][key][zbxid]
        if action['action']=='create' and omniid:
            if entity=='hstgrp':
                result = zapi.hstgrp_create(omni_record, ignore_error=True)
            elif entity=='hosts':
                templates = dbdata.keys.hosts_templates.omni['hostid'].get(omniid, [])
                groups = []
                for hostgroup in dbdata.keys.hosts_groups.omni['hostid'].get(omniid, []):
                    rmap = dbdata.maps.hstgrp.omni.get(hostgroup['groupid'], None)
                    if rmap:
                        if rmap['zbxid']:
                            groups.append({'groupid':rmap['zbxid']})
                tags = dbdata.keys.host_tag.omni['hostid'].get(omniid, [])
                inventory = dbdata.keys.host_inventory.omni['hostid'].get(omniid, {})
                interfaces = action['interfaces']
                result = zapi.host_create(omni_record, templates, groups, tags, inventory, interfaces, ignore_error=True)
            elif entity=='interface':
                zbx_hostid = dbdata.maps.hosts.omni.get(omni_record['hostid'], None)
                zbx_hostid = None if zbx_hostid is None else zbx_hostid['zbxid']
                if zbx_hostid:
                    result = zapi.interface_create(omni_record, zbx_hostid, ignore_error=True)
            elif entity=='hostmacro':
                zbx_hostid = dbdata.maps.hosts.omni.get(omni_record['hostid'], None)
                zbx_hostid = None if zbx_hostid is None else zbx_hostid['zbxid']
                if zbx_hostid:
                    result = zapi.hostmacro_create(omni_record, zbx_hostid, ignore_error=True)
            elif entity=='maintenances':
                zbx_groupid = dbdata.keys.hstgrp.zbx['name'].get(omni_config.zbx_omnissiah_maintenance_group, None)
                if maintenance_groupid:
                    result = zapi.maintenance_create(omni_record, maintenance_groupid, ignore_error=True)
            if result:
                map_record['zbxid'] = int(result)
                dbdata.update_zbx_omni_map(db, cur, map_record, log, ignore_error=True)
        elif action['action']=='delete' and zbxid:
            if entity=='hstgrp':
                result = zapi.hstgrp_delete(zbxid, ignore_error=True)
            elif entity=='hosts':
                result = zapi.host_delete(zbxid, ignore_error=True)
            elif entity=='interface':
                result = zapi.interface_delete(zbxid, ignore_error=True)
            elif entity=='hostmacro':
                result = zapi.hostmacro_delete(zbxid, ignore_error=True)
            elif entity=='maintenances':
                result = zapi.maintenance_delete(zbxid, ignore_error=True)
            if result:
                map_record['zbxid'] = None
                dbdata.update_zbx_omni_map(db, cur, map_record, log, ignore_error=True)
        elif action['action']=='update' and omniid and zbxid:
            if entity=='hstgrp':
                zapi.hstgrp_update(omni_record, zbxid, ignore_error=True)
            elif entity=='hosts':
                templates = dbdata.keys.hosts_templates.omni['hostid'].get(omniid, [])
                zbx_templates = dbdata.keys.hosts_templates.zbx['hostid'].get(zbxid, [])
                groups = []
                for hostgroup in dbdata.keys.hosts_groups.omni['hostid'].get(omniid, []):
                    rmap = dbdata.maps.hstgrp.omni.get(hostgroup['groupid'], None)
                    if rmap:
                        if rmap['zbxid']:
                            group = dbdata.keys.hstgrp.zbx['groupid'].get(rmap['zbxid'], None)
                            if group:
                                groups.append(group)
                tags = dbdata.keys.host_tag.omni['hostid'].get(omniid, [])
                inventory = dbdata.keys.host_inventory.omni['hostid'].get(omniid, {})
                zapi.host_update(omni_record, zbxid, templates, zbx_templates, groups, tags, inventory, ignore_error=True)
            elif entity=='interface':
                zbx_hostid = dbdata.maps.hosts.omni.get(omni_record['hostid'], None)
                zbx_hostid = None if zbx_hostid is None else zbx_hostid['zbxid']
                if zbx_hostid:
                    zapi.interface_update(omni_record, zbx_hostid, zbxid, ignore_error=True)
            elif entity=='hostmacro':
                zapi.hostmacro_update(omni_record, zbxid, ignore_error=True)
            elif entity=='maintenances':
                if maintenance_groupid:
                    zapi.maintenance_update(omni_record, maintenance_groupid, zbxid, ignore_error=True)
    cur.close()
    if maintenance_groupid:
        for omniid, map_record in dbdata.maps.maintenances.omni.items():
            zbxid = map_record['zbxid']
            if zbxid:
                maintenance_hosts = {r['hostid'] for r in dbdata.tables.hosts.omni if r['maintenance_status']==1 and r['maintenanceid']==omniid}
                maintenance_hosts = [dbdata.maps.hosts.omni[hid]['zbxid'] for hid in maintenance_hosts if dbdata.maps.hosts.omni[hid]['zbxid'] is not None]
                try:
                    zapi.maintenance.update(maintenanceid=zbxid, groupids=[maintenance_groupid], hostids=maintenance_hosts)
                except:
                    log.exception('Fatal error')

def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_zbx_user, omni_unpwd.db_zbx_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        dbdata = load_dbdata(omnidb, program.log)
        zapi = ZbxAPI(omni_config.zabbix_url, omni_unpwd.zbx_userpasstoken, program.log, mode='rw')
        fix_wrong_records (zapi, omnidb, dbdata.wrong_records, program.log)
        actions = build_actions(dbdata)
        run_actions(zapi, omnidb, actions, dbdata, program.log)
        omnidb.run_program_queries(stage=2)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())
