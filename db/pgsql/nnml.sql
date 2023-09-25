CREATE TABLE IF NOT EXISTS nnml_ip (
  ipid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
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
  predict_manufacturerid_prob FLOAT DEFAULT NULL CHECK (predict_manufacturerid_prob>=0), 
  predict_devicetypeid_prob FLOAT DEFAULT NULL CHECK (predict_devicetypeid_prob>=0), 
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
CREATE INDEX ON nnml_ip (predict_manufacturerid_prob);
CREATE INDEX ON nnml_ip (predict_devicetypeid_prob);

CREATE TABLE IF NOT EXISTS nnml_input (
  inputid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  input_typeid INT NOT NULL CHECK (input_typeid>=0), 
  typeid INT NOT NULL DEFAULT 0, 
  CONSTRAINT input_typeid_ni FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX ON nnml_input (input_typeid, typeid);
CREATE INDEX ON nnml_input (input_typeid);
CREATE INDEX ON nnml_input (typeid);

CREATE TABLE IF NOT EXISTS nnml_ip_input (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
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
  trainid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  created TIMESTAMP NOT NULL DEFAULT NOW() UNIQUE
);

CREATE TABLE IF NOT EXISTS nnml_train_ip (
  ipid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
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
  inputid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  input_typeid INT NOT NULL CHECK (input_typeid>=0), 
  typeid INT NOT NULL DEFAULT 0, 
  CONSTRAINT input_typeid_tni FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX ON nnml_train_input (input_typeid, typeid);
CREATE INDEX ON nnml_train_input (input_typeid);
CREATE INDEX ON nnml_train_input (typeid);

CREATE TABLE IF NOT EXISTS nnml_train_ip_input (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  inputid INT NOT NULL, 
  value FLOAT NOT NULL DEFAULT 1.0, 
  CONSTRAINT ipid_tnii FOREIGN KEY (ipid) REFERENCES nnml_train_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT inputid_tnii FOREIGN KEY (inputid) REFERENCES nnml_train_input (inputid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_train_ip_input (ipid, inputid);
CREATE INDEX ON nnml_train_ip_input (ipid);
CREATE INDEX ON nnml_train_ip_input (inputid);

CREATE TABLE IF NOT EXISTS nnml_model (
  modelid INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  created TIMESTAMP NOT NULL DEFAULT NOW() UNIQUE,
  modeltypeid INT NOT NULL CHECK (modeltypeid>=0), 
  model_filename VARCHAR(256) NOT NULL,
  CONSTRAINT modeltypeid_nm FOREIGN KEY (modeltypeid) REFERENCES ref_nnml_modeltype (modeltypeid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON nnml_model (modeltypeid);

CREATE TABLE IF NOT EXISTS nnml_model_devicetype_map (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  modelid INT NOT NULL, 
  outputnum INT NOT NULL CHECK (outputnum>=0),
  devicetypeid INT NOT NULL CHECK (devicetypeid>=0), 
  CONSTRAINT devicetypeid_nmdt FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT modelid_nmdt FOREIGN KEY (modelid) REFERENCES nnml_model (modelid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_model_devicetype_map (modelid, outputnum);
CREATE UNIQUE INDEX ON nnml_model_devicetype_map (modelid, devicetypeid);
CREATE INDEX ON nnml_model_devicetype_map (modelid);
CREATE INDEX ON nnml_model_devicetype_map (outputnum);
CREATE INDEX ON nnml_model_devicetype_map (devicetypeid);

CREATE TABLE IF NOT EXISTS nnml_model_manufacturer_map (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  modelid INT NOT NULL, 
  outputnum INT NOT NULL CHECK (outputnum>=0),
  manufacturerid INT NOT NULL CHECK (manufacturerid>=0), 
  CONSTRAINT manufacturerid_nmmm FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT modelid_nmmm FOREIGN KEY (modelid) REFERENCES nnml_model (modelid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_model_manufacturer_map (modelid, outputnum);
CREATE UNIQUE INDEX ON nnml_model_manufacturer_map (modelid, manufacturerid);
CREATE INDEX ON nnml_model_manufacturer_map (modelid);
CREATE INDEX ON nnml_model_manufacturer_map (outputnum);
CREATE INDEX ON nnml_model_manufacturer_map (manufacturerid);

CREATE TABLE IF NOT EXISTS nnml_model_input_map (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  modelid INT NOT NULL, 
  inputnum INT NOT NULL CHECK (inputnum>=0),
  input_typeid INT NOT NULL CHECK (input_typeid>=0), 
  typeid INT NOT NULL, 
  CONSTRAINT modelid_nmim FOREIGN KEY (modelid) REFERENCES nnml_model (modelid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT input_typeid_nmim FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON nnml_model_input_map (modelid, inputnum);
CREATE UNIQUE INDEX ON nnml_model_input_map (modelid, input_typeid, typeid);
CREATE INDEX ON nnml_model_input_map (input_typeid, typeid);
CREATE INDEX ON nnml_model_input_map (modelid);
CREATE INDEX ON nnml_model_input_map (inputnum);
CREATE INDEX ON nnml_model_input_map (input_typeid);
CREATE INDEX ON nnml_model_input_map (typeid);

