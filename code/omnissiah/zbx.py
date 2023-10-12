import warnings
warnings.filterwarnings('ignore', message='Unverified HTTPS request')
import logging

from munch import Munch
from pyzabbix import ZabbixAPI
from .const import zbx_zabbix_timeout, zbx_update_zbx_omni_map_sql

class ZbxAPI(ZabbixAPI):
    def __init__(self, url, userpasstoken, log, mode='ro', tkn=None, timeout=zbx_zabbix_timeout):
        self.log = log
        token = tkn or userpasstoken[mode]['token']
        log = logging.getLogger('pyzabbix')
        log.propagate = False
        log.setLevel(logging.ERROR)
        super(ZbxAPI, self).__init__(url, timeout=timeout, detect_version=False)
        self.session.verify = False
        self.login(api_token=token)

    def prepare_interface(self, interface, zbx_hostid=None, zbx_interfaceid=None):
        zbxif = {'main':interface['main'], 'type':interface['type'], 'useip':interface['useip'], 'ip':interface['ip'], 'dns':interface['dns'], 'port':interface['port']}
        if zbx_hostid is not None:
            zbxif['hostid'] = zbx_hostid if zbx_hostid else interface['hostid']
        if zbx_interfaceid is not None:
            zbxif['interfaceid'] = zbx_interfaceid if zbx_interfaceid else interface['interfaceid']
        if zbxif['type']==2:
            zbxif['details'] = {'version':interface['version'], 'bulk':interface['bulk']}
            if interface['version']==3:
                zbxif['details'].update({'securityname':interface['securityname'], 'securitylevel':interface['securitylevel'],
                    'authpassphrase':interface['authpassphrase'], 'privpassphrase':interface['privpassphrase'], 'authprotocol':interface['authprotocol'],
                    'privprotocol':interface['privprotocol'], 'contextname':interface['contextname']})
            else:
                zbxif['details']['community'] = interface['community']
        return zbxif

    def prepare_hostmacro(self, hostmacro, zbx_hostid=None, zbx_hostmacroid=None):
        zbxhm = {'macro':hostmacro['macro'], 'value':hostmacro['value'], 'type':hostmacro['type'], 'description':hostmacro['description']}
        if zbx_hostid is not None:
            zbxhm['hostid'] = zbx_hostid if zbx_hostid else hostmacro['hostid']
        if zbx_hostmacroid is not None:
            zbxhm['hostmacroid'] = zbx_hostmacroid if zbx_hostmacroid else hostmacro['hostmacroid']
        return zbxhm

    def prepare_maintenance(self, maintenance, zbx_groupid, zbx_maintenanceid=None):
        zbxmaint = {'name':maintenance['name'], 'name':maintenance['name'], 'active_till':maintenance['active_till'], 'maintenance_type':maintenance['maintenance_type'],
            'groups':[{'groupid':zbx_groupid}], 'active_since':maintenance['active_since'], 'timeperiods':[{'period':86400, 'timeperiod_type':2}]}
        if zbx_maintenanceid is not None:
            zbxmaint['maintenanceid'] = zbx_maintenanceid if zbx_maintenanceid else maintenance['maintenanceid']
        return zbxmaint

    def prepare_hstgrp(self, hstgrp, zbx_groupid=None):
        zbxhstgrp = {'name':hstgrp['name']}
        if zbx_groupid is not None:
            zbxhstgrp['groupid'] = zbx_groupid if zbx_groupid else hstgrp['groupid']
        return zbxhstgrp

    def prepare_host(self, host, templates=None, groups=None, tags=None, inventory=None, interfaces=None, hostmacros=None, zbx_hostid=None):
        zbxhost = {'inventory_mode':inventory['inventory_mode'], 'host':host['host'], 'name':host['name'], 'status':host['status'], 'description':host['description'],
            'ipmi_authtype':host['ipmi_authtype'], 'ipmi_password':host['ipmi_password'], 'ipmi_privilege':host['ipmi_privilege'], 'ipmi_username':host['ipmi_username'],
            'tls_connect':host['tls_connect'], 'tls_accept':host['tls_accept'], 'tls_issuer':host['tls_issuer'], 'tls_subject':host['tls_subject']}
        zbxhost['proxy_hostid'] = host['proxy_hostid'] if host['proxy_hostid'] else 0
        if zbx_hostid is not None:
            zbxhost['hostid'] = zbx_hostid if zbx_hostid else host['hostid']
        if inventory:
            zbxhost['inventory_mode'] = inventory['inventory_mode']
        zbxgroups = [{'groupid':r['groupid']} for r in groups] if groups is not None else None
        zbxtags = [{'tag':r['tag'], 'value':r['value']} for r in tags] if tags is not None else None
        zbxtemplates = [{'templateid':r['templateid']} for r in templates] if templates is not None else None
        zbxinventory = {f:v for f, v in inventory.items() if f not in {'inventory_mode', 'hostid'} and v} if inventory is not None else None
        zbxinterfaces = [self.prepare_interface(r, zbx_hostid=zbx_hostid) for r in interfaces] if interfaces is not None else None
        zbxhostmacros = [self.prepare_hostmacro(r, zbx_hostid=zbx_hostid) for r in hostmacros] if hostmacros is not None else None
        if zbxgroups is not None:
            zbxhost['groups'] = zbxgroups
        if zbxtags is not None:
            zbxhost['tags'] = zbxtags
        if zbxtemplates is not None:
            zbxhost['templates'] = zbxtemplates
        if zbxinventory is not None:
            zbxhost['inventory'] = zbxinventory
        if zbxinterfaces is not None:
            zbxhost['interfaces'] = zbxinterfaces
        if zbxhostmacros is not None:
            zbxhost['macros'] = zbxhostmacros
        return zbxhost

    def hstgrp_create(self, hstgrp, ignore_error=False):
        result = None
        hstgrp_zabbix = self.prepare_hstgrp(hstgrp)
        if ignore_error:
            try:
                result = self.hostgroup.create(hstgrp_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.hostgroup.create(hstgrp_zabbix)
        if result:
            return result['groupids'][0]
        else:
            return result

    def host_create(self, host, templates, groups, tags, inventory, interfaces, ignore_error=False):
        result = None
        host_zabbix = self.prepare_host(host, templates=templates, groups=groups, tags=tags, inventory=inventory, interfaces=interfaces)
        if ignore_error:
            try:
                result = self.host.create(host_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.host.create(host_zabbix)
        if result:
            return result['hostids'][0]
        else:
            return result

    def interface_create(self, interface, zbx_hostid, ignore_error=False):
        result = None
        interface_zabbix = self.prepare_interface(interface, zbx_hostid=zbx_hostid)
        if ignore_error:
            try:
                result = self.hostinterface.create(interface_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.hostinterface.create(interface_zabbix)
        if result:
            return result['interfaceids'][0]
        else:
            return result

    def hostmacro_create(self, hostmacro, zbx_hostid, ignore_error=False):
        result = None
        hostmacro_zabbix = self.prepare_hostmacro(hostmacro, zbx_hostid=zbx_hostid)
        if ignore_error:
            try:
                result = self.usermacro.create(hostmacro_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.usermacro.create(hostmacro_zabbix)
        if result:
            return result['hostmacroids'][0]
        else:
            return result

    def maintenance_create(self, maintenance, zbx_groupid, ignore_error=False):
        result = None
        maintenance_zabbix = self.prepare_maintenance(maintenance, zbx_groupid)
        if ignore_error:
            try:
                result = self.maintenance.create(maintenance_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.maintenance.create(maintenance_zabbix)
        if result:
            return result['maintenanceids'][0]
        else:
            return result

    def trigger_delete(self, zbx_triggerid, ignore_error=False):
        if ignore_error:
            try:
                result = self.trigger.delete(zbx_triggerid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.trigger.delete(zbx_triggerid)
        if result:
            return result['triggerids'][0]
        else:
            return result

    def item_delete(self, zbx_itemid, ignore_error=False):
        if ignore_error:
            try:
                result = self.item.delete(zbx_itemid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.item.delete(zbx_itemid)
        if result:
            return result['itemids'][0]
        else:
            return result

    def hstgrp_delete(self, zbx_groupid, ignore_error=False):
        if ignore_error:
            try:
                result = self.hostgroup.delete(zbx_groupid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.hostgroup.delete(zbx_groupid)
        if result:
            return result['groupids'][0]
        else:
            return result

    def host_delete(self, zbx_hostid, ignore_error=False):
        if ignore_error:
            try:
                result = self.host.delete(zbx_hostid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.host.delete(zbx_hostid)
        if result:
            return result['hostids'][0]
        else:
            return result

    def interface_delete(self, zbx_interfaceid, ignore_error=False):
        if ignore_error:
            try:
                result = self.hostinterface.delete(zbx_interfaceid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.hostinterface.delete(zbx_interfaceid)
        if result:
            return result['interfaceids'][0]
        else:
            return result

    def hostmacro_delete(self, zbx_hostmacroid, ignore_error=False):
        if ignore_error:
            try:
                result = self.usermacro.delete(zbx_hostmacroid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.usermacro.delete(zbx_hostmacroid)
        if result:
            return result['hostmacroids'][0]
        else:
            return result

    def maintenance_delete(self, zbx_maintenanceid, ignore_error=False):
        if ignore_error:
            try:
                result = self.maintenance.delete(zbx_maintenanceid)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.maintenance.delete(zbx_maintenanceid)
        if result:
            return result['maintenanceids'][0]
        else:
            return result

    def hstgrp_update(self, hstgrp, zbx_groupid, ignore_error=False):
        hstgrp_zabbix = self.prepare_hstgrp(hstgrp, zbx_groupid=zbx_groupid)
        if ignore_error:
            try:
                result = self.hostgroup.update(hstgrp_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.hostgroup.update(hstgrp_zabbix)
        if result:
            return result['groupids'][0]
        else:
            return result

    def host_update(self, host, zbx_hostid, templates, zbx_templates, groups, tags, inventory, ignore_error=False):
        host_zabbix = self.prepare_host(host, templates=templates, groups=groups, tags=tags, inventory=inventory, zbx_hostid=zbx_hostid)
        templateset = {r['templateid'] for r in host_zabbix['templates']}
        host_zabbix['templates_clear'] = [{'templateid':r['templateid']} for r in zbx_templates if r['templateid'] not in templateset]
        if ignore_error:
            try:
                result = self.host.update(host_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.host.update(host_zabbix)
        if result:
            return result['hostids'][0]
        else:
            return result

    def interface_update(self, interface, zbx_hostid, zbx_interfaceid, ignore_error=False):
        interface_zabbix = self.prepare_inerface(interface, zbx_hostid=zbx_hostid, zbx_interfaceid=zbx_interfaceid)
        if ignore_error:
            try:
                result = self.hostinterface.update(interface_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.hostinterface.update(interface_zabbix)
        if result:
            return result['interfaceids'][0]
        else:
            return result

    def hostmacro_update(self, hostmacro, zbx_hostmacroid, ignore_error=False):
        hostmacro_zabbix = self.prepare_hostmacro(hostmacro, zbx_hostmacroid=zbx_hostmacroid)
        if ignore_error:
            try:
                result = self.usermacro.update(hostmacro_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.usermacro.update(hostmacro_zabbix)
        if result:
            return result['hostmacroids'][0]
        else:
            return result

    def maintenance_update(self, maintenance, zbx_groupid, zbx_maintenanceid, ignore_error=False):
        maintenance_zabbix = self.prepare_maintenance(maintenance, zbx_groupid, zbx_maintenanceid=zbx_maintenanceid)
        if ignore_error:
            try:
                result = self.maintenance.update(maintenance_zabbix)
            except:
                self.log.exception('Fatal error')
        else:
            result = self.maintenance.update(maintenance_zabbix)
        if result:
            return result['maintenanceids'][0]
        else:
            return result


class DBOmniZbx():
    def __init__(self, refmap, idmaps, wrong_records, omni_tables, zbx_tables):
        self.refmap = refmap
        self.idmaps = idmaps
        self.wrong_records = wrong_records
        self.omni_tables = omni_tables
        self.zbx_tables = zbx_tables

        self.maintenances_typeid = [i for i, t in refmap.items() if t['omni_table']=='zbx_omni_maintenances'][0]
        self.hstgrp_typeid = [i for i, t in refmap.items() if t['omni_table']=='zbx_omni_hstgrp'][0]
        self.hosts_typeid = [i for i, t in refmap.items() if t['omni_table']=='zbx_omni_hosts'][0]
        self.interface_typeid = [i for i, t in refmap.items() if t['omni_table']=='zbx_omni_interface'][0]
        self.hostmacro_typeid = [i for i, t in refmap.items() if t['omni_table']=='zbx_omni_hostmacro'][0]
        self.map_typeids = {self.maintenances_typeid:'maintenances', self.hstgrp_typeid:'hstgrp', self.hosts_typeid:'hosts',
            self.interface_typeid:'interface', self.hostmacro_typeid:'hostmacro'}
        maps = {}
        for typeid, table in self.map_typeids.items():
            maps[table] = {'omni':None, 'zbx':None}
        self.maps = Munch.fromDict(maps)
        for typeid, table in self.map_typeids.items():
            self.maps[table]['omni'] = self.idmaps['typeid'][typeid]['omni']
            self.maps[table]['zbx'] = self.idmaps['typeid'][typeid]['zbx']
        tables = {} 
        for table in self.zbx_tables:
            tables[table]={'zbx':None}
            if table in self.omni_tables:
                tables[table]['omni'] = None
        self.tables = Munch.fromDict(tables)
        for table in self.zbx_tables:
            self.tables[table]['zbx'] = self.zbx_tables[table]['table']
            if table in self.omni_tables:
                self.tables[table]['omni'] = self.omni_tables[table]['table']
        keys = {}
        for table in self.zbx_tables:
            keys[table] = {'zbx':None}
            if table in self.omni_tables:
                keys[table]['omni'] = None
        self.keys = Munch.fromDict(keys)
        for table in self.zbx_tables:
            self.keys[table]['zbx'] = {}
            for key in self.zbx_tables[table]['keys']:
                self.keys[table]['zbx'][key] = self.zbx_tables[table]['keys'][key]
            if table in self.omni_tables:
                self.keys[table]['omni'] = {}
                for key in self.omni_tables[table]['keys']:
                    self.keys[table]['omni'][key] = self.omni_tables[table]['keys'][key]

    def update_zbx_omni_map(self, db, cur, record, log, ignore_error=True):
        omniid = 'NULL' if record['omniid'] is None else str(record['omniid'])
        zbxid = 'NULL' if record['zbxid'] is None else str(record['zbxid'])
        if ignore_error:
            try:
                cur.execute(zbx_update_zbx_omni_map_sql.format(omniid, zbxid, str(record['mapid'])))
                db.commit()
            except:
                log.exception('Fatal error')
        else:
            cur.execute(zbx_update_zbx_omni_map_sql.format(omniid, zbxid, str(record['mapid'])))
            db.commit()
