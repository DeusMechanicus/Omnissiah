CREATE TABLE sec_camera_unpwd (
  ip VARCHAR(39) NOT NULL PRIMARY KEY, 
  username VARCHAR(100) NOT NULL, 
  password VARCHAR(100) NOT NULL 
) ENGINE=InnoDB;

CREATE TABLE sec_onvif_unpwd (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  username VARCHAR(100) DEFAULT NULL, 
  password VARCHAR(100) DEFAULT NULL, 
  ipprefixid INT(10) UNSIGNED DEFAULT NULL, 
  priority INT(10) UNSIGNED NOT NULL DEFAULT 0, 
  KEY username (username, password, ipprefixid), 
  KEY ipprefixid (ipprefixid), 
  KEY priority (priority), 
  CONSTRAINT subnetid_sou FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;
