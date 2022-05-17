CREATE TABLE IF NOT EXISTS ref_nnml_script_exists_table (
  id SERIAL NOT NULL PRIMARY KEY, 
  type VARCHAR(20) NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  script VARCHAR(100) NOT NULL 
);
CREATE TABLE IF NOT EXISTS ref_tenantgroup ( 
  tenantgroupid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  tenantgroup VARCHAR(100) NOT NULL UNIQUE, 
  tenantgroup_alias VARCHAR(100) NOT NULL UNIQUE, 
  parentid INT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  CONSTRAINT parentid_rtg FOREIGN KEY (parentid) REFERENCES ref_tenantgroup (tenantgroupid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_tenant ( 
  tenantid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  tenant VARCHAR(100) DEFAULT NULL UNIQUE, 
  tenant_alias VARCHAR(100) DEFAULT NULL UNIQUE, 
  tenantgroupid INT DEFAULT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  CONSTRAINT tenantgroupid_rt FOREIGN KEY (tenantgroupid) REFERENCES ref_tenantgroup (tenantgroupid) ON DELETE SET NULL ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_sitegroup ( 
  sitegroupid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  sitegroup VARCHAR(100) DEFAULT NULL UNIQUE, 
  sitegroup_alias VARCHAR(100) DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  parentid INT DEFAULT NULL, 
  CONSTRAINT parentid_rsg FOREIGN KEY (parentid) REFERENCES ref_sitegroup (sitegroupid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_region ( 
  regionid INT NOT NULL PRIMARY KEY CHECK (regionid>=0), 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  region VARCHAR(100) DEFAULT NULL UNIQUE, 
  region_alias VARCHAR(100) DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  parentid INT DEFAULT NULL, 
  CONSTRAINT parentid_rr FOREIGN KEY (parentid) REFERENCES ref_region (regionid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_site ( 
  siteid INT NOT NULL PRIMARY KEY CHECK (siteid>=0), 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  site VARCHAR(100) NOT NULL UNIQUE, 
  site_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  active SMALLINT NOT NULL DEFAULT 1, 
  regionid INT DEFAULT NULL, 
  groupid INT DEFAULT NULL, 
  tenantid INT DEFAULT NULL, 
  facility VARCHAR(50) DEFAULT NULL, 
  time_zone VARCHAR(63) DEFAULT NULL, 
  physical_address VARCHAR(200) DEFAULT NULL, 
  shipping_address VARCHAR(200) DEFAULT NULL, 
  latitude NUMERIC(8,6) DEFAULT NULL, 
  longitude NUMERIC(9,6) DEFAULT NULL, 
  contact_name VARCHAR(50) DEFAULT NULL, 
  contact_phone VARCHAR(20) DEFAULT NULL, 
  contact_email VARCHAR(254) DEFAULT NULL, 
  importance REAL NOT NULL DEFAULT 1,  
  comments TEXT DEFAULT NULL, 
  CONSTRAINT regionid_rs FOREIGN KEY (regionid) REFERENCES ref_region (regionid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT groupid_rs FOREIGN KEY (groupid) REFERENCES ref_sitegroup (sitegroupid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rs FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE INDEX ON ref_site (active);

CREATE TABLE IF NOT EXISTS ref_manufacturer ( 
  manufacturerid INT NOT NULL PRIMARY KEY CHECK (manufacturerid>=0), 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  manufacturer VARCHAR(100) NOT NULL UNIQUE, 
  manufacturer_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS ref_devicerole ( 
  deviceroleid INT NOT NULL PRIMARY KEY CHECK (deviceroleid>=0), 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  devicerole VARCHAR(100) NOT NULL UNIQUE, 
  devicerole_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  vm_role SMALLINT DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS ref_platform ( 
  platformid INT NOT NULL PRIMARY KEY CHECK (platformid>=0), 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  platform VARCHAR(100) NOT NULL UNIQUE, 
  platform_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  manufacturerid INT DEFAULT NULL CHECK (manufacturerid>=0), 
  CONSTRAINT manufacturerid_rp FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_subdevice_role ( 
  subdevice_roleid INT NOT NULL PRIMARY KEY CHECK (subdevice_roleid>=0), 
  subdevice_role VARCHAR(100) NOT NULL UNIQUE,
  subdevice_role_alias VARCHAR(100) NOT NULL UNIQUE
); 

CREATE TABLE IF NOT EXISTS ref_devicetype ( 
  devicetypeid INT NOT NULL PRIMARY KEY CHECK (devicetypeid>=0), 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  model VARCHAR(100) NOT NULL UNIQUE, 
  model_alias VARCHAR(100) NOT NULL UNIQUE, 
  manufacturerid INT DEFAULT NULL CHECK (manufacturerid>=0), 
  subdevice_roleid INT DEFAULT NULL CHECK (subdevice_roleid>=0), 
  part_number VARCHAR(50) DEFAULT NULL, 
  u_height SMALLINT DEFAULT NULL, 
  is_full_depth SMALLINT DEFAULT NULL, 
  airflow VARCHAR(50) DEFAULT NULL, 
  comments TEXT DEFAULT NULL, 
  parentid INT DEFAULT NULL CHECK (parentid>=0), 
  CONSTRAINT parentid_rd FOREIGN KEY (parentid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_rd FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT subdevice_roleid_rd FOREIGN KEY (subdevice_roleid) REFERENCES ref_subdevice_role (subdevice_roleid) ON DELETE SET NULL ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_vrf ( 
  vrfid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  vrf VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  tenantid INT DEFAULT NULL CHECK (tenantid>=0), 
  enforce_unique SMALLINT DEFAULT NULL, 
  CONSTRAINT tenantid_rv FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON ref_vrf (enforce_unique);

CREATE TABLE IF NOT EXISTS ref_subnet_role ( 
  subnet_roleid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  subnet_role VARCHAR(100) NOT NULL UNIQUE, 
  subnet_role_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS ref_vlangroup ( 
  vlangroupid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  vlangroup VARCHAR(100) NOT NULL UNIQUE, 
  vlangroup_alias VARCHAR(100) NOT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL,
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  CONSTRAINT siteid_rvg FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS ref_vlan ( 
  vlanid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE,   
  vlan VARCHAR(100) NOT NULL, 
  description VARCHAR(200) DEFAULT NULL, 
  siteid INT DEFAULT NULL CHECK (siteid>=0), 
  groupid INT DEFAULT NULL CHECK (groupid>=0), 
  vid SMALLINT NOT NULL, 
  tenantid INT DEFAULT NULL CHECK (tenantid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  active SMALLINT DEFAULT 1, 
  CONSTRAINT siteid_rvl FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT groupid_rvl FOREIGN KEY (groupid) REFERENCES ref_vlangroup (vlangroupid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rvl FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_rvl FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON ref_vlan (vid, siteid);
CREATE INDEX ON ref_vlan (vid);
CREATE INDEX ON ref_vlan (vlan);
CREATE INDEX ON ref_vlan (active);

CREATE TABLE IF NOT EXISTS ref_ipfamily ( 
  familyid INT NOT NULL PRIMARY KEY CHECK (familyid>=0), 
  family VARCHAR(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS ref_ipprefix ( 
  ipprefixid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  familyid INT NOT NULL CHECK (familyid>=0), 
  prefix VARCHAR(43) NOT NULL, 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vrfid INT NOT NULL DEFAULT 0 CHECK (vrfid>=0), 
  tenantid INT DEFAULT NULL CHECK (tenantid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  active SMALLINT DEFAULT 1, 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  is_pool SMALLINT DEFAULT NULL, 
  netnum SMALLINT NOT NULL, 
  startip VARCHAR(39) NOT NULL, 
  endip VARCHAR(39) NOT NULL, 
  startipnum BIGINT NOT NULL, 
  endipnum BIGINT NOT NULL, 
  CONSTRAINT familyid_rip FOREIGN KEY (familyid) REFERENCES ref_ipfamily (familyid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT siteid_rip FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vrfid_rip FOREIGN KEY (vrfid) REFERENCES ref_vrf (vrfid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rip FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vlanid_rip FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_rip FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON ref_ipprefix (prefix, vrfid); 
CREATE INDEX ON ref_ipprefix (active); 
CREATE INDEX ON ref_ipprefix (is_pool); 
CREATE INDEX ON ref_ipprefix (prefix); 
CREATE INDEX ON ref_ipprefix (netnum); 
CREATE INDEX ON ref_ipprefix (startip, endip); 
CREATE INDEX ON ref_ipprefix (startipnum, endipnum); 
CREATE INDEX ON ref_ipprefix (siteid, startipnum, endipnum);

CREATE TABLE IF NOT EXISTS ref_iprange ( 
  iprangeid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  familyid INT NOT NULL CHECK (familyid>=0), 
  start_address VARCHAR(43) NOT NULL, 
  end_address VARCHAR(43) NOT NULL, 
  netnum SMALLINT NOT NULL, 
  startip VARCHAR(39) NOT NULL, 
  endip VARCHAR(39) NOT NULL, 
  startipnum BIGINT NOT NULL, 
  endipnum BIGINT NOT NULL, 
  size INT NOT NULL, 
  vrfid INT NOT NULL DEFAULT 0 CHECK (vrfid>=0), 
  tenantid INT DEFAULT NULL CHECK (tenantid>=0), 
  active SMALLINT DEFAULT 1, 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  CONSTRAINT familyid_rir FOREIGN KEY (familyid) REFERENCES ref_ipfamily (familyid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vrfid_rir FOREIGN KEY (vrfid) REFERENCES ref_vrf (vrfid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_rir FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_rir FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON ref_iprange (startip, endip, vrfid); 
CREATE INDEX ON ref_iprange (active); 
CREATE INDEX ON ref_iprange (start_address); 
CREATE INDEX ON ref_iprange (end_address); 
CREATE INDEX ON ref_iprange (startip, endip); 
CREATE INDEX ON ref_iprange (startipnum, endipnum); 

CREATE TABLE IF NOT EXISTS ref_ipaddress_role ( 
  ipaddress_roleid INT NOT NULL PRIMARY KEY CHECK (ipaddress_roleid>=0), 
  ipaddress_role VARCHAR(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS ref_ipaddress ( 
  ipaddressid SERIAL NOT NULL PRIMARY KEY, 
  netboxid BIGINT DEFAULT NULL UNIQUE, 
  description VARCHAR(200) DEFAULT NULL, 
  familyid INT NOT NULL CHECK (familyid>=0), 
  address VARCHAR(43) NOT NULL, 
  netnum SMALLINT NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT NOT NULL, 
  vrfid INT NOT NULL DEFAULT 0 CHECK (vrfid>=0), 
  tenantid INT DEFAULT NULL CHECK (tenantid>=0), 
  active SMALLINT DEFAULT 1, 
  iproleid INT DEFAULT NULL CHECK (iproleid>=0), 
  CONSTRAINT familyid_ria FOREIGN KEY (familyid) REFERENCES ref_ipfamily (familyid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT iproleid_ria FOREIGN KEY (iproleid) REFERENCES ref_ipaddress_role (ipaddress_roleid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT vrfid_ria FOREIGN KEY (vrfid) REFERENCES ref_vrf (vrfid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT tenantid_ria FOREIGN KEY (tenantid) REFERENCES ref_tenant (tenantid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON ref_ipaddress (ip, vrfid); 
CREATE INDEX ON ref_ipaddress (active); 
CREATE INDEX ON ref_ipaddress (address); 
CREATE INDEX ON ref_ipaddress (ip); 
CREATE INDEX ON ref_ipaddress (netnum); 

CREATE TABLE IF NOT EXISTS ref_ipaddress_source ( 
  sourceid INT NOT NULL PRIMARY KEY CHECK (sourceid>=0),
  description VARCHAR(100) NOT NULL UNIQUE, 
  tablename VARCHAR(100) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS ref_scan_ip_info (
  infoid INT NOT NULL PRIMARY KEY CHECK (infoid>=0), 
  info VARCHAR(256) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS ref_scan_snmp_oid (
  oidid INT NOT NULL PRIMARY KEY, 
  name VARCHAR(256) NOT NULL UNIQUE, 
  oid VARCHAR(256) NOT NULL UNIQUE, 
  command VARCHAR(10) NOT NULL, 
  prescan SMALLINT NOT NULL DEFAULT 0 
);

CREATE TABLE IF NOT EXISTS ref_static_device (
  deviceid SERIAL NOT NULL PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  active SMALLINT NOT NULL DEFAULT 1, 
  snmp_community VARCHAR(256) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS ref_wlc_type (
  wlcid INT NOT NULL PRIMARY KEY, 
  wlc_type VARCHAR(50) NOT NULL UNIQUE, 
  wlc_name VARCHAR(256) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS ref_mac_manufacturer_map (
  mapid SERIAL NOT NULL PRIMARY KEY, 
  organization VARCHAR(256) NOT NULL, 
  manufacturerid INT NOT NULL CHECK (manufacturerid>=0), 
  CONSTRAINT manufacturerid_rmmm FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON ref_mac_manufacturer_map (organization, manufacturerid); 
CREATE INDEX ON ref_mac_manufacturer_map (organization); 
CREATE INDEX ON ref_mac_manufacturer_map (manufacturerid); 

CREATE TABLE IF NOT EXISTS ref_nnml_input_type (
  typeid INT NOT NULL PRIMARY KEY CHECK (typeid>=0), 
  input_type VARCHAR(50) NOT NULL UNIQUE, 
  description VARCHAR(256) DEFAULT NULL 
);

CREATE TABLE IF NOT EXISTS ref_nnml_ip_exists_table (
  id INT NOT NULL PRIMARY KEY CHECK (id>=0), 
  tablename VARCHAR(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS ref_nnml_mac_exists_table (
  id INT NOT NULL PRIMARY KEY CHECK (id>=0), 
  tablename VARCHAR(50) NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS ref_nnml_word_source ( 
  srcid INT NOT NULL PRIMARY KEY CHECK (srcid>=0), 
  src_name VARCHAR(50) NOT NULL UNIQUE, 
  query VARCHAR(1000) NOT NULL, 
  min_word_num SMALLINT NOT NULL DEFAULT 3,
  min_word_percent FLOAT NOT NULL DEFAULT 0.5,
  max_word_percent FLOAT NOT NULL DEFAULT 95.0
);