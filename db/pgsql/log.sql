CREATE TABLE IF NOT EXISTS log_program ( 
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  programid INT NOT NULL, 
  queryid INT DEFAULT NULL, 
  actionid INT NOT NULL, 
  actiondt TIMESTAMP NOT NULL DEFAULT NOW(), 
  CONSTRAINT programid_lp FOREIGN KEY (programid) REFERENCES code_program (programid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT queryid_lp FOREIGN KEY (queryid) REFERENCES code_program_query (id) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT actionid_lp FOREIGN KEY (actionid) REFERENCES code_action (actionid) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE INDEX ON log_program (actiondt);

