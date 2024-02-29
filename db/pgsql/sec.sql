CREATE TABLE sec_camera_unpwd (
  ip VARCHAR(39) NOT NULL PRIMARY KEY, 
  username VARCHAR(100) NOT NULL, 
  password VARCHAR(100) NOT NULL 
);

CREATE TABLE sec_onvif_unpwd (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  username VARCHAR(100) DEFAULT NULL, 
  password VARCHAR(100) DEFAULT NULL, 
  ipprefixid INT DEFAULT NULL, 
  priority INT NOT NULL DEFAULT 0 CHECK (priority>=0), 
  CONSTRAINT subnetid_sou FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON sec_onvif_unpwd (username, password, ipprefixid);
CREATE INDEX ON sec_onvif_unpwd (ipprefixid);
CREATE INDEX ON sec_onvif_unpwd (priority);
