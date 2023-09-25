CREATE TABLE IF NOT EXISTS main_host ( 
  hostid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostuuid VARCHAR(256) NOT NULL, 
  idtype INT NOT NULL CHECK (idtype>=0), 
  ip VARCHAR(39) DEFAULT NULL, 
  mac VARCHAR(12) DEFAULT NULL, 
  name varchar(256) DEFAULT NULL,
  hostname varchar(100) DEFAULT NULL,
  manufacturerid INT DEFAULT NULL CHECK (manufacturerid>=0),
  devicetypeid INT NOT NULL CHECK (devicetypeid>=0), 
  controllerid BIGINT DEFAULT NULL, 
  idoncontroller VARCHAR(256) DEFAULT NULL, 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  ispublic SMALLINT DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  snmp_community VARCHAR(50) DEFAULT NULL,
  change_delay SMALLINT NOT NULL, 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  CONSTRAINT roleid_mh FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_mh FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_mh FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT devicetypeid_mh FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_mh FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT controllerid_mh FOREIGN KEY (controllerid) REFERENCES main_host (hostid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT idtype_mh FOREIGN KEY (idtype) REFERENCES ref_host_idtype (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT siteid_mh FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_host (hostuuid, idtype);
CREATE INDEX ON main_host (hostuuid);
CREATE INDEX ON main_host (idtype);
CREATE INDEX ON main_host (ip);
CREATE INDEX ON main_host (mac);
CREATE INDEX ON main_host (name);
CREATE INDEX ON main_host (manufacturerid);
CREATE INDEX ON main_host (devicetypeid);
CREATE INDEX ON main_host (controllerid);
CREATE INDEX ON main_host (ipprefixid);
CREATE INDEX ON main_host (roleid);
CREATE INDEX ON main_host (macvendorid);
CREATE INDEX ON main_host (active);
CREATE INDEX ON main_host (last_active);
CREATE INDEX ON main_host (change_delay);
CREATE INDEX ON main_host (siteid);

CREATE TABLE IF NOT EXISTS main_host_uuid ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL, 
  uuid_type INT NOT NULL CHECK (uuid_type>=0), 
  uuid VARCHAR(256) NOT NULL, 
  CONSTRAINT hostid_mhu FOREIGN KEY (hostid) REFERENCES main_host (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT uuid_type_mhu FOREIGN KEY (uuid_type) REFERENCES ref_host_uuid (id) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_host_uuid (uuid_type, uuid);
CREATE INDEX ON main_host_uuid (uuid_type);
CREATE INDEX ON main_host_uuid (hostid);
CREATE INDEX ON main_host_uuid (uuid);

CREATE TABLE IF NOT EXISTS main_host_link ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL, 
  linkid INT NOT NULL CHECK (linkid>=0), 
  uuid VARCHAR(256) NOT NULL, 
  CONSTRAINT hostid_mhl FOREIGN KEY (hostid) REFERENCES main_host (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT linkid_mhl FOREIGN KEY (linkid) REFERENCES ref_host_link (linkid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_host_link (hostid, linkid);
CREATE INDEX ON main_host_link (linkid);
CREATE INDEX ON main_host_link (hostid);
CREATE INDEX ON main_host_link (uuid);

CREATE TABLE IF NOT EXISTS main_if (
  ifid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  device VARCHAR(39) NOT NULL, 
  ifindex INT NOT NULL CHECK (ifindex>=0), 
  ifdescr VARCHAR(256) DEFAULT NULL,
  ifname VARCHAR(100) DEFAULT NULL,
  ifalias VARCHAR(256) DEFAULT NULL,
  ifadminstatus SMALLINT NOT NULL DEFAULT 2 CHECK (ifadminstatus>=0), 
  ifoperstatus SMALLINT NOT NULL DEFAULT 4 CHECK (ifoperstatus>=0), 
  ip VARCHAR(39) DEFAULT NULL, 
  netmask VARCHAR(39) DEFAULT NULL, 
  netnum INT DEFAULT NULL CHECK (netnum>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  connectedto BIGINT DEFAULT NULL, 
  macs INT NOT NULL DEFAULT 0 CHECK (macs>=0),
  ifphysaddress VARCHAR(12) DEFAULT NULL, 
  ifphysaddressnum BIGINT DEFAULT NULL CHECK (ifphysaddressnum>=0), 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT vlanid_mif FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_mif FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_mif FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT connectedto_mif FOREIGN KEY (connectedto) REFERENCES main_if (ifid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_mif FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_if (device, ifindex);
CREATE INDEX ON main_if (device);
CREATE INDEX ON main_if (ifindex);
CREATE INDEX ON main_if (ifdescr);
CREATE INDEX ON main_if (ifname);
CREATE INDEX ON main_if (ifalias);
CREATE INDEX ON main_if (ifadminstatus);
CREATE INDEX ON main_if (ifoperstatus);
CREATE INDEX ON main_if (ip);
CREATE INDEX ON main_if (netnum);
CREATE INDEX ON main_if (siteid);
CREATE INDEX ON main_if (vlanid);
CREATE INDEX ON main_if (vlan);
CREATE INDEX ON main_if (roleid);
CREATE INDEX ON main_if (macs);
CREATE INDEX ON main_if (connectedto);
CREATE INDEX ON main_if (ifphysaddress);
CREATE INDEX ON main_if (ifphysaddressnum);
CREATE INDEX ON main_if (macvendorid);
CREATE INDEX ON main_if (active);
CREATE INDEX ON main_if (last_active);

CREATE TABLE IF NOT EXISTS main_arp_device (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  device VARCHAR(39) NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  ifindex INT DEFAULT NULL CHECK (ifindex>=0), 
  ispublic SMALLINT DEFAULT 1, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT vlanid_sar FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sar FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sar FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sar FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_arp_device (device,ip);
CREATE INDEX ON main_arp_device (device);
CREATE INDEX ON main_arp_device (ip);
CREATE INDEX ON main_arp_device (ipnum);
CREATE INDEX ON main_arp_device (mac);
CREATE INDEX ON main_arp_device (vlanid);
CREATE INDEX ON main_arp_device (vlan);
CREATE INDEX ON main_arp_device (roleid); 
CREATE INDEX ON main_arp_device (siteid);
CREATE INDEX ON main_arp_device (ipprefixid);
CREATE INDEX ON main_arp_device (ifindex);
CREATE INDEX ON main_arp_device (ispublic);
CREATE INDEX ON main_arp_device (active);
CREATE INDEX ON main_arp_device (last_active);

CREATE TABLE IF NOT EXISTS main_arp_site (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  ispublic SMALLINT DEFAULT 1, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT vlanid_sas FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sas FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sas FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sas FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_arp_site (ip, siteid);
CREATE INDEX ON main_arp_site (ip);
CREATE INDEX ON main_arp_site (ipnum);
CREATE INDEX ON main_arp_site (mac);
CREATE INDEX ON main_arp_site (vlanid);
CREATE INDEX ON main_arp_site (vlan);
CREATE INDEX ON main_arp_site (roleid);
CREATE INDEX ON main_arp_site (ipprefixid);
CREATE INDEX ON main_arp_site (siteid);
CREATE INDEX ON main_arp_site (ispublic);
CREATE INDEX ON main_arp_site (active);
CREATE INDEX ON main_arp_site (last_active);

CREATE TABLE IF NOT EXISTS main_arp (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ispublic SMALLINT DEFAULT 1, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT vlanid_sa FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sa FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sa FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sa FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE INDEX ON main_arp (ipnum);
CREATE INDEX ON main_arp (mac);
CREATE INDEX ON main_arp (vlanid);
CREATE INDEX ON main_arp (vlan);
CREATE INDEX ON main_arp (ipprefixid);
CREATE INDEX ON main_arp (siteid);
CREATE INDEX ON main_arp (roleid);
CREATE INDEX ON main_arp (ispublic);
CREATE INDEX ON main_arp (active);
CREATE INDEX ON main_arp (last_active);

CREATE TABLE IF NOT EXISTS main_mac_device (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT NOT NULL CHECK (macnum>=0), 
  port INT NOT NULL CHECK (port>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vendorid VARCHAR(12) DEFAULT NULL, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT vlanid_mmd FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_mmd FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_mmd FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT macid_mmd FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_mac_device (device, mac, vlan);
CREATE INDEX ON main_mac_device (device, mac);
CREATE INDEX ON main_mac_device (mac);
CREATE INDEX ON main_mac_device (macnum);
CREATE INDEX ON main_mac_device (device);
CREATE INDEX ON main_mac_device (port);
CREATE INDEX ON main_mac_device (vlan);
CREATE INDEX ON main_mac_device (siteid);
CREATE INDEX ON main_mac_device (vlanid);
CREATE INDEX ON main_mac_device (roleid);
CREATE INDEX ON main_mac_device (vendorid);
CREATE INDEX ON main_mac_device (active);
CREATE INDEX ON main_mac_device (last_active);

CREATE TABLE IF NOT EXISTS main_mac_site (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT NOT NULL CHECK (macnum>=0), 
  port INT NOT NULL CHECK (port>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vendorid VARCHAR(12) DEFAULT NULL,
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT vlanid_mms FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_mms FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_mms FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT macid_mms FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_mac_site (siteid, mac, vlan);
CREATE INDEX ON main_mac_site (siteid, mac);
CREATE INDEX ON main_mac_site (mac);
CREATE INDEX ON main_mac_site (macnum);
CREATE INDEX ON main_mac_site (device);
CREATE INDEX ON main_mac_site (port);
CREATE INDEX ON main_mac_site (vlan);
CREATE INDEX ON main_mac_site (siteid);
CREATE INDEX ON main_mac_site (vlanid);
CREATE INDEX ON main_mac_site (roleid);
CREATE INDEX ON main_mac_site (vendorid);
CREATE INDEX ON main_mac_site (active);
CREATE INDEX ON main_mac_site (last_active);

CREATE TABLE IF NOT EXISTS main_mac (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT NOT NULL CHECK (macnum>=0), 
  port INT NOT NULL CHECK (port>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vendorid VARCHAR(12) DEFAULT NULL, 
  active SMALLINT DEFAULT 1, 
  created TIMESTAMP DEFAULT NOW(), 
  last_active TIMESTAMP DEFAULT NOW(), 
  CONSTRAINT roleid_mm FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macid_mm FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_mm FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON main_mac (mac, vlan);
CREATE INDEX ON main_mac (mac);
CREATE INDEX ON main_mac (macnum); 
CREATE INDEX ON main_mac (device);
CREATE INDEX ON main_mac (port);
CREATE INDEX ON main_mac (vlan);
CREATE INDEX ON main_mac (siteid); 
CREATE INDEX ON main_mac (roleid);
CREATE INDEX ON main_mac (vendorid);
CREATE INDEX ON main_mac (active);
CREATE INDEX ON main_mac (last_active);
