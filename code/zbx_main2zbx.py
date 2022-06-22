#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram

select_ref_zbx_group_sql = 'SELECT groupid, name, prefix, table_name, field_name, id_field, parent_field FROM ref_zbx_group;'
insert_tmp_zbx_omni_hstgrp_sql = 'INSERT INTO tmp_zbx_omni_hstgrp (name, internal, flags, typeid, srcid) VALUES (%s, 0, 0, %s, %s);'
select_group_source_sql = "SELECT {0}, {1} FROM {2} WHERE {0}<>0 AND NOT ('{2}'='ref_zbx_group' AND {0}=6);"
select_group_source_root_sql = 'SELECT {0}, {1} FROM {2} WHERE {0}<>0 AND ({3} IS NULL OR {3}=0);'
select_group_source_parent_sql = 'SELECT {0}, {1} FROM {2} WHERE {0}<>0 AND {3}={4};'
insert_tmp_zbx_omni_host_tag_sql = 'INSERT INTO tmp_zbx_omni_host_tag (hostid, tag, value) VALUES (%s, %s, %s);'
select_zbx_omni_host_inventory_sql = 'SELECT hostid, inventory_mode, type, type_full, name, alias, os, os_full, os_short, serialno_a, serialno_b, \
tag, asset_tag, macaddress_a, macaddress_b, hardware, hardware_full, software, software_full, software_app_a, software_app_b, software_app_c, \
software_app_d, software_app_e, contact, location, location_lat, location_lon, notes, chassis, model, hw_arch, vendor, contract_number, \
installer_name, deployment_status, url_a, url_b, url_c, host_networks, host_netmask, host_router, oob_ip, oob_netmask, oob_router, \
date_hw_purchase, date_hw_install, date_hw_expiry, date_hw_decomm, site_address_a, site_address_b, site_address_c, site_city, site_state, \
site_country, site_zip, site_rack, site_notes, poc_1_name, poc_1_email, poc_1_phone_a, poc_1_phone_b, poc_1_cell, poc_1_screen, poc_1_notes, \
poc_2_name, poc_2_email, poc_2_phone_a, poc_2_phone_b, poc_2_cell, poc_2_screen, poc_2_notes FROM tmp_zbx_omni_host_inventory;'
select_zbx_zbx_host_inventory_sql = 'SELECT tmp_zbx_omni_hosts.hostid, i.inventory_mode, i.type, i.type_full, i.name, i.alias, i.os, i.os_full, i.os_short, \
i.serialno_a, i.serialno_b, i.tag, i.asset_tag, i.macaddress_a, i.macaddress_b, i.hardware, i.hardware_full, i.software, i.software_full, i.software_app_a, \
i.software_app_b, i.software_app_c, i.software_app_d, i.software_app_e, i.contact, i.location, i.location_lat, i.location_lon, i.notes, i.chassis, i.model, \
i.hw_arch, i.vendor, i.contract_number, i.installer_name, i.deployment_status, i.url_a, i.url_b, i.url_c, i.host_networks, i.host_netmask, i.host_router, \
i.oob_ip, i.oob_netmask, i.oob_router, i.date_hw_purchase, i.date_hw_install, i.date_hw_expiry, i.date_hw_decomm, i.site_address_a, i.site_address_b, \
i.site_address_c, i.site_city, i.site_state, i.site_country, i.site_zip, i.site_rack, i.site_notes, i.poc_1_name, i.poc_1_email, i.poc_1_phone_a, i.poc_1_phone_b, \
i.poc_1_cell, i.poc_1_screen, i.poc_1_notes, i.poc_2_name, i.poc_2_email, i.poc_2_phone_a, i.poc_2_phone_b, i.poc_2_cell, i.poc_2_screen, i.poc_2_notes \
FROM zbx_zbx_host_inventory AS i INNER JOIN zbx_zbx_hosts ON i.hostid=zbx_zbx_hosts.hostid INNER JOIN tmp_zbx_omni_hosts ON zbx_zbx_hosts.host=tmp_zbx_omni_hosts.host;'
select_omni_hostmacro_sql = 'SELECT tmp_zbx_omni_hostmacro.hostid, tmp_zbx_omni_hostmacro.macro, tmp_zbx_omni_hostmacro.value, ref_zbx_macro.name \
FROM tmp_zbx_omni_hostmacro INNER JOIN ref_zbx_macro ON tmp_zbx_omni_hostmacro.macro=ref_zbx_macro.macro;;'
select_ref_zbx_host_tag_sql = 'SELECT tag, source, field FROM ref_zbx_host_tag;'
select_tmp_zbx_omni_hosts_sql = 'SELECT hostid FROM tmp_zbx_omni_hosts;'


def load_childs(cur, sql, groupid, idset, prefix, parentid, log):
    result = []
    cur.execute(sql.format(str(parentid)))
    for r in cur.fetchall():
        if r[0] not in idset:
            idset.add(r[0])
            result.append((prefix+'/'+r[1], groupid, r[0]))
            result.extend(load_childs(cur, sql, groupid, idset, prefix+'/'+r[1], r[0], log))
    return result

def add_groups(db, log):
    cur = db.cursor()
    cur.execute(select_ref_zbx_group_sql)
    group_types = {r[0]:{'groupid':r[0], 'name':r[1], 'prefix':r[2], 'table_name':r[3], 'field_name':r[4], 'id_field':r[5], 
        'parent_field':r[6]} for r in cur.fetchall()}
    for groupid, group_type in group_types.items():
        if group_type['prefix']:
            vallist = [(group_type['prefix'], groupid, 0)]
        else:
            vallist = []
        if group_type['parent_field'] is None:
            cur.execute(select_group_source_sql.format(group_type['id_field'], group_type['field_name'], group_type['table_name']))
            for r in cur.fetchall():
                if group_type['prefix']:
                    vallist.append((group_type['prefix']+'/'+r[1], groupid, r[0]))
                else:
                    vallist.append((r[1], groupid, r[0]))
        else:
            idset = set()
            cur.execute(select_group_source_root_sql.format(group_type['id_field'], group_type['field_name'], group_type['table_name'],
                group_type['parent_field']))
            root_groups = [{'id':r[0], 'name':group_type['prefix']+'/'+r[1]} for r in cur.fetchall()]
            idset = set([g['id'] for g in root_groups])
            for root_group in root_groups:
                vallist.append((root_group['name'], groupid, root_group['id']))
                vallist.extend(load_childs(cur, select_group_source_parent_sql.format(group_type['id_field'], group_type['field_name'], group_type['table_name'], 
                group_type['parent_field'], '{0}'), groupid, idset, root_group['name'], root_group['id'], log))
        cur.executemany(insert_tmp_zbx_omni_hstgrp_sql, vallist)
        db.commit
    cur.close()

def add_hosttags(db, log):
    cur = db.cursor()
    cur.execute(select_zbx_omni_host_inventory_sql)
    omni_inventory = {r[0]:{'hostid':r[0], 'inventory_mode':r[1], 'type':r[2], 'type_full':r[3], 'name':r[4], 'alias':r[5], 'os':r[6], 'os_full':r[7],
        'os_short':r[8], 'serialno_a':r[9], 'serialno_b':r[10], 'tag':r[11], 'asset_tag':r[12], 'macaddress_a':r[13], 'macaddress_b':r[14],
        'hardware':r[15], 'hardware_full':r[16], 'software':r[17], 'software_full':r[18], 'software_app_a':r[19], 'software_app_b':r[20],
        'software_app_c':r[21], 'software_app_d':r[22], 'software_app_e':r[23], 'contact':r[24], 'location':r[25], 'location_lat':r[26],
        'location_lon':r[27], 'notes':r[28], 'chassis':r[29], 'model':r[30], 'hw_arch':r[31], 'vendor':r[32], 'contract_number':r[33],
        'installer_name':r[34], 'deployment_status':r[35], 'url_a':r[36], 'url_b':r[37], 'url_c':r[38], 'host_networks':r[39], 'host_netmask':r[40],
        'host_router':r[41], 'oob_ip':r[42], 'oob_netmask':r[43], 'oob_router':r[44], 'date_hw_purchase':r[45], 'date_hw_install':r[46],
        'date_hw_expiry':r[47], 'date_hw_decomm':r[48], 'site_address_a':r[49], 'site_address_b':r[50], 'site_address_c':r[51], 'site_city':r[52],
        'site_state':r[53], 'site_country':r[54], 'site_zip':r[55], 'site_rack':r[56], 'site_notes':r[57], 'poc_1_name':r[58], 'poc_1_email':r[59],
        'poc_1_phone_a':r[60], 'poc_1_phone_b':r[61], 'poc_1_cell':r[62], 'poc_1_screen':r[63], 'poc_1_notes':r[64], 'poc_2_name':r[65], 'poc_2_email':r[66],
        'poc_2_phone_a':r[67], 'poc_2_phone_b':r[68], 'poc_2_cell':r[69], 'poc_2_screen':r[70], 'poc_2_notes':r[71]} for r in cur.fetchall()}
    cur.execute(select_zbx_zbx_host_inventory_sql)
    zbx_inventory = {r[0]:{'hostid':r[0], 'inventory_mode':r[1], 'type':r[2], 'type_full':r[3], 'name':r[4], 'alias':r[5], 'os':r[6], 'os_full':r[7],
        'os_short':r[8], 'serialno_a':r[9], 'serialno_b':r[10], 'tag':r[11], 'asset_tag':r[12], 'macaddress_a':r[13], 'macaddress_b':r[14],
        'hardware':r[15], 'hardware_full':r[16], 'software':r[17], 'software_full':r[18], 'software_app_a':r[19], 'software_app_b':r[20],
        'software_app_c':r[21], 'software_app_d':r[22], 'software_app_e':r[23], 'contact':r[24], 'location':r[25], 'location_lat':r[26],
        'location_lon':r[27], 'notes':r[28], 'chassis':r[29], 'model':r[30], 'hw_arch':r[31], 'vendor':r[32], 'contract_number':r[33],
        'installer_name':r[34], 'deployment_status':r[35], 'url_a':r[36], 'url_b':r[37], 'url_c':r[38], 'host_networks':r[39], 'host_netmask':r[40],
        'host_router':r[41], 'oob_ip':r[42], 'oob_netmask':r[43], 'oob_router':r[44], 'date_hw_purchase':r[45], 'date_hw_install':r[46],
        'date_hw_expiry':r[47], 'date_hw_decomm':r[48], 'site_address_a':r[49], 'site_address_b':r[50], 'site_address_c':r[51], 'site_city':r[52],
        'site_state':r[53], 'site_country':r[54], 'site_zip':r[55], 'site_rack':r[56], 'site_notes':r[57], 'poc_1_name':r[58], 'poc_1_email':r[59],
        'poc_1_phone_a':r[60], 'poc_1_phone_b':r[61], 'poc_1_cell':r[62], 'poc_1_screen':r[63], 'poc_1_notes':r[64], 'poc_2_name':r[65], 'poc_2_email':r[66],
        'poc_2_phone_a':r[67], 'poc_2_phone_b':r[68], 'poc_2_cell':r[69], 'poc_2_screen':r[70], 'poc_2_notes':r[71]} for r in cur.fetchall()}
    cur.execute(select_omni_hostmacro_sql)
    omni_hostmacros = {}
    for r in cur.fetchall():
        if r[0] not in omni_hostmacros:
            omni_hostmacros[r[0]] = {}
        omni_hostmacros[r[0]][r[3]] = r[2]
    cur.execute(select_ref_zbx_host_tag_sql)
    ref_hosttags = [{'tag':r[0], 'source':r[1], 'field':r[2]} for r in cur.fetchall()]
    vallist = []
    cur.execute(select_tmp_zbx_omni_hosts_sql)
    for r in cur.fetchall():
        hostid = r[0]
        for hosttag in ref_hosttags:
            tag = hosttag['tag']
            field = hosttag['field']
            if hosttag['source']=='macro':
                try:
                    value = omni_hostmacros[hostid][field]
                except:
                    value = None
            elif hosttag['source']=='inventory':
                try:
                    value = omni_inventory[hostid][field]
                except:
                    value = None
                if value is None or value=='':
                    try:
                        value = zbx_inventory[hostid][field]
                        if value=='':
                            value = None
                    except:
                        value = None
            else:
                value = None
            if value is not None:
                vallist.append((hostid, tag, value))
    if vallist:
        cur.executemany(insert_tmp_zbx_omni_host_tag_sql, vallist)
        db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_zbx_user, omni_unpwd.db_zbx_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=[1,2])
        add_groups(omnidb, program.log)
        omnidb.run_program_queries(stage=list(range(3,9)))
        add_hosttags(omnidb, program.log)
        omnidb.run_program_queries(stage=list(range(9,11)))
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())