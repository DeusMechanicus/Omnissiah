CREATE TABLE IF NOT EXISTS cfg_parameter ( 
  id SERIAL PRIMARY KEY,
  parameter VARCHAR(256) NOT NULL, 
  tablename VARCHAR(256) DEFAULT NULL, 
  value VARCHAR(256) DEFAULT NULL 
);
CREATE UNIQUE INDEX ON cfg_parameter (parameter, tablename);
