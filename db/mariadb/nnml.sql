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
  CONSTRAINT roleid_ni FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_ni FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT label_manufacturerid_ni FOREIGN KEY (label_manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT predict_manufacturerid_ni FOREIGN KEY (predict_manufacturerid) REFERENCES ref_manufacturer (manufacturerid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT label_devicetypeid_ni FOREIGN KEY (label_devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT predict_devicetypeid_ni FOREIGN KEY (predict_devicetypeid) REFERENCES ref_devicetype (devicetypeid) ON DELETE SET NULL ON UPDATE CASCADE 
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
