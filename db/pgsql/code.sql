CREATE TABLE IF NOT EXISTS code_layer ( 
  layerid INT NOT NULL PRIMARY KEY CHECK (layerid>=0), 
  layer VARCHAR(256) NOT NULL UNIQUE);

CREATE TABLE IF NOT EXISTS code_program ( 
  programid INT NOT NULL PRIMARY KEY CHECK (programid>=0), 
  program VARCHAR(256) NOT NULL UNIQUE, 
  enabled SMALLINT NOT NULL DEFAULT 1, 
  layerid INT NOT NULL CHECK (layerid>=0), 
  CONSTRAINT layerid_cp FOREIGN KEY (layerid) REFERENCES code_layer (layerid) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE IF NOT EXISTS code_program_launch ( 
  priority INT NOT NULL PRIMARY KEY CHECK (priority>=0), 
  programid INT NOT NULL CHECK (programid>=0), 
  parameters VARCHAR(1024) DEFAULT NULL, 
  wait SMALLINT NOT NULL DEFAULT 1, 
  enabled SMALLINT NOT NULL DEFAULT 1, 
  CONSTRAINT programid_cpl FOREIGN KEY (programid) REFERENCES code_program (programid) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE IF NOT EXISTS code_program_query ( 
  id INT GENERATED ALWAYS AS IDENTITY  PRIMARY KEY, 
  programid INT NOT NULL CHECK (programid>=0), 
  stage INT NOT NULL CHECK (stage>=0), 
  priority INT NOT NULL CHECK (priority>=0), 
  parameter VARCHAR(256) DEFAULT NULL, 
  tablename VARCHAR(256) DEFAULT NULL,
  query VARCHAR(8192) NOT NULL DEFAULT '', 
  enabled SMALLINT NOT NULL DEFAULT 1, 
  nrepeat SMALLINT NOT NULL DEFAULT 1 CHECK (nrepeat>=0), 
  CONSTRAINT programid_cpq FOREIGN KEY (programid) REFERENCES code_program (programid) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE INDEX ON code_program_query (stage);
CREATE INDEX ON code_program_query (priority);
CREATE UNIQUE INDEX ON code_program_query (programid, stage, priority);

CREATE TABLE IF NOT EXISTS code_action ( 
  actionid INT NOT NULL PRIMARY KEY CHECK (actionid>=0), 
  action VARCHAR(256) NOT NULL UNIQUE);
