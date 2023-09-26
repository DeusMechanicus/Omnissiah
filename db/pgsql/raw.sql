CREATE TABLE IF NOT EXISTS raw_mac ( 
  registry VARCHAR(16) DEFAULT NULL, 
  assignment VARCHAR(12) NOT NULL PRIMARY KEY, 
  organization VARCHAR(256) DEFAULT NULL, 
  address VARCHAR(300) DEFAULT NULL);

CREATE TABLE IF NOT EXISTS raw_netbox_tenancy_tenantgroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_tenancy_tenant ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  group_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_sitegroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_region ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_site ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  region_id BIGINT DEFAULT NULL, 
  group_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  facility VARCHAR(50) DEFAULT NULL, 
  time_zone VARCHAR(63) DEFAULT NULL, 
  physical_address VARCHAR(200) DEFAULT NULL, 
  shipping_address VARCHAR(200) DEFAULT NULL, 
  latitude NUMERIC(8,6) DEFAULT NULL, 
  longitude NUMERIC(9,6) DEFAULT NULL, 
  contact_name VARCHAR(50) DEFAULT NULL, 
  contact_phone VARCHAR(20) DEFAULT NULL, 
  contact_email VARCHAR(254) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  asn BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_location ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  tenant_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_rackrole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_rack ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  facility_id VARCHAR(50) DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL, 
  location_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  type VARCHAR(50) DEFAULT NULL, 
  serial VARCHAR(50) DEFAULT NULL, 
  asset_tag VARCHAR(50) DEFAULT NULL, 
  width SMALLINT DEFAULT NULL, 
  u_height SMALLINT DEFAULT NULL, 
  desc_units BOOLEAN DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  outer_width SMALLINT DEFAULT NULL, 
  outer_depth SMALLINT DEFAULT NULL, 
  outer_unit VARCHAR(50) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_manufacturer ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_devicerole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  vm_role BOOLEAN DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_platform ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  manufacturer_id BIGINT DEFAULT NULL, 
  napalm_driver VARCHAR(50) DEFAULT NULL, 
  napalm_args VARCHAR(1024) DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_devicetype ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  slug VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  manufacturer_id BIGINT DEFAULT NULL, 
  model VARCHAR(100) DEFAULT NULL, 
  part_number VARCHAR(50) DEFAULT NULL, 
  u_height SMALLINT DEFAULT NULL, 
  is_full_depth BOOLEAN DEFAULT NULL, 
  subdevice_role VARCHAR(50) DEFAULT NULL, 
  airflow VARCHAR(50) DEFAULT NULL, 
  front_image VARCHAR(256) DEFAULT NULL, 
  rear_image VARCHAR(256) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_virtualchassis ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  domain VARCHAR(30) DEFAULT NULL, 
  master_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_device ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  device_type_id BIGINT DEFAULT NULL, 
  device_role_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  platform_id BIGINT DEFAULT NULL, 
  serial VARCHAR(50) DEFAULT NULL, 
  asset_tag VARCHAR(50) DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL, 
  location_id BIGINT DEFAULT NULL, 
  rack_id BIGINT DEFAULT NULL, 
  position SMALLINT DEFAULT NULL, 
  face VARCHAR(100) DEFAULT NULL, 
  parent_device_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  primary_ip VARCHAR(43) DEFAULT NULL, 
  primary_ip4_id BIGINT DEFAULT NULL, 
  primary_ip6_id BIGINT DEFAULT NULL, 
  cluster_id BIGINT DEFAULT NULL, 
  virtual_chassis_id BIGINT DEFAULT NULL, 
  vc_position SMALLINT DEFAULT NULL, 
  vc_priority SMALLINT DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  local_context_data VARCHAR(1024) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_interface ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(64) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  device_id BIGINT DEFAULT NULL, 
  type VARCHAR(50) DEFAULT NULL, 
  enabled BOOLEAN DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  bridge_id BIGINT DEFAULT NULL, 
  lag_id BIGINT DEFAULT NULL, 
  mtu INT DEFAULT NULL, 
  mac_address VARCHAR(17) DEFAULT NULL, 
  wwn VARCHAR(23) DEFAULT NULL, 
  mgmt_only BOOLEAN DEFAULT NULL, 
  mode VARCHAR(50) DEFAULT NULL, 
  rf_role VARCHAR(30) DEFAULT NULL, 
  rf_channel VARCHAR(50) DEFAULT NULL, 
  rf_channel_frequency NUMERIC(7,2) DEFAULT NULL, 
  rf_channel_width NUMERIC(7,3) DEFAULT NULL, 
  tx_power SMALLINT DEFAULT NULL, 
  untagged_vlan_id BIGINT DEFAULT NULL, 
  mark_connected BOOLEAN DEFAULT NULL, 
  label VARCHAR(64) DEFAULT NULL, 
  cable_id BIGINT DEFAULT NULL, 
  wireless_link_id BIGINT DEFAULT NULL, 
  link_peer VARCHAR(100) DEFAULT NULL, 
  link_peer_type INT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_vrf ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  rd VARCHAR(21) DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  enforce_unique BOOLEAN DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_role ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  weight SMALLINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_vlangroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  scope_type VARCHAR(100) DEFAULT NULL, 
  scope_id BIGINT DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_vlan ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL,
  group_id BIGINT DEFAULT NULL,
  vid SMALLINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL,
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_prefix ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  prefix VARCHAR(43) DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL,
  vrf_id BIGINT DEFAULT NULL,
  tenant_id BIGINT DEFAULT NULL,
  vlan_id BIGINT DEFAULT NULL,
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  is_pool BOOLEAN DEFAULT NULL, 
  mark_utilized BOOLEAN DEFAULT NULL, 
  level INT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_iprange ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  start_address VARCHAR(43) DEFAULT NULL, 
  end_address VARCHAR(43) DEFAULT NULL, 
  size INT DEFAULT NULL, 
  vrf_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_ipaddress ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  address VARCHAR(43) DEFAULT NULL, 
  vrf_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  role VARCHAR(50) DEFAULT NULL, 
  assigned_object_type VARCHAR(100) DEFAULT NULL, 
  assigned_object_id  VARCHAR(100) DEFAULT NULL, 
  assigned_object VARCHAR(100) DEFAULT NULL, 
  nat_inside_id BIGINT DEFAULT NULL, 
  nat_outside_id BIGINT DEFAULT NULL, 
  dns_name VARCHAR(255) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS raw_scan_ip (
  ipid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) NULL UNIQUE,
  refid INT NOT NULL CHECK (refid>=0),
  sourceid INT NOT NULL CHECK (sourceid>=0) 
);
CREATE INDEX ON raw_scan_ip (refid);
CREATE INDEX ON raw_scan_ip (sourceid);

CREATE TABLE IF NOT EXISTS raw_scan_ip_info (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ipid INT NOT NULL CHECK (ipid>=0),
  infoid INT NOT NULL CHECK (infoid>=0), 
  value VARCHAR(256) NOT NULL 
);
CREATE INDEX ON raw_scan_ip_info (ipid);
CREATE INDEX ON raw_scan_ip_info (infoid);

CREATE TABLE IF NOT EXISTS raw_scan_arp (
  arpid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid INT NOT NULL CHECK (routerid>=0),
  mac VARCHAR(12) NOT NULL 
);
CREATE INDEX ON raw_scan_arp (ip);
CREATE INDEX ON raw_scan_arp (routerid);
CREATE INDEX ON raw_scan_arp (mac);

CREATE TABLE IF NOT EXISTS raw_scan_dhcp (
  dhcpid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39)NOT NULL,
  routerid INT NOT NULL CHECK (routerid>=0),
  mac VARCHAR(12) DEFAULT NULL 
);
CREATE INDEX ON raw_scan_dhcp (ip);
CREATE INDEX ON raw_scan_dhcp (routerid);
CREATE INDEX ON raw_scan_dhcp (mac);

CREATE TABLE IF NOT EXISTS raw_scan_port (
  portid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  port INT NOT NULL CHECK (port>=0),
  ipid INT NOT NULL CHECK (ipid>=0),
  state VARCHAR(20) NOT NULL,
  reason VARCHAR(20) NOT NULL
);
CREATE INDEX ON raw_scan_port (type);
CREATE INDEX ON raw_scan_port (port);
CREATE INDEX ON raw_scan_port (ipid);
CREATE INDEX ON raw_scan_port (state);
CREATE INDEX ON raw_scan_port (reason);
CREATE INDEX ON raw_scan_port (ipid, type, port);

CREATE TABLE IF NOT EXISTS raw_scan_script (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  portid INT NOT NULL CHECK (portid>=0),  
  script VARCHAR(100) NOT NULL, 
  value VARCHAR(16100) NOT NULL 
);
CREATE INDEX ON raw_scan_script (portid);
CREATE INDEX ON raw_scan_script (script);

CREATE TABLE IF NOT EXISTS raw_scan_service (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  portid INT NOT NULL CHECK (portid>=0),  
  product VARCHAR(100) DEFAULT NULL, 
  version VARCHAR(50) DEFAULT NULL, 
  extrainfo VARCHAR(256) DEFAULT NULL, 
  conf INT DEFAULT NULL, 
  cpe VARCHAR(100) DEFAULT NULL, 
  name VARCHAR(50) DEFAULT NULL, 
  method VARCHAR(256) DEFAULT NULL, 
  servicefp VARCHAR(14100) DEFAULT NULL 
);
CREATE INDEX ON raw_scan_service (portid);
CREATE INDEX ON raw_scan_service (product);
CREATE INDEX ON raw_scan_service (cpe);

CREATE TABLE IF NOT EXISTS raw_scan_osportused (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid INT NOT NULL CHECK (ipid>=0), 
  state VARCHAR(20) NOT NULL,
  proto VARCHAR(20) NOT NULL,
  port INT NOT NULL CHECK (port>=0)
);
CREATE INDEX ON raw_scan_osportused (ipid);

CREATE TABLE IF NOT EXISTS raw_scan_osmatch (
  osmatchid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid INT NOT NULL CHECK (ipid>=0), 
  name VARCHAR(256) NOT NULL,
  accuracy INT NOT NULL CHECK (accuracy>=0),
  line INT DEFAULT NULL 
);
CREATE INDEX ON raw_scan_osmatch (ipid);
CREATE INDEX ON raw_scan_osmatch (name);

CREATE TABLE IF NOT EXISTS raw_scan_osclass (
  osclassid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  osmatchid INT NOT NULL CHECK (osmatchid>=0), 
  type VARCHAR(50) DEFAULT NULL, 
  vendor VARCHAR(50) DEFAULT NULL, 
  osfamily VARCHAR(50) DEFAULT NULL, 
  osgen VARCHAR(20) DEFAULT NULL, 
  accuracy INT NOT NULL CHECK (accuracy>=0),
  cpe VARCHAR(100) DEFAULT NULL 
);
CREATE INDEX ON raw_scan_osclass (osmatchid);

CREATE TABLE IF NOT EXISTS raw_enplug (
  enplugid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  macaddressethernet VARCHAR(17) DEFAULT NULL, 
  macaddresswifi VARCHAR(17) DEFAULT NULL, 
  ipaddress VARCHAR(39) DEFAULT NULL, 
  internalipaddress VARCHAR(39) DEFAULT NULL, 
  edu_id VARCHAR(256) DEFAULT NULL, 
  edu_name VARCHAR(256) DEFAULT NULL, 
  venue_timezone VARCHAR(100) DEFAULT NULL, 
  venue_id VARCHAR(256) DEFAULT NULL, 
  venue_name VARCHAR(256) DEFAULT NULL, 
  account_id VARCHAR(256) DEFAULT NULL, 
  account_name VARCHAR(256) DEFAULT NULL, 
  statuscode VARCHAR(20) DEFAULT NULL, 
  statusmessage VARCHAR(1024) DEFAULT NULL, 
  lastplayerheartbeat VARCHAR(100) DEFAULT NULL, 
  playeruptime INT DEFAULT NULL, 
  tvstatus VARCHAR(100) DEFAULT NULL, 
  playerversion VARCHAR(20) DEFAULT NULL, 
  created TIMESTAMP DEFAULT NULL, 
  tags VARCHAR(1024) DEFAULT NULL 
);
CREATE INDEX ON raw_enplug (venue_id);
CREATE INDEX ON raw_enplug (venue_timezone);
CREATE INDEX ON raw_enplug (ipaddress);
CREATE INDEX ON raw_enplug (statuscode);

CREATE TABLE IF NOT EXISTS raw_activaire (
  activaireid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  _id VARCHAR(256) DEFAULT NULL, 
  name VARCHAR(256) DEFAULT NULL, 
  macaddress VARCHAR(17) DEFAULT NULL, 
  remotevolume INT DEFAULT NULL, 
  remotevolumemode VARCHAR(10) DEFAULT NULL, 
  lastonline BIGINT DEFAULT NULL, 
  isplaying VARCHAR(10) DEFAULT NULL, 
  makeandmodel VARCHAR(20) DEFAULT NULL, 
  ethernetmacaddress VARCHAR(17) DEFAULT NULL, 
  internalipaddress VARCHAR(39) DEFAULT NULL, 
  publicipaddress VARCHAR(39) DEFAULT NULL, 
  appversion VARCHAR(20) DEFAULT NULL, 
  currentsong VARCHAR(256) DEFAULT NULL, 
  devicestatus VARCHAR(20) DEFAULT NULL 
);
CREATE INDEX ON raw_activaire (_id);
CREATE INDEX ON raw_activaire (publicipaddress);
CREATE INDEX ON raw_activaire (internalipaddress);
CREATE INDEX ON raw_activaire (devicestatus);

CREATE TABLE IF NOT EXISTS raw_snmp (
  snmpid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid INT NOT NULL CHECK (ipid>=0), 
  oidid INT DEFAULT NULL CHECK (oidid>=0), 
  oid VARCHAR(256) NOT NULL,
  oid_index VARCHAR(256) DEFAULT NULL,
  snmp_type VARCHAR(20) NOT NULL,
  value VARCHAR(1000) NOT NULL, 
  value_hex VARCHAR(2000) NOT NULL, 
  vlan INT DEFAULT NULL CHECK (vlan>=0) 
);
CREATE INDEX ON raw_snmp (ipid);
CREATE INDEX ON raw_snmp (oidid);
CREATE INDEX ON raw_snmp (oid);
CREATE INDEX ON raw_snmp (snmp_type);
CREATE INDEX ON raw_snmp (vlan);

CREATE TABLE IF NOT EXISTS raw_ruckussz (
  wapid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ip VARCHAR(39) DEFAULT NULL, 
  wlcip VARCHAR(39) DEFAULT NULL, 
  externalip VARCHAR(39) DEFAULT NULL, 
  mac VARCHAR(17) DEFAULT NULL, 
  name VARCHAR(256) DEFAULT NULL, 
  model VARCHAR(256) DEFAULT NULL, 
  location VARCHAR(256) DEFAULT NULL, 
  administrativestate VARCHAR(20) DEFAULT NULL, 
  countrycode VARCHAR(20) DEFAULT NULL, 
  configstate VARCHAR(20) DEFAULT NULL, 
  connectionstate VARCHAR(20) DEFAULT NULL, 
  registrationstate VARCHAR(20) DEFAULT NULL, 
  lastseentime BIGINT DEFAULT NULL, 
  approvedtime BIGINT DEFAULT NULL, 
  uptime BIGINT DEFAULT NULL, 
  clientcount INT DEFAULT NULL 
);
CREATE INDEX ON raw_ruckussz (ip); 
CREATE INDEX ON raw_ruckussz (externalip); 
CREATE INDEX ON raw_ruckussz (wlcip); 
CREATE INDEX ON raw_ruckussz (mac); 
CREATE INDEX ON raw_ruckussz (connectionstate); 
CREATE INDEX ON raw_ruckussz (lastseentime); 

CREATE TABLE IF NOT EXISTS raw_mist (
  mistid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) DEFAULT NULL,
  ext_ip VARCHAR(39) DEFAULT NULL,
  mac VARCHAR(17) DEFAULT NULL,
  status VARCHAR(20) DEFAULT NULL,
  type VARCHAR(20) DEFAULT NULL,
  last_seen BIGINT DEFAULT NULL,
  uptime BIGINT DEFAULT NULL,
  name VARCHAR(100) DEFAULT NULL,
  model VARCHAR(20) DEFAULT NULL,
  lldp_stat_chassis_id VARCHAR(17) DEFAULT NULL,
  lldp_stat_system_name VARCHAR(100) DEFAULT NULL,
  lldp_stat_system_desc VARCHAR(256) DEFAULT NULL,
  lldp_stat_port_desc VARCHAR(100) DEFAULT NULL,
  lldp_stat_port_id VARCHAR(50) DEFAULT NULL 
);
CREATE INDEX ON raw_mist (ip);
CREATE INDEX ON raw_mist (ext_ip); 
CREATE INDEX ON raw_mist (mac); 
CREATE INDEX ON raw_mist (status); 
CREATE INDEX ON raw_mist (last_seen); 
