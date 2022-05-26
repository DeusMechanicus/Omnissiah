CREATE TABLE IF NOT EXISTS nnml_ip (
  ipid BIGSERIAL NOT NULL PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  mac VARCHAR(12) DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  ispublic SMALLINT NOT NULL DEFAULT 0, 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  netnum SMALLINT NOT NULL DEFAULT 32,  
  label_manufacturerid INT DEFAULT NULL CHECK (label_manufacturerid>=0), 
  predict_manufacturerid INT DEFAULT NULL CHECK (predict_manufacturerid>=0),
  label_devicetypeid INT DEFAULT NULL CHECK (label_devicetypeid>=0), 
  predict_devicetypeid INT DEFAULT NULL CHECK (predict_devicetypeid>=0),
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  CONSTRAINT roleid_ni FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_ni FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT label_manufacturerid_ni FOREIGN KEY (label_manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT predict_manufacturerid_ni FOREIGN KEY (predict_manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT label_devicetypeid_ni FOREIGN KEY (label_devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT predict_devicetypeid_ni FOREIGN KEY (predict_devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_ni FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX ON nnml_ip (mac);
CREATE INDEX ON nnml_ip (macvendorid);
CREATE INDEX ON nnml_ip (roleid);
CREATE INDEX ON nnml_ip (vlan);
CREATE INDEX ON nnml_ip (ispublic);
CREATE INDEX ON nnml_ip (netnum);
CREATE INDEX ON nnml_ip (label_manufacturerid);
CREATE INDEX ON nnml_ip (predict_manufacturerid);
CREATE INDEX ON nnml_ip (label_devicetypeid);
CREATE INDEX ON nnml_ip (predict_devicetypeid);
CREATE INDEX ON nnml_ip (ipprefixid);

CREATE TABLE IF NOT EXISTS nnml_input (
  inputid SERIAL NOT NULL PRIMARY KEY, 
  input_typeid INT NOT NULL CHECK (input_typeid>=0), 
  typeid INT NOT NULL DEFAULT 0, 
  CONSTRAINT input_typeid_ni FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX ON nnml_input (input_typeid, typeid);
CREATE INDEX ON nnml_input (input_typeid);
CREATE INDEX ON nnml_input (typeid);

CREATE TABLE IF NOT EXISTS nnml_ip_input (
  id BIGSERIAL NOT NULL PRIMARY KEY, 
  ipid BIGINT NOT NULL , 
  inputid INT NOT NULL, 
  value FLOAT NOT NULL DEFAULT 1.0, 
  CONSTRAINT ipid_nii FOREIGN KEY (ipid) REFERENCES nnml_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT inputid_nii FOREIGN KEY (inputid) REFERENCES nnml_input (inputid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_ip_input (ipid, inputid);
CREATE INDEX ON nnml_ip_input (ipid);
CREATE INDEX ON nnml_ip_input (inputid);

CREATE TABLE IF NOT EXISTS nnml_train (
  trainid SERIAL NOT NULL PRIMARY KEY, 
  created TIMESTAMP NOT NULL DEFAULT NOW() UNIQUE
);

CREATE TABLE IF NOT EXISTS nnml_train_ip (
  ipid BIGSERIAL NOT NULL PRIMARY KEY, 
  trainid INT NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  ispublic SMALLINT NOT NULL DEFAULT 0, 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  netnum SMALLINT NOT NULL DEFAULT 32,  
  manufacturerid INT DEFAULT NULL CHECK (manufacturerid>=0), 
  devicetypeid INT DEFAULT NULL CHECK (devicetypeid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  CONSTRAINT trainid_nti FOREIGN KEY (trainid) REFERENCES nnml_train (trainid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_nti FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_nti FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_nti FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT devicetypeid_nti FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_nti FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_train_ip (trainid, ip);
CREATE INDEX ON nnml_train_ip (trainid);
CREATE INDEX ON nnml_train_ip (ip);
CREATE INDEX ON nnml_train_ip (mac);
CREATE INDEX ON nnml_train_ip (macvendorid);
CREATE INDEX ON nnml_train_ip (roleid);
CREATE INDEX ON nnml_train_ip (vlan);
CREATE INDEX ON nnml_train_ip (ispublic);
CREATE INDEX ON nnml_train_ip (netnum);
CREATE INDEX ON nnml_train_ip (manufacturerid);
CREATE INDEX ON nnml_train_ip (devicetypeid);
CREATE INDEX ON nnml_train_ip (ipprefixid);

CREATE TABLE IF NOT EXISTS nnml_train_input (
  inputid SERIAL NOT NULL PRIMARY KEY, 
  input_typeid INT NOT NULL CHECK (input_typeid>=0), 
  typeid INT NOT NULL DEFAULT 0, 
  CONSTRAINT input_typeid_tni FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX ON nnml_train_input (input_typeid, typeid);
CREATE INDEX ON nnml_train_input (input_typeid);
CREATE INDEX ON nnml_train_input (typeid);

CREATE TABLE IF NOT EXISTS nnml_train_ip_input (
  id BIGSERIAL NOT NULL PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  inputid INT NOT NULL, 
  value FLOAT NOT NULL DEFAULT 1.0, 
  CONSTRAINT ipid_tnii FOREIGN KEY (ipid) REFERENCES nnml_train_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT inputid_tnii FOREIGN KEY (inputid) REFERENCES nnml_train_input (inputid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_train_ip_input (ipid, inputid);
CREATE INDEX ON nnml_train_ip_input (ipid);
CREATE INDEX ON nnml_train_ip_input (inputid);
