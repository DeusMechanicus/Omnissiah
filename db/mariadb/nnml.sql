CREATE TABLE IF NOT EXISTS nnml_ip (
  ipid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  mac VARCHAR(12) DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  ispublic BOOLEAN NOT NULL DEFAULT FALSE, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  netnum smallint(6) NOT NULL DEFAULT 32,  
  label_manufacturerid INT UNSIGNED DEFAULT NULL, 
  predict_manufacturerid INT UNSIGNED DEFAULT NULL,
  label_devicetypeid INT UNSIGNED DEFAULT NULL, 
  predict_devicetypeid INT UNSIGNED DEFAULT NULL, 
  ipprefixid INT UNSIGNED DEFAULT NULL, 
  predict_manufacturerid_prob FLOAT UNSIGNED DEFAULT NULL,
  predict_devicetypeid_prob FLOAT UNSIGNED DEFAULT NULL, 
  KEY mac (mac), 
  KEY macvendorid (macvendorid), 
  KEY roleid (roleid), 
  KEY vlan (vlan), 
  KEY ispublic (ispublic), 
  KEY netnum (netnum), 
  KEY label_manufacturerid (label_manufacturerid), 
  KEY predict_manufacturerid (predict_manufacturerid), 
  KEY label_devicetypeid (label_devicetypeid), 
  KEY predict_devicetypeid (predict_devicetypeid), 
  KEY ipprefixid (ipprefixid), 
  KEY predict_manufacturerid_prob (predict_manufacturerid_prob), 
  KEY predict_devicetypeid_prob (predict_devicetypeid_prob), 
  CONSTRAINT roleid_ni FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_ni FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT label_manufacturerid_ni FOREIGN KEY (label_manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT predict_manufacturerid_ni FOREIGN KEY (predict_manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT label_devicetypeid_ni FOREIGN KEY (label_devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT predict_devicetypeid_ni FOREIGN KEY (predict_devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT ipprefixid_ni FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_input (
  inputid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  input_typeid INT UNSIGNED NOT NULL, 
  typeid INT NOT NULL DEFAULT 0, 
  UNIQUE KEY inputtypeid (input_typeid, typeid), 
  KEY input_typeid (input_typeid), 
  KEY typeid (typeid), 
  CONSTRAINT input_typeid_ni FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_ip_input (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid BIGINT NOT NULL , 
  inputid INT NOT NULL, 
  value FLOAT NOT NULL DEFAULT 1.0, 
  UNIQUE KEY ipinput (ipid, inputid), 
  KEY ipid (ipid), 
  KEY inputid (inputid), 
  CONSTRAINT ipid_nii FOREIGN KEY (ipid) REFERENCES nnml_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT inputid_nii FOREIGN KEY (inputid) REFERENCES nnml_input (inputid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_train (
  trainid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  created DATETIME NOT NULL DEFAULT NOW() UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_train_ip (
  ipid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  trainid INT NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  ispublic BOOLEAN NOT NULL DEFAULT FALSE, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  netnum smallint(6) NOT NULL DEFAULT 32,  
  manufacturerid INT UNSIGNED DEFAULT NULL, 
  devicetypeid INT UNSIGNED DEFAULT NULL, 
  ipprefixid INT UNSIGNED DEFAULT NULL, 
  UNIQUE KEY trainip (trainid, ip), 
  KEY trainid (trainid),   
  KEY ip (ip), 
  KEY mac (mac), 
  KEY macvendorid (macvendorid), 
  KEY roleid (roleid), 
  KEY vlan (vlan), 
  KEY ispublic (ispublic), 
  KEY netnum (netnum), 
  KEY manufacturerid (manufacturerid), 
  KEY devicetypeid (devicetypeid), 
  KEY ipprefixid (ipprefixid), 
  CONSTRAINT trainid_nti FOREIGN KEY (trainid) REFERENCES nnml_train (trainid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT roleid_nti FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_nti FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT manufacturerid_nti FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT devicetypeid_nti FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_nti FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_train_input (
  inputid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  input_typeid INT UNSIGNED NOT NULL, 
  typeid INT NOT NULL DEFAULT 0, 
  UNIQUE KEY inputtypeid (input_typeid, typeid), 
  KEY input_typeid (input_typeid), 
  KEY typeid (typeid), 
  CONSTRAINT input_typeid_nti FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_train_ip_input (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid BIGINT NOT NULL, 
  inputid INT NOT NULL, 
  value FLOAT NOT NULL DEFAULT 1.0, 
  UNIQUE KEY ipinput (ipid, inputid), 
  KEY ipid (ipid), 
  KEY inputid (inputid), 
  CONSTRAINT ipid_ntii FOREIGN KEY (ipid) REFERENCES nnml_train_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT inputid_ntii FOREIGN KEY (inputid) REFERENCES nnml_train_input (inputid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_model (
  modelid INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  created DATETIME NOT NULL DEFAULT NOW() UNIQUE,
  modeltypeid INT UNSIGNED NOT NULL, 
  model_filename VARCHAR(256) NOT NULL,
  KEY modeltypeid (modeltypeid),
  CONSTRAINT modeltypeid_nm FOREIGN KEY (modeltypeid) REFERENCES ref_nnml_modeltype (modeltypeid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_model_devicetype_map (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  modelid INT NOT NULL, 
  outputnum INT UNSIGNED NOT NULL,
  devicetypeid INT UNSIGNED NOT NULL, 
  UNIQUE KEY modeloutput (modelid, outputnum), 
  UNIQUE KEY modeldevicetype (modelid, devicetypeid), 
  KEY modelid (modelid),
  KEY outputnum (outputnum),
  KEY devicetypeid (devicetypeid),
  CONSTRAINT devicetypeid_nmdt FOREIGN KEY (devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT modelid_nmdt FOREIGN KEY (modelid) REFERENCES nnml_model (modelid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_model_manufacturer_map (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  modelid INT NOT NULL, 
  outputnum INT UNSIGNED NOT NULL,
  manufacturerid INT UNSIGNED NOT NULL, 
  UNIQUE KEY modeloutput (modelid, outputnum), 
  UNIQUE KEY modelmanufacturer (modelid, manufacturerid), 
  KEY modelid (modelid),
  KEY outputnum (outputnum),
  KEY manufacturerid (manufacturerid),
  CONSTRAINT manufacturerid_nmmm FOREIGN KEY (manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT modelid_nmmm FOREIGN KEY (modelid) REFERENCES nnml_model (modelid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS nnml_model_input_map (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  modelid INT NOT NULL, 
  inputnum INT UNSIGNED NOT NULL,
  input_typeid INT UNSIGNED NOT NULL, 
  typeid INT NOT NULL, 
  UNIQUE KEY modelinput (modelid, inputnum), 
  UNIQUE KEY modelinputtype (modelid, input_typeid, typeid), 
  KEY inputtype (input_typeid, typeid),   
  KEY modelid (modelid),
  KEY inputnum (inputnum),
  KEY input_typeid (input_typeid),
  KEY typeid (typeid),  
  CONSTRAINT modelid_nmim FOREIGN KEY (modelid) REFERENCES nnml_model (modelid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT input_typeid_nmim FOREIGN KEY (input_typeid) REFERENCES ref_nnml_input_type (typeid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;
