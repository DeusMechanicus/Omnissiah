CREATE TABLE IF NOT EXISTS info_mac (
  assignmentid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  assignment VARCHAR(12) NOT NULL UNIQUE, 
  registry VARCHAR(16) NOT NULL, 
  organization VARCHAR(256) NOT NULL, 
  address VARCHAR(300) DEFAULT NULL, 
  assignment_len SMALLINT NOT NULL CHECK (assignment_len>=0), 
  first_mac CHAR(12) NOT NULL, 
  last_mac CHAR(12) NOT NULL, 
  first_mac_num BIGINT NOT NULL CHECK (first_mac_num>=0), 
  last_mac_num BIGINT NOT NULL CHECK (last_mac_num>=0));
CREATE INDEX ON info_mac (registry);
CREATE INDEX ON info_mac (organization);
CREATE INDEX ON info_mac (assignment_len);
CREATE INDEX ON info_mac (first_mac, last_mac);
CREATE INDEX ON info_mac (first_mac_num, last_mac_num);

CREATE TABLE IF NOT EXISTS info_netbox_tenancy_tenantgroup ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL, 
  slug VARCHAR(100) NOT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  level INT NOT NULL DEFAULT 0, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_tenancy_tenantgroup (name);
CREATE INDEX ON info_netbox_tenancy_tenantgroup (slug);
CREATE INDEX ON info_netbox_tenancy_tenantgroup (parent_id);

CREATE TABLE IF NOT EXISTS info_netbox_tenancy_tenant ( 
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
CREATE INDEX ON info_netbox_tenancy_tenant (name);
CREATE INDEX ON info_netbox_tenancy_tenant (slug);
CREATE INDEX ON info_netbox_tenancy_tenant (group_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_sitegroup ( 
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
CREATE INDEX ON info_netbox_dcim_sitegroup (name);
CREATE INDEX ON info_netbox_dcim_sitegroup (slug);
CREATE INDEX ON info_netbox_dcim_sitegroup (parent_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_region ( 
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
CREATE INDEX ON info_netbox_dcim_region (name);
CREATE INDEX ON info_netbox_dcim_region (slug);
CREATE INDEX ON info_netbox_dcim_region (parent_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_site ( 
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
CREATE INDEX ON info_netbox_dcim_site (name);
CREATE INDEX ON info_netbox_dcim_site (slug);
CREATE INDEX ON info_netbox_dcim_site (region_id);
CREATE INDEX ON info_netbox_dcim_site (group_id);
CREATE INDEX ON info_netbox_dcim_site (tenant_id);
CREATE INDEX ON info_netbox_dcim_site (status);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_location ( 
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
CREATE INDEX ON info_netbox_dcim_location (name);
CREATE INDEX ON info_netbox_dcim_location (slug);
CREATE INDEX ON info_netbox_dcim_location (site_id);
CREATE INDEX ON info_netbox_dcim_location (parent_id);
CREATE INDEX ON info_netbox_dcim_location (tenant_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_rackrole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);
CREATE INDEX ON info_netbox_dcim_rackrole (name);
CREATE INDEX ON info_netbox_dcim_rackrole (slug);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_rack ( 
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
  desc_units SMALLINT DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  outer_width SMALLINT DEFAULT NULL, 
  outer_depth SMALLINT DEFAULT NULL, 
  outer_unit VARCHAR(50) DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);
CREATE INDEX ON info_netbox_dcim_rack (name);
CREATE INDEX ON info_netbox_dcim_rack (site_id);
CREATE INDEX ON info_netbox_dcim_rack (location_id);
CREATE INDEX ON info_netbox_dcim_rack (tenant_id);
CREATE INDEX ON info_netbox_dcim_rack (role_id);
CREATE INDEX ON info_netbox_dcim_rack (status);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_manufacturer ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);
CREATE INDEX ON info_netbox_dcim_manufacturer (name);
CREATE INDEX ON info_netbox_dcim_manufacturer (slug);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_devicerole ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  color VARCHAR(6) DEFAULT NULL, 
  vm_role SMALLINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);
CREATE INDEX ON info_netbox_dcim_devicerole (name);
CREATE INDEX ON info_netbox_dcim_devicerole (slug);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_platform ( 
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
CREATE INDEX ON info_netbox_dcim_platform (name);
CREATE INDEX ON info_netbox_dcim_platform (slug);
CREATE INDEX ON info_netbox_dcim_platform (manufacturer_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_devicetype ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  slug VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  manufacturer_id BIGINT DEFAULT NULL, 
  model VARCHAR(100) DEFAULT NULL, 
  part_number VARCHAR(50) DEFAULT NULL, 
  u_height SMALLINT DEFAULT NULL, 
  is_full_depth SMALLINT DEFAULT NULL, 
  subdevice_role VARCHAR(50) DEFAULT NULL, 
  airflow VARCHAR(50) DEFAULT NULL, 
  front_image VARCHAR(256) DEFAULT NULL, 
  rear_image VARCHAR(256) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_dcim_devicetype (slug);
CREATE INDEX ON info_netbox_dcim_devicetype (model);
CREATE INDEX ON info_netbox_dcim_devicetype (manufacturer_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_virtualchassis ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  domain VARCHAR(30) DEFAULT NULL, 
  master_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_dcim_virtualchassis (name);
CREATE INDEX ON info_netbox_dcim_virtualchassis (master_id);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_device ( 
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
CREATE INDEX ON info_netbox_dcim_device (name);
CREATE INDEX ON info_netbox_dcim_device (device_type_id);
CREATE INDEX ON info_netbox_dcim_device (device_role_id);
CREATE INDEX ON info_netbox_dcim_device (tenant_id);
CREATE INDEX ON info_netbox_dcim_device (platform_id);
CREATE INDEX ON info_netbox_dcim_device (site_id);
CREATE INDEX ON info_netbox_dcim_device (rack_id);
CREATE INDEX ON info_netbox_dcim_device (parent_device_id);
CREATE INDEX ON info_netbox_dcim_device (LOWER(primary_ip));
CREATE INDEX ON info_netbox_dcim_device (cluster_id);
CREATE INDEX ON info_netbox_dcim_device (virtual_chassis_id);
CREATE INDEX ON info_netbox_dcim_device (status);

CREATE TABLE IF NOT EXISTS info_netbox_dcim_interface ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(64) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  device_id BIGINT DEFAULT NULL, 
  type VARCHAR(50) DEFAULT NULL, 
  enabled SMALLINT DEFAULT NULL, 
  parent_id BIGINT DEFAULT NULL, 
  bridge_id BIGINT DEFAULT NULL, 
  lag_id BIGINT DEFAULT NULL, 
  mtu INT DEFAULT NULL, 
  mac_address VARCHAR(12) DEFAULT NULL, 
  wwn VARCHAR(23) DEFAULT NULL, 
  mgmt_only SMALLINT DEFAULT NULL, 
  mode VARCHAR(50) DEFAULT NULL, 
  rf_role VARCHAR(30) DEFAULT NULL, 
  rf_channel VARCHAR(50) DEFAULT NULL, 
  rf_channel_frequency NUMERIC(7,2) DEFAULT NULL, 
  rf_channel_width NUMERIC(7,3) DEFAULT NULL, 
  tx_power SMALLINT DEFAULT NULL, 
  untagged_vlan_id BIGINT DEFAULT NULL, 
  mark_connected SMALLINT DEFAULT NULL, 
  label VARCHAR(64) DEFAULT NULL, 
  cable_id BIGINT DEFAULT NULL, 
  wireless_link_id BIGINT DEFAULT NULL, 
  link_peer VARCHAR(100) DEFAULT NULL, 
  link_peer_type INT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_dcim_interface (name);
CREATE INDEX ON info_netbox_dcim_interface (device_id);
CREATE INDEX ON info_netbox_dcim_interface (parent_id);
CREATE INDEX ON info_netbox_dcim_interface (bridge_id);
CREATE INDEX ON info_netbox_dcim_interface (lag_id);
CREATE INDEX ON info_netbox_dcim_interface (UPPER(mac_address));
CREATE INDEX ON info_netbox_dcim_interface (cable_id);
CREATE INDEX ON info_netbox_dcim_interface (wireless_link_id);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_vrf ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  rd VARCHAR(21) DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  enforce_unique SMALLINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_ipam_vrf (name);
CREATE INDEX ON info_netbox_ipam_vrf (tenant_id);
CREATE INDEX ON info_netbox_ipam_vrf (enforce_unique);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_role ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  name VARCHAR(100) DEFAULT NULL, 
  slug VARCHAR(100) DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  weight SMALLINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL 
);
CREATE INDEX ON info_netbox_ipam_role (name);
CREATE INDEX ON info_netbox_ipam_role (slug);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_vlangroup ( 
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
CREATE INDEX ON info_netbox_ipam_vlangroup (name);
CREATE INDEX ON info_netbox_ipam_vlangroup (slug);
CREATE INDEX ON info_netbox_ipam_vlangroup (scope_id);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_vlan ( 
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
CREATE INDEX ON info_netbox_ipam_vlan (name);
CREATE INDEX ON info_netbox_ipam_vlan (slug);
CREATE INDEX ON info_netbox_ipam_vlan (site_id);
CREATE INDEX ON info_netbox_ipam_vlan (group_id);
CREATE INDEX ON info_netbox_ipam_vlan (vid);
CREATE INDEX ON info_netbox_ipam_vlan (tenant_id);
CREATE INDEX ON info_netbox_ipam_vlan (role_id);
CREATE INDEX ON info_netbox_ipam_vlan (status);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_prefix ( 
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
  is_pool SMALLINT DEFAULT NULL, 
  mark_utilized SMALLINT DEFAULT NULL, 
  level INT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_ipam_prefix (LOWER(prefix));
CREATE INDEX ON info_netbox_ipam_prefix (site_id);
CREATE INDEX ON info_netbox_ipam_prefix (vrf_id);
CREATE INDEX ON info_netbox_ipam_prefix (tenant_id);
CREATE INDEX ON info_netbox_ipam_prefix (vlan_id);
CREATE INDEX ON info_netbox_ipam_prefix (status);
CREATE INDEX ON info_netbox_ipam_prefix (role_id);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_iprange ( 
  id BIGINT NOT NULL PRIMARY KEY, 
  description VARCHAR(200) DEFAULT NULL, 
  created DATE DEFAULT NULL, 
  last_updated TIMESTAMP DEFAULT NULL, 
  family VARCHAR(50) DEFAULT NULL, 
  start_address VARCHAR(39) DEFAULT NULL, 
  end_address VARCHAR(39) DEFAULT NULL, 
  size INT DEFAULT NULL, 
  vrf_id BIGINT DEFAULT NULL, 
  tenant_id BIGINT DEFAULT NULL, 
  status VARCHAR(50) DEFAULT NULL, 
  role_id BIGINT DEFAULT NULL, 
  custom_fields VARCHAR(1024) DEFAULT NULL
);
CREATE INDEX ON info_netbox_ipam_iprange (LOWER(start_address));
CREATE INDEX ON info_netbox_ipam_iprange (LOWER(end_address));
CREATE INDEX ON info_netbox_ipam_iprange (vrf_id);
CREATE INDEX ON info_netbox_ipam_iprange (tenant_id);
CREATE INDEX ON info_netbox_ipam_iprange (status);
CREATE INDEX ON info_netbox_ipam_iprange (role_id);

CREATE TABLE IF NOT EXISTS info_netbox_ipam_ipaddress ( 
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
CREATE INDEX ON info_netbox_ipam_ipaddress (LOWER(address));
CREATE INDEX ON info_netbox_ipam_ipaddress (vrf_id);
CREATE INDEX ON info_netbox_ipam_ipaddress (tenant_id);
CREATE INDEX ON info_netbox_ipam_ipaddress (status);

CREATE TABLE IF NOT EXISTS info_nnml_script_exists (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  type VARCHAR(20) NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  script VARCHAR(100) NOT NULL 
);
CREATE UNIQUE INDEX ON info_nnml_script_exists (type, port, script); 
CREATE INDEX ON info_nnml_script_exists (type); 
CREATE INDEX ON info_nnml_script_exists (port); 
CREATE INDEX ON info_nnml_script_exists (script); 

CREATE TABLE IF NOT EXISTS info_nnml_osmatch_exists (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  name varchar(256) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS info_nnml_script_value_exists (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  script VARCHAR(100) NOT NULL, 
  value varchar(700) NOT NULL 
);
CREATE UNIQUE INDEX ON info_nnml_script_value_exists (script, value);
CREATE INDEX ON info_nnml_script_value_exists (script);
CREATE INDEX ON info_nnml_script_value_exists (value);

CREATE TABLE IF NOT EXISTS info_nnml_service_product (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  type VARCHAR(20) NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  product varchar(100) NOT NULL 
);
CREATE UNIQUE INDEX ON info_nnml_service_product (type, port, product);
CREATE INDEX ON info_nnml_service_product (type);
CREATE INDEX ON info_nnml_service_product (port);
CREATE INDEX ON info_nnml_service_product (product);

CREATE TABLE IF NOT EXISTS info_nnml_service_extrainfo (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  type VARCHAR(20) NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  extrainfo varchar(256) NOT NULL 
);
CREATE UNIQUE INDEX ON info_nnml_service_extrainfo (type, port, extrainfo);
CREATE INDEX ON info_nnml_service_extrainfo (type);
CREATE INDEX ON info_nnml_service_extrainfo (port);
CREATE INDEX ON info_nnml_service_extrainfo (extrainfo);

CREATE TABLE IF NOT EXISTS info_nnml_service_cpe (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  type VARCHAR(20) NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  cpe varchar(100) NOT NULL 
);
CREATE UNIQUE INDEX ON info_nnml_service_cpe (type, port, cpe);
CREATE INDEX ON info_nnml_service_cpe (type);
CREATE INDEX ON info_nnml_service_cpe (port);
CREATE INDEX ON info_nnml_service_cpe (cpe);

CREATE TABLE IF NOT EXISTS info_nnml_osclass_type (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  type varchar(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS info_nnml_osclass_vendor (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  vendor varchar(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS info_nnml_osclass_osfamily (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  osfamily varchar(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS info_nnml_osclass_cpe (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  cpe varchar(100) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS info_nnml_word (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  srcid INT NOT NULL CHECK (srcid>=0),
  groupname VARCHAR(100) NOT NULL, 
  word VARCHAR(256) NOT NULL, 
  CONSTRAINT srcid_inw FOREIGN KEY (srcid) REFERENCES ref_nnml_word_source (srcid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON info_nnml_word (srcid, groupname, word);
CREATE INDEX ON info_nnml_word (srcid, groupname);
CREATE INDEX ON info_nnml_word (srcid);
CREATE INDEX ON info_nnml_word (groupname);
CREATE INDEX ON info_nnml_word (word);

