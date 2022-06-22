CREATE TABLE IF NOT EXISTS info_mac (
  assignmentid INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  assignment VARCHAR(12) NOT NULL PRIMARY KEY, 
  registry VARCHAR(16) NOT NULL, 
  organization VARCHAR(256) NOT NULL, 
  address VARCHAR(256) DEFAULT NULL, 
  assignment_len SMALLINT UNSIGNED NOT NULL,
  first_mac CHAR(12) NOT NULL, 
  last_mac CHAR(12) NOT NULL, 
  first_mac_num BIGINT UNSIGNED NOT NULL, 
  last_mac_num BIGINT UNSIGNED NOT NULL, 
  KEY registry (registry), 
  KEY organization (organization), 
  KEY assignment_len (assignment_len), 
  KEY first_last_mac (first_mac, last_mac), 
  KEY first_last_mac_num (first_mac_num, last_mac_num) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_tenancy_tenantgroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL, 
  slug VARCHAR(100) NOT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY name (name), 
  KEY slug (slug), 
  KEY parent_id (parent_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_tenancy_tenant ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  group_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug), 
  KEY group_id (group_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_sitegroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug), 
  KEY parent_id (parent_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_region ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug), 
  KEY parent_id (parent_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_site ( 
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
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug), 
  KEY region_id (region_id),
  KEY group_id (group_id),
  KEY tenant_id (tenant_id),
  KEY status (status) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_location ( 
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
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug), 
  KEY site_id (site_id), 
  KEY parent_id (parent_id), 
  KEY tenant_id (tenant_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_rackrole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_rack ( 
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
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY site_id (site_id), 
  KEY location_id (location_id), 
  KEY tenant_id (tenant_id), 
  KEY role_id (role_id),
  KEY status (status)   
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_manufacturer ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_devicerole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  vm_role BOOLEAN DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_platform ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  manufacturer_id BIGINT DEFAULT NULL, 
  napalm_driver VARCHAR(50) DEFAULT NULL, 
  napalm_args VARCHAR(1024) DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY slug (slug), 
  KEY manufacturer_id (manufacturer_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_devicetype ( 
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
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY slug (slug), 
  KEY model (model), 
  KEY manufacturer_id (manufacturer_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_virtualchassis ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  domain VARCHAR(30) DEFAULT NULL, 
  master_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY name (name), 
  KEY master_id (master_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_device ( 
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
  primary_ip VARCHAR(43) DEFAULT NULL COLLATE utf8mb4_unicode_ci, 
  primary_ip4_id BIGINT DEFAULT NULL, 
  primary_ip6_id BIGINT DEFAULT NULL, 
  cluster_id BIGINT DEFAULT NULL, 
  virtual_chassis_id BIGINT DEFAULT NULL, 
  vc_position SMALLINT DEFAULT NULL, 
  vc_priority SMALLINT DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  local_context_data VARCHAR(1024) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name), 
  KEY device_type_id (device_type_id), 
  KEY device_role_id (device_role_id), 
  KEY tenant_id (tenant_id), 
  KEY platform_id (platform_id), 
  KEY site_id (site_id), 
  KEY rack_id (rack_id), 
  KEY parent_device_id (parent_device_id), 
  KEY primary_ip (primary_ip), 
  KEY cluster_id (cluster_id), 
  KEY virtual_chassis_id (virtual_chassis_id),
  KEY status (status)   
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_dcim_interface ( 
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
  mac_address VARCHAR(12) DEFAULT NULL COLLATE utf8mb4_unicode_ci, 
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
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY name (name), 
  KEY device_id (device_id), 
  KEY parent_id (parent_id), 
  KEY bridge_id (bridge_id), 
  KEY lag_id (lag_id), 
  KEY mac_address (mac_address), 
  KEY cable_id (cable_id), 
  KEY wireless_link_id (wireless_link_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_vrf ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  rd VARCHAR(21) DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  enforce_unique BOOLEAN DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY name (name),   
  KEY tenant_id (tenant_id),
  KEY enforce_unique (enforce_unique) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_role ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  weight SMALLINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name),
  KEY slug (slug)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_vlangroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  scope_type VARCHAR(100) DEFAULT NULL, 
  scope_id BIGINT DEFAULT NULL,
  custom_fields VARCHAR(1024) DEFAULT NULL,  
  KEY name (name),
  KEY slug (slug),
  KEY scope_id (scope_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_vlan ( 
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
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY name (name),
  KEY slug (slug),
  KEY site_id (site_id), 
  KEY group_id (group_id), 
  KEY vid (vid), 
  KEY tenant_id (tenant_id), 
  KEY role_id (role_id), 
  KEY status (status) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_prefix ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  prefix VARCHAR(43) DEFAULT NULL COLLATE utf8mb4_unicode_ci, 
  site_id BIGINT DEFAULT NULL,
  vrf_id BIGINT DEFAULT NULL,
  tenant_id BIGINT DEFAULT NULL,
  vlan_id BIGINT DEFAULT NULL,
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  is_pool BOOLEAN DEFAULT NULL, 
  mark_utilized BOOLEAN DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY prefix (prefix), 
  KEY site_id (site_id), 
  KEY vrf_id (vrf_id), 
  KEY tenant_id (tenant_id), 
  KEY vlan_id (vlan_id), 
  KEY status (status), 
  KEY role_id (role_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_iprange ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  start_address VARCHAR(39) DEFAULT NULL COLLATE utf8mb4_unicode_ci, 
  end_address VARCHAR(39) DEFAULT NULL COLLATE utf8mb4_unicode_ci, 
  size INT DEFAULT NULL, 
  vrf_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL,
  KEY start_address (start_address), 
  KEY end_address (end_address), 
  KEY vrf_id (vrf_id), 
  KEY tenant_id (tenant_id), 
  KEY status (status), 
  KEY role_id (role_id) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_netbox_ipam_ipaddress ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated DATETIME DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  address VARCHAR(43) DEFAULT NULL COLLATE utf8mb4_unicode_ci, 
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
  custom_fields VARCHAR(1024) DEFAULT NULL, 
  KEY address (address), 
  KEY vrf_id (vrf_id), 
  KEY tenant_id (tenant_id), 
  KEY status (status) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_script_exists (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  type VARCHAR(20) NOT NULL, 
  port INT UNSIGNED NOT NULL,
  script VARCHAR(100) NOT NULL, 
  UNIQUE KEY typeportscript (type, port, script), 
  KEY type (type), 
  KEY port (port), 
  KEY script (script) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_osmatch_exists (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  name varchar(256) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_script_value_exists (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  script VARCHAR(100) NOT NULL, 
  value varchar(700) NOT NULL,  
  UNIQUE KEY scriptvalue (script, value), 
  KEY script (script), 
  KEY value (value) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_service_product (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  type VARCHAR(20) NOT NULL, 
  port INT UNSIGNED NOT NULL,
  product varchar(100) NOT NULL, 
  UNIQUE KEY typeportproduct (type, port, product), 
  KEY type (type), 
  KEY port (port), 
  KEY product (product) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_service_extrainfo (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  type VARCHAR(20) NOT NULL, 
  port INT UNSIGNED NOT NULL,
  extrainfo varchar(256) NOT NULL, 
  UNIQUE KEY typeportextrainfo (type, port, extrainfo), 
  KEY type (type), 
  KEY port (port), 
  KEY extrainfo (extrainfo) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_service_cpe (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  type VARCHAR(20) NOT NULL, 
  port INT UNSIGNED NOT NULL,
  cpe varchar(100) NOT NULL, 
  UNIQUE KEY typeportcpe (type, port, cpe), 
  KEY type (type), 
  KEY port (port), 
  KEY product (cpe) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_osclass_type (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  type varchar(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_osclass_vendor (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  vendor varchar(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_osclass_osfamily (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  osfamily varchar(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_osclass_cpe (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  cpe varchar(100) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_word_source (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  srcid INT UNSIGNED NOT NULL,
  groupname VARCHAR(100) NOT NULL, 
  UNIQUE KEY srcgroup (srcid, groupname), 
  KEY srcid (srcid), 
  KEY groupname (groupname) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS info_nnml_word (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  srcid INT UNSIGNED NOT NULL,
  groupname VARCHAR(100) NOT NULL, 
  word VARCHAR(256) NOT NULL, 
  UNIQUE KEY srcgroupword (srcid, groupname, word), 
  KEY srcgroup (srcid, groupname), 
  KEY srcid (srcid), 
  KEY groupname (groupname), 
  KEY word (word), 
  CONSTRAINT srcid_inw FOREIGN KEY (srcid) REFERENCES ref_nnml_word_source (srcid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

