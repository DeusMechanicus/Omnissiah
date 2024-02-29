#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
from pynetbox import api

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.msg import msg_db_query_try, msg_db_added_records


netbox_tables = {
'tenancy_tenantgroup':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'parent.id':'parent_id', '_depth':'level', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_tenancy_tenantgroup'},
'tenancy_tenant':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'group.id':'group_id', 'comments':'comments', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_tenancy_tenant'},
'dcim_sitegroup':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'parent.id':'parent_id', '_depth':'level', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_dcim_sitegroup'},
'dcim_region':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'parent.id':'parent_id', '_depth':'level', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_dcim_region'},
'dcim_site':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'status':'status', 'region.id':'region_id', 'group.id':'group_id', 'tenant.id':'tenant_id',
    'facility':'facility', 'time_zone':'time_zone', 'physical_address':'physical_address', 'shipping_address':'shipping_address',
    'latitude':'latitude', 'longitude':'longitude', 'contact_name':'contact_name', 'contact_phone':'contact_phone',
    'contact_email':'contact_email', 'comments':'comments', 'asn':'asn', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_site'},
'dcim_location':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'site.id':'site_id', 'parent.id':'parent_id', 'tenant.id':'tenant_id',
    'custom_fields':'custom_fields', '_depth':'level'}, 'dbtable':'raw_netbox_dcim_location'},
'dcim_rackrole':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'color':'color', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_rackrole'},
'dcim_rack':{'fields':{'id':'id', 'name':'name', 'created':'created', 'last_updated':'last_updated',
    'facility_id':'facility_id', 'site.id':'site_id', 'location.id':'location_id', 'tenant.id':'tenant_id',
    'status':'status', 'role.id':'role_id', 'type':'type', 'width.value':'width', 'u_height':'u_height', 'desc_units':'desc_units',
    'serial':'serial', 'asset_tag':'asset_tag', 'comments':'comments', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_dcim_rack'},
'dcim_manufacturer':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_manufacturer'},
'dcim_devicerole':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'color':'color', 'vm_role':'vm_role', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_dcim_devicerole'},
'dcim_platform':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'manufacturer.id':'manufacturer_id', 'napalm_driver':'napalm_driver', 'napalm_args':'napalm_args',
    'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_platform'},
'dcim_devicetype':{'fields':{'id':'id', 'slug':'slug', 'created':'created', 'last_updated':'last_updated',
    'manufacturer.id':'manufacturer_id', 'model':'model', 'part_number':'part_number', 'u_height':'u_height',
    'is_full_depth':'is_full_depth', 'subdevice_role':'subdevice_role', 'airflow':'airflow', 'front_image':'front_image',
    'rear_image':'rear_image', 'comments':'comments', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_devicetype'},
'dcim_virtualchassis':{'fields':{'id':'id', 'name':'name', 'created':'created', 'last_updated':'last_updated',
    'domain':'domain', 'master.id':'master_id', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_virtualchassis'},
'dcim_device':{'fields':{'id':'id', 'name':'name', 'created':'created',
    'last_updated':'last_updated', 'device_type.id':'device_type_id', 'device_role.id':'device_role_id',
    'tenant.id':'tenant_id', 'platform.id':'platform_id', 'serial':'serial', 'asset_tag':'asset_tag',
    'site.id':'site_id', 'location.id':'location_id', 'rack.id':'rack_id', 'position':'position', 'face':'face',
    'parent_device.id':'parent_device_id', 'status':'status', 'primary_ip':'primary_ip', 'primary_ip4.id':'primary_ip4_id',
    'primary_ip6.id':'primary_ip6_id', 'cluster.id':'cluster_id', 'virtual_chassis.id':'virtual_chassis_id',
    'vc_position':'vc_position', 'vc_priority':'vc_priority', 'comments':'comments', 'local_context_data':'local_context_data',
    'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_device'},
#'dcim_interface':{'fields':{'id':'id', 'name':'name', 'description':'description', 'created':'created',
#    'last_updated':'last_updated', 'device.id':'device_id', 'type':'type', 'enabled':'enabled', 'parent.id':'parent_id',
#    'bridge.id':'bridge_id', 'lag.id':'lag_id', 'mtu':'mtu', 'mac_address':'mac_address', 'wwn':'wwn', 'mgmt_only':'mgmt_only', 'mode':'mode',
#    'rf_role':'rf_role', 'rf_channel':'rf_channel', 'rf_channel_frequency':'rf_channel_frequency', 'rf_channel_width':'rf_channel_width',
#    'tx_power':'tx_power', 'untagged_vlan.id':'untagged_vlan_id', 'mark_connected':'mark_connected', 'label':'label',
#    'cable.id':'cable_id', 'wireless_link.id':'wireless_link_id', 'link_peer':'link_peer', 'link_peer_type':'link_peer_type',
#    'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_dcim_interface'},
'ipam_vrf':{'fields':{'id':'id', 'name':'name', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'rd':'rd', 'tenant.id':'tenant_id', 'enforce_unique':'enforce_unique',
    'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_ipam_vrf'},
'ipam_role':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'weight':'weight', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_ipam_role'},
'ipam_vlangroup':{'fields':{'id':'id', 'name':'name', 'slug':'slug', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'scope_type':'scope_type', 'scope_id':'scope_id', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_ipam_vlangroup'},
'ipam_vlan':{'fields':{'id':'id', 'name':'name', 'description':'description', 'created':'created',
    'last_updated':'last_updated', 'site.id':'site_id', 'group.id':'group_id', 'vid':'vid', 'tenant.id':'tenant_id',
    'status':'status', 'role.id':'role_id', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_ipam_vlan'},
'ipam_prefix':{'fields':{'id':'id', 'description':'description', 'created':'created', 'last_updated':'last_updated',
    'family':'family', 'prefix':'prefix', 'site.id':'site_id', 'vrf.id':'vrf_id', 'tenant.id':'tenant_id',
    'vlan.id':'vlan_id', 'status':'status', 'role.id':'role_id', 'is_pool':'is_pool', 'mark_utilized':'mark_utilized',
    '_depth':'level', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_ipam_prefix'},
'ipam_iprange':{'fields':{'id':'id', 'description':'description', 'created':'created', 'last_updated':'last_updated',
    'family':'family', 'start_address':'start_address', 'end_address':'end_address', 'size':'size',
    'vrf.id':'vrf_id', 'tenant.id':'tenant_id', 'status':'status', 'role.id':'role_id', 'custom_fields':'custom_fields'},
    'dbtable':'raw_netbox_ipam_iprange'},
'ipam_ipaddress':{'fields':{'id':'id', 'description':'description', 'created':'created', 'last_updated':'last_updated',
    'family':'family', 'address':'address', 'vrf.id':'vrf_id', 'tenant.id':'tenant_id', 'status':'status',
    'role':'role', 'assigned_object_type':'assigned_object_type', 'assigned_object_id':'assigned_object_id',
    'assigned_object':'assigned_object', 'nat_inside.id':'nat_inside_id', 'nat_outside.id':'nat_outside_id',
    'dns_name':'dns_name', 'custom_fields':'custom_fields'}, 'dbtable':'raw_netbox_ipam_ipaddress'}}

insert_raw_netbox_sql = {'mariadb':'INSERT IGNORE INTO {0} ({1}) VALUES ({2});',
    'pgsql':'INSERT INTO {0} ({1}) VALUES ({2}) ON CONFLICT DO NOTHING;'}


def getall(netbox):
    return {'tenancy_tenantgroup':netbox.tenancy.tenant_groups.all(), 'tenancy_tenant':netbox.tenancy.tenants.all(),
        'dcim_sitegroup':netbox.dcim.site_groups.all(), 'dcim_region':netbox.dcim.regions.all(),
        'dcim_site':netbox.dcim.sites.all(), 'dcim_location':netbox.dcim.locations.all(),
        'dcim_rackrole':netbox.dcim.rack_roles.all(), 'dcim_rack':netbox.dcim.racks.all(),
        'dcim_manufacturer':netbox.dcim.manufacturers.all(), 'dcim_devicerole':netbox.dcim.device_roles.all(),
        'dcim_platform':netbox.dcim.platforms.all(), 'dcim_devicetype':netbox.dcim.device_types.all(),
        'dcim_virtualchassis':netbox.dcim.virtual_chassis.all(), 'dcim_device':netbox.dcim.devices.all(),
#        'dcim_interface':getone(netbox.dcim.interfaces.all),
        'ipam_vrf':netbox.ipam.vrfs.all(),
        'ipam_role':netbox.ipam.roles.all(), 'ipam_vlangroup':netbox.ipam.vlan_groups.all(),
        'ipam_vlan':netbox.ipam.vlans.all(), 'ipam_prefix':netbox.ipam.prefixes.all(),
        'ipam_iprange':netbox.ipam.ip_ranges.all(), 'ipam_ipaddress':netbox.ipam.ip_addresses.all()}

def save_netbox(db, netbox_data, dbtype, log):
    cur = db.cursor()
    for table in netbox_tables:
        sql = insert_raw_netbox_sql[dbtype]
        sql = insert_raw_netbox_sql[dbtype].format(netbox_tables[table]['dbtable'],
            ','.join([ td for tn, td in netbox_tables[table]['fields'].items() ]),
            ','.join(['%s']*len(netbox_tables[table]['fields'])))
        values = []
        recnum = 0
        try:
            netbox_list = list(netbox_data[table])
        except:
            netbox_list = []
        for record in netbox_list:
            vals = []
            for field in netbox_tables[table]['fields']:
                try:
                    if '.' in field:
                        flds = field.split('.')
                        v = getattr(record, flds[0])
                        if v is not None:
                            v = getattr(v, flds[1])
                    else:
                        v = getattr(record, field)
                except:
                    v = None
                if not (v is None or isinstance(v, str) or isinstance(v, int) or isinstance(v,float)):
                    v = str(v)
                vals.append(v)
            values.append(tuple(vals))
            recnum += 1
        if recnum:
            log.info(msg_db_query_try.format(sql))
            if values:
                cur.executemany(sql, values)
                log.info(msg_db_added_records.format(netbox_tables[table]['dbtable'], recnum))
                db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        netbox = api(omni_config.netbox_url, token=omni_unpwd.netbox_token, threading=True)
        omnidb.run_program_queries(stage=1)
        netbox_data = getall(netbox)
        save_netbox(omnidb, netbox_data, omni_config.dbtype, program.log)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())
