CREATE TABLE IF NOT EXISTS ref_tenantgroup ( 
  tenantgroupid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  tenantgroup VARCHAR(100) NOT NULL UNIQUE, 
  tenantgroup_alias VARCHAR(100) NOT NULL UNIQUE, 
  parentid INT UNSIGNED DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  CONSTRAINT parentid_rtg FOREIGN KEY (parentid) REFERENCES ref_tenantgroup (tenantgroupid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_tenant ( 
  tenantid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  tenant VARCHAR(100) DEFAULT NULL UNIQUE, 
  tenant_alias VARCHAR(100) DEFAULT NULL UNIQUE, 
  tenantgroupid INT UNSIGNED DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  CONSTRAINT tenantgroupid_rt FOREIGN KEY (tenantgroupid) REFERENCES ref_tenantgroup (tenantgroupid) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_sitegroup ( 
  sitegroupid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  sitegroup VARCHAR(100) DEFAULT NULL UNIQUE, 
  sitegroup_alias VARCHAR(100) DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  parentid INT UNSIGNED DEFAULT NULL, 
  CONSTRAINT parentid_rsg FOREIGN KEY (parentid) REFERENCES ref_sitegroup (sitegroupid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_region ( 
  regionid INT UNSIGNED NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  region VARCHAR(100) DEFAULT NULL UNIQUE, 
  region_alias VARCHAR(100) DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  parentid INT UNSIGNED DEFAULT NULL, 
  CONSTRAINT parentid_rr FOREIGN KEY (parentid) REFERENCES ref_region (regionid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_site ( 
  siteid INT UNSIGNED NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  site VARCHAR(100) NOT NULL UNIQUE, 
  site_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  active BOOLEAN DEFAULT TRUE,   
  regionid INT UNSIGNED DEFAULT NULL, 
  groupid INT UNSIGNED DEFAULT NULL, 
  tenantid INT UNSIGNED DEFAULT NULL, 
  facility VARCHAR(50) DEFAULT NULL, 
  time_zone VARCHAR(63) DEFAULT NULL, 
  physical_address VARCHAR(200) DEFAULT NULL, 
  shipping_address VARCHAR(200) DEFAULT NULL, 
  latitude NUMERIC(8,6) DEFAULT NULL, 
  longitude NUMERIC(9,6) DEFAULT NULL, 
  contact_name VARCHAR(50) DEFAULT NULL, 
  contact_phone VARCHAR(20) DEFAULT NULL, 
  contact_email VARCHAR(254) DEFAULT NULL, 
  importance DOUBLE NOT NULL DEFAULT 1,  
  comments TEXT DEFAULT NULL, 
  KEY active (active), 
  CONSTRAINT regionid_rs FOREIGN KEY (regionid) REFERENCES ref_region (regionid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT groupid_rs FOREIGN KEY (groupid) REFERENCES ref_sitegroup (sitegroupid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rs FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_manufacturer ( 
  manufacturerid INT UNSIGNED NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  manufacturer VARCHAR(100) NOT NULL UNIQUE, 
  manufacturer_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_devicerole ( 
  deviceroleid INT UNSIGNED NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  devicerole VARCHAR(100) NOT NULL UNIQUE, 
  devicerole_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  vm_role BOOLEAN DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_platform ( 
  platformid INT UNSIGNED NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  platform VARCHAR(100) NOT NULL UNIQUE, 
  platform_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  manufacturerid INT UNSIGNED DEFAULT NULL, 
  CONSTRAINT manufacturerid_rp FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_subdevice_role ( 
  subdevice_roleid INT UNSIGNED NOT NULL PRIMARY KEY, 
  subdevice_role VARCHAR(100) NOT NULL UNIQUE,
  subdevice_role_alias VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB; 

CREATE TABLE IF NOT EXISTS ref_devicetype ( 
  devicetypeid INT UNSIGNED NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  model VARCHAR(100) NOT NULL, 
  model_alias VARCHAR(100) NOT NULL, 
  devicetype_alias VARCHAR(256) NOT NULL UNIQUE, 
  manufacturerid INT UNSIGNED DEFAULT NULL, 
  part_number VARCHAR(50) DEFAULT NULL, 
  u_height SMALLINT DEFAULT NULL, 
  is_full_depth BOOLEAN DEFAULT NULL, 
  airflow VARCHAR(50) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  parentid INT UNSIGNED NOT NULL DEFAULT 0, 
  UNIQUE KEY modelparent (model, parentid), 
  UNIQUE KEY modelaliasparent (model_alias, parentid), 
  KEY model (model), 
  KEY model_alias (model_alias), 
  KEY manufacturerid (manufacturerid), 
  KEY parentid (parentid), 
  CONSTRAINT parentid_rd FOREIGN KEY (parentid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_rd FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_vrf ( 
  vrfid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  vrf VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  tenantid INT UNSIGNED DEFAULT NULL, 
  enforce_unique BOOLEAN DEFAULT NULL, 
  KEY enforce_unique (enforce_unique),
  CONSTRAINT tenantid_rv FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_subnet_role ( 
  subnet_roleid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  subnet_role VARCHAR(100) NOT NULL UNIQUE, 
  subnet_role_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_vlangroup ( 
  vlangroupid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  vlangroup VARCHAR(100) NOT NULL UNIQUE, 
  vlangroup_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL,
  siteid INT UNSIGNED DEFAULT NULL, 
  CONSTRAINT siteid_rvg FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_vlan ( 
  vlanid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  vlan VARCHAR(100) NOT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  siteid INT UNSIGNED DEFAULT NULL, 
  groupid INT UNSIGNED DEFAULT NULL, 
  vid SMALLINT NOT NULL, 
  tenantid INT UNSIGNED DEFAULT NULL, 
  roleid INT UNSIGNED DEFAULT NULL, 
  active BOOLEAN DEFAULT TRUE,   
  UNIQUE KEY vidsite (vid, siteid), 
  KEY vid (vid), 
  KEY vlan (vlan), 
  KEY active (active), 
  CONSTRAINT siteid_rvl FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT groupid_rvl FOREIGN KEY (groupid) REFERENCES ref_vlangroup (vlangroupid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rvl FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_rvl FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_ipfamily ( 
  familyid INT UNSIGNED NOT NULL PRIMARY KEY, 
  family VARCHAR(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_ipprefix ( 
  ipprefixid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  familyid INT UNSIGNED NOT NULL, 
  prefix VARCHAR(43) NOT NULL COLLATE utf8mb4_unicode_ci, 
  siteid INT UNSIGNED DEFAULT NULL, 
  vrfid INT UNSIGNED NOT NULL DEFAULT 0, 
  tenantid INT UNSIGNED DEFAULT NULL, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  active BOOLEAN DEFAULT TRUE, 
  roleid INT UNSIGNED DEFAULT NULL, 
  is_pool BOOLEAN DEFAULT NULL, 
  netnum SMALLINT NOT NULL, 
  startip VARCHAR(39) NOT NULL COLLATE utf8mb4_unicode_ci, 
  endip VARCHAR(39) NOT NULL COLLATE utf8mb4_unicode_ci, 
  startipnum BIGINT UNSIGNED NOT NULL, 
  endipnum BIGINT UNSIGNED NOT NULL, 
  UNIQUE KEY prefixvrf (prefix, vrfid), 
  KEY active (active), 
  KEY is_pool (is_pool), 
  KEY prefix (prefix), 
  KEY netnum (netnum), 
  KEY startendip (startip, endip), 
  KEY startendipnum (startipnum, endipnum), 
  KEY siteipnum (siteid, startipnum, endipnum), 
  CONSTRAINT familyid_rip FOREIGN KEY (familyid) REFERENCES ref_ipfamily (familyid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT siteid_rip FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vrfid_rip FOREIGN KEY (vrfid) REFERENCES ref_vrf (vrfid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rip FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vlanid_rip FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_rip FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_iprange ( 
  iprangeid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  familyid INT UNSIGNED NOT NULL, 
  start_address VARCHAR(43) NOT NULL COLLATE utf8mb4_unicode_ci, 
  end_address VARCHAR(43) NOT NULL COLLATE utf8mb4_unicode_ci, 
  netnum SMALLINT NOT NULL, 
  startip VARCHAR(39) NOT NULL COLLATE utf8mb4_unicode_ci, 
  endip VARCHAR(39) NOT NULL COLLATE utf8mb4_unicode_ci, 
  startipnum BIGINT UNSIGNED NOT NULL, 
  endipnum BIGINT UNSIGNED NOT NULL, 
  size INT NOT NULL, 
  vrfid INT UNSIGNED NOT NULL DEFAULT 0, 
  tenantid INT UNSIGNED DEFAULT NULL, 
  active BOOLEAN DEFAULT TRUE, 
  roleid INT UNSIGNED DEFAULT NULL,   
  UNIQUE KEY startipvrf (startip, endip, vrfid), 
  KEY active (active), 
  KEY start_address (start_address), 
  KEY end_address (end_address), 
  KEY startendip (startip, endip), 
  KEY startendipnum (startipnum, endipnum), 
  CONSTRAINT familyid_rir FOREIGN KEY (familyid) REFERENCES ref_ipfamily (familyid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vrfid_rir FOREIGN KEY (vrfid) REFERENCES ref_vrf (vrfid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rir FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_rir FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_ipaddress_role ( 
  ipaddress_roleid INT UNSIGNED NOT NULL PRIMARY KEY, 
  ipaddress_role VARCHAR(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_ipaddress ( 
  ipaddressid INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  familyid INT UNSIGNED NOT NULL, 
  address VARCHAR(43) NOT NULL COLLATE utf8mb4_unicode_ci, 
  netnum SMALLINT NOT NULL, 
  ip VARCHAR(39) NOT NULL COLLATE utf8mb4_unicode_ci, 
  ipnum BIGINT UNSIGNED NOT NULL, 
  vrfid INT UNSIGNED NOT NULL DEFAULT 0, 
  tenantid INT UNSIGNED DEFAULT NULL, 
  active BOOLEAN DEFAULT TRUE, 
  iproleid INT UNSIGNED DEFAULT NULL, 
  UNIQUE KEY ipvrf (ip, vrfid), 
  KEY active (active), 
  KEY address (address), 
  KEY ip (ip), 
  KEY netnum (netnum), 
  CONSTRAINT familyid_ria FOREIGN KEY (familyid) REFERENCES ref_ipfamily (familyid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT iproleid_ria FOREIGN KEY (iproleid) REFERENCES ref_ipaddress_role (ipaddress_roleid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vrfid_ria FOREIGN KEY (vrfid) REFERENCES ref_vrf (vrfid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_ria FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_ipaddress_source ( 
  sourceid INT UNSIGNED NOT NULL PRIMARY KEY,
  source VARCHAR(100) NOT NULL UNIQUE, 
  tablename VARCHAR(100) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `ref_scan_ip_info` (
  `infoid` int unsigned NOT NULL PRIMARY KEY,
  `info` varchar(256) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_scan_snmp_oid (
  oidid INT NOT NULL PRIMARY KEY, 
  name VARCHAR(256) NOT NULL UNIQUE, 
  oid VARCHAR(256) NOT NULL UNIQUE, 
  command VARCHAR(10) NOT NULL, 
  prescan BOOLEAN NOT NULL DEFAULT FALSE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_static_device (
  deviceid INT NOT NULL PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  active BOOLEAN NOT NULL DEFAULT TRUE, 
  snmp_community VARCHAR(256) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_wlc_type (
  wlcid INT NOT NULL PRIMARY KEY, 
  wlc_type VARCHAR(50) NOT NULL UNIQUE, 
  wlc_name VARCHAR(256) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_mac_manufacturer_map (
  mapid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  organization VARCHAR(256) NOT NULL UNIQUE, 
  manufacturerid INT UNSIGNED NOT NULL, 
  KEY manufacturerid (manufacturerid), 
  CONSTRAINT manufacturerid_rmmm FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_nnml_input_type (
  typeid INT UNSIGNED NOT NULL PRIMARY KEY, 
  input_type VARCHAR(50) NOT NULL UNIQUE, 
  description VARCHAR(256) DEFAULT NULL 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_nnml_ip_exists_table (
  id INT UNSIGNED NOT NULL PRIMARY KEY, 
  tablename VARCHAR(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_nnml_mac_exists_table (
  id INT UNSIGNED NOT NULL PRIMARY KEY, 
  tablename VARCHAR(50) NOT NULL UNIQUE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_nnml_word_source ( 
  srcid INT UNSIGNED NOT NULL PRIMARY KEY, 
  src_name VARCHAR(50) NOT NULL UNIQUE, 
  query VARCHAR(1000) NOT NULL, 
  min_word_num SMALLINT NOT NULL DEFAULT 3,
  min_word_percent FLOAT NOT NULL DEFAULT 0.5,
  max_word_percent FLOAT NOT NULL DEFAULT 95.0
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ref_osclass_manufacturer_map (
  mapid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  vendor VARCHAR(50) NOT NULL UNIQUE, 
  manufacturerid INT UNSIGNED NOT NULL, 
  KEY manufacturerid (manufacturerid), 
  CONSTRAINT manufacturerid_romm FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;
