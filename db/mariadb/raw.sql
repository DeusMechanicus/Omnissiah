CREATE TABLE IF NOT EXISTS raw_mac ( 
  registry VARCHAR(16) DEFAULT NULL, 
  assignment VARCHAR(12) NOT NULL PRIMARY KEY, 
  organization VARCHAR(256) DEFAULT NULL, 
  address VARCHAR(256) DEFAULT NULL) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_tenancy_tenantgroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_tenancy_tenant ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  group_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_sitegroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_region ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_site ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_location ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  tenant_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_rackrole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_rack ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_manufacturer ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_devicerole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  vm_role BOOLEAN DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_platform ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  manufacturer_id BIGINT DEFAULT NULL, 
  napalm_driver VARCHAR(50) DEFAULT NULL, 
  napalm_args VARCHAR(1024) DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_devicetype ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  slug VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  manufacturer_id BIGINT DEFAULT NULL, 
  model VARCHAR(100) DEFAULT NULL, 
  part_number VARCHAR(50) DEFAULT NULL, 
  u_height SMALLINT DEFAULT NULL, 
  is_full_depth BOOLEAN DEFAULT NULL, 
  subdevice_role VARCHAR(50) DEFAULT NULL, 
  airflow VARCHAR(50) DEFAULT NULL, 
  front_image VARCHAR(100) DEFAULT NULL, 
  rear_image VARCHAR(100) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_virtualchassis ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  domain VARCHAR(30) DEFAULT NULL, 
  master_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_device ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_dcim_interface ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(64) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_vrf ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  rd VARCHAR(21) DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  enforce_unique BOOLEAN DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_role ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  weight SMALLINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_vlangroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  scope_type VARCHAR(100) DEFAULT NULL, 
  scope_id BIGINT DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_vlan ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  site_id BIGINT DEFAULT NULL,
  group_id BIGINT DEFAULT NULL,
  vid SMALLINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL,
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_prefix ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
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
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_iprange ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  start_address VARCHAR(43) DEFAULT NULL, 
  end_address VARCHAR(43) DEFAULT NULL, 
  size INT DEFAULT NULL, 
  vrf_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_netbox_ipam_ipaddress ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_ip (
  ipid INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  ip VARCHAR(39) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  refid INT UNSIGNED NOT NULL,
  sourceid INT UNSIGNED NOT NULL,
  KEY refid (refid),
  KEY sourceid (sourceid)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_ip_info (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  ipid INT UNSIGNED NOT NULL,
  infoid INT UNSIGNED NOT NULL,
  value VARCHAR(256) COLLATE utf8mb4_bin NOT NULL,
  KEY ipid (ipid),
  KEY infoid (infoid) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_arp (
  arpid INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  ip VARCHAR(39) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  routerid INT UNSIGNED NOT NULL,
  mac VARCHAR(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  KEY ip (ip),
  KEY routerid (routerid),
  KEY mac (mac)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_dhcp (
  dhcpid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
  ip VARCHAR(39) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  routerid INT UNSIGNED NOT NULL,
  mac VARCHAR(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY ip (ip),
  KEY routerid (routerid),
  KEY mac (mac)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_port (
  portid INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  type VARCHAR(20) NOT NULL,
  port INT UNSIGNED NOT NULL,
  ipid INT UNSIGNED NOT NULL,
  state VARCHAR(20) NOT NULL,
  reason VARCHAR(20) NOT NULL,
  KEY type (type),
  KEY port (port),
  KEY ipid (ipid),
  KEY state (state),
  KEY reason (reason),
  KEY iptypeport (ipid, type, port)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_script (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  portid INT UNSIGNED NOT NULL, 
  script VARCHAR(100) NOT NULL, 
  value VARCHAR(16100) NOT NULL, 
  KEY portid (portid), 
  KEY script (script) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_service (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  portid INT UNSIGNED NOT NULL, 
  product VARCHAR(100) DEFAULT NULL, 
  version VARCHAR(50) DEFAULT NULL, 
  extrainfo VARCHAR(256) DEFAULT NULL, 
  conf INT DEFAULT NULL, 
  cpe VARCHAR(100) DEFAULT NULL, 
  name VARCHAR(50) DEFAULT NULL, 
  method VARCHAR(256) DEFAULT NULL, 
  servicefp VARCHAR(14100) DEFAULT NULL, 
  KEY portid (portid), 
  KEY product (product), 
  KEY cpe (cpe) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_osportused (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid INT UNSIGNED NOT NULL, 
  state VARCHAR(20) NOT NULL,
  proto VARCHAR(20) NOT NULL,
  port INT UNSIGNED NOT NULL,
  KEY ipid (ipid) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_osmatch (
  osmatchid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid INT UNSIGNED NOT NULL, 
  name VARCHAR(256) NOT NULL,
  accuracy INT UNSIGNED NOT NULL,
  line INT DEFAULT NULL,  
  KEY ipid (ipid), 
  KEY name (name) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_scan_osclass (
  osclassid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  osmatchid INT UNSIGNED NOT NULL, 
  type VARCHAR(50) DEFAULT NULL, 
  vendor VARCHAR(50) DEFAULT NULL, 
  osfamily VARCHAR(50) DEFAULT NULL, 
  osgen VARCHAR(20) DEFAULT NULL, 
  accuracy INT UNSIGNED NOT NULL,
  cpe VARCHAR(100) DEFAULT NULL, 
  KEY osmatchid (osmatchid) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_enplug (
  enplugid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
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
  created DATETIME DEFAULT NULL, 
  tags VARCHAR(1024) DEFAULT NULL, 
  KEY venue_id (venue_id), 
  KEY venue_timezone (venue_timezone), 
  KEY ipaddress (ipaddress), 
  KEY statuscode (statuscode) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_activaire (
  activaireid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
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
  devicestatus VARCHAR(20) DEFAULT NULL, 
  KEY _id (_id), 
  KEY publicipaddress (publicipaddress), 
  KEY internalipaddress (internalipaddress), 
  KEY devicestatus (devicestatus) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_snmp (
  snmpid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid INT UNSIGNED NOT NULL, 
  oidid INT UNSIGNED DEFAULT NULL, 
  oid VARCHAR(256) NOT NULL,
  oid_index VARCHAR(256) DEFAULT NULL,
  snmp_type VARCHAR(20) NOT NULL,
  value VARCHAR(1000) NOT NULL, 
  value_hex VARCHAR(2000) NOT NULL, 
  vlan INT UNSIGNED DEFAULT NULL, 
  KEY ipid (ipid),
  KEY oidid (oidid),
  KEY oid (oid),
  KEY snmp_type (snmp_type), 
  KEY vlan (vlan) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_ruckussz (
  wapid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
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
  clientcount INT DEFAULT NULL, 
  KEY ip (ip), 
  KEY externalip (externalip), 
  KEY wlcip (wlcip), 
  KEY mac (mac), 
  KEY connectionstate (connectionstate), 
  KEY lastseentime (lastseentime) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS raw_mist (
  mistid INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
  lldp_stat_port_id VARCHAR(50) DEFAULT NULL,
  KEY ip (ip),
  KEY ext_ip (ext_ip),
  KEY mac (mac),
  KEY status (status),
  KEY last_seen (last_seen)
) ENGINE=InnoDB;

