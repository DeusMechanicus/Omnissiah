CREATE TABLE IF NOT EXISTS shot_host_option ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  optionid INT NOT NULL CHECK (optionid>=0), 
  hostuuid VARCHAR(256) NOT NULL, 
  idtype INT NOT NULL CHECK (idtype>=0), 
  ip VARCHAR(39) DEFAULT NULL, 
  mac VARCHAR(12) DEFAULT NULL, 
  name varchar(256) DEFAULT NULL,
  hostname varchar(100) DEFAULT NULL,
  manufacturerid INT DEFAULT NULL CHECK (manufacturerid>=0),
  devicetypeid INT NOT NULL CHECK (devicetypeid>=0), 
  weight FLOAT NOT NULL, 
  controllerid BIGINT DEFAULT NULL, 
  idoncontroller VARCHAR(256) DEFAULT NULL, 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  ispublic SMALLINT DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  CONSTRAINT roleid_sho FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_sho FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_sho FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT devicetypeid_sho FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sho FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT optionid_sho FOREIGN KEY (optionid) REFERENCES ref_host_option (optionid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT controllerid_sho FOREIGN KEY (controllerid) REFERENCES shot_host_option (id) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT idtype_sho FOREIGN KEY (idtype) REFERENCES ref_host_idtype (id) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON shot_host_option (hostuuid, optionid, idtype);
CREATE INDEX ON shot_host_option (hostuuid, idtype);
CREATE INDEX ON shot_host_option (optionid);
CREATE INDEX ON shot_host_option (hostuuid);
CREATE INDEX ON shot_host_option (idtype);
CREATE INDEX ON shot_host_option (ip);
CREATE INDEX ON shot_host_option (mac);
CREATE INDEX ON shot_host_option (name);
CREATE INDEX ON shot_host_option (manufacturerid);
CREATE INDEX ON shot_host_option (devicetypeid);
CREATE INDEX ON shot_host_option (weight);
CREATE INDEX ON shot_host_option (controllerid);
CREATE INDEX ON shot_host_option (ipprefixid);
CREATE INDEX ON shot_host_option (roleid);
CREATE INDEX ON shot_host_option (macvendorid);

CREATE TABLE IF NOT EXISTS shot_host_option_uuid ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL, 
  optionid INT NOT NULL CHECK (optionid>=0), 
  uuid_type INT NOT NULL CHECK (uuid_type>=0), 
  uuid VARCHAR(256) NOT NULL, 
  CONSTRAINT optionid_shou FOREIGN KEY (optionid) REFERENCES ref_host_option (optionid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT hostid_shou FOREIGN KEY (hostid) REFERENCES shot_host_option (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT uuid_type_shou FOREIGN KEY (uuid_type) REFERENCES ref_host_uuid (id) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON shot_host_option_uuid (optionid, uuid_type, uuid);
CREATE INDEX ON shot_host_option_uuid (uuid_type, uuid);
CREATE INDEX ON shot_host_option_uuid (optionid);
CREATE INDEX ON shot_host_option_uuid (uuid_type);
CREATE INDEX ON shot_host_option_uuid (hostid);
CREATE INDEX ON shot_host_option_uuid (uuid);

CREATE TABLE IF NOT EXISTS shot_host_option_link ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL, 
  optionid INT NOT NULL CHECK (optionid>=0), 
  linkid INT NOT NULL CHECK (linkid>=0), 
  uuid VARCHAR(256) NOT NULL, 
  CONSTRAINT optionid_shol FOREIGN KEY (optionid) REFERENCES ref_host_option (optionid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT hostid_shol FOREIGN KEY (hostid) REFERENCES shot_host_option (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT linkid_shol FOREIGN KEY (linkid) REFERENCES ref_host_link (linkid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON shot_host_option_link (optionid, hostid, linkid);
CREATE INDEX ON shot_host_option_link (hostid, linkid);
CREATE INDEX ON shot_host_option_link (linkid);
CREATE INDEX ON shot_host_option_link (optionid);
CREATE INDEX ON shot_host_option_link (hostid);
CREATE INDEX ON shot_host_option_link (uuid);

CREATE TABLE IF NOT EXISTS shot_host ( 
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
  CONSTRAINT roleid_sh FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_sh FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_sh FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT devicetypeid_sh FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sh FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT controllerid_sh FOREIGN KEY (controllerid) REFERENCES shot_host (hostid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT idtype_sh FOREIGN KEY (idtype) REFERENCES ref_host_idtype (id) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON shot_host (hostuuid, idtype);
CREATE INDEX ON shot_host (hostuuid);
CREATE INDEX ON shot_host (idtype);
CREATE INDEX ON shot_host (ip);
CREATE INDEX ON shot_host (mac);
CREATE INDEX ON shot_host (name);
CREATE INDEX ON shot_host (manufacturerid);
CREATE INDEX ON shot_host (devicetypeid);
CREATE INDEX ON shot_host (controllerid);
CREATE INDEX ON shot_host (ipprefixid);
CREATE INDEX ON shot_host (roleid);
CREATE INDEX ON shot_host (macvendorid);

CREATE TABLE IF NOT EXISTS shot_host_uuid ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL, 
  uuid_type INT NOT NULL CHECK (uuid_type>=0), 
  uuid VARCHAR(256) NOT NULL, 
  CONSTRAINT hostid_shu FOREIGN KEY (hostid) REFERENCES shot_host (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT uuid_type_shu FOREIGN KEY (uuid_type) REFERENCES ref_host_uuid (id) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON shot_host_uuid (uuid_type, uuid);
CREATE INDEX ON shot_host_uuid (uuid_type);
CREATE INDEX ON shot_host_uuid (hostid);
CREATE INDEX ON shot_host_uuid (uuid);

CREATE TABLE IF NOT EXISTS shot_host_link ( 
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL, 
  linkid INT NOT NULL CHECK (linkid>=0), 
  uuid VARCHAR(256) NOT NULL, 
  CONSTRAINT hostid_shl FOREIGN KEY (hostid) REFERENCES shot_host (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT linkid_shl FOREIGN KEY (linkid) REFERENCES ref_host_link (linkid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON shot_host_link (hostid, linkid);
CREATE INDEX ON shot_host_link (linkid);
CREATE INDEX ON shot_host_link (hostid);
CREATE INDEX ON shot_host_link (uuid);

