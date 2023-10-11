DROP PROCEDURE IF EXISTS grant_tables_rights;
DROP PROCEDURE IF EXISTS set_ownership;

CREATE OR REPLACE PROCEDURE grant_tables_rights (GRANT_RIGHTS VARCHAR, DATABASE_NAME VARCHAR, TABLES_WHERE VARCHAR, USERS_WHERE VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
  cur_users NO SCROLL CURSOR FOR SELECT username FROM tmp_install_users;
  cur_tables NO SCROLL CURSOR FOR SELECT tablename FROM tmp_install_tables;
BEGIN
  TRUNCATE TABLE tmp_install_users;
  TRUNCATE TABLE tmp_install_tables;
  EXECUTE 'INSERT INTO tmp_install_users (username) SELECT username FROM tmp_install_username ' || USERS_WHERE || ';';
  EXECUTE 'INSERT INTO tmp_install_tables (tablename) SELECT table_name FROM information_schema.tables WHERE table_type=''BASE TABLE'' AND table_schema NOT IN (''pg_catalog'', ''information_schema'') AND table_catalog=''' || DATABASE_NAME || ''' ' || TABLES_WHERE || ';';
  FOR cur_user IN cur_users LOOP
    FOR cur_table IN cur_tables LOOP
	  EXECUTE 'GRANT ' || GRANT_RIGHTS || ' ON ' ||  cur_table.tablename || ' TO ' || cur_user.username || ';';
    END LOOP;
  END LOOP;
END; $$;

CREATE OR REPLACE PROCEDURE set_ownership (DATABASE_NAME VARCHAR, TABLES_WHERE VARCHAR, USER_NAME VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
  cur_tables NO SCROLL CURSOR FOR SELECT tablename FROM tmp_install_tables;
BEGIN
  TRUNCATE TABLE tmp_install_tables;
  EXECUTE 'INSERT INTO tmp_install_tables (tablename) SELECT table_name FROM information_schema.tables WHERE table_type=''BASE TABLE'' AND table_schema NOT IN (''pg_catalog'', ''information_schema'') AND table_catalog=''' || DATABASE_NAME || ''' ' || TABLES_WHERE || ';';
  FOR cur_table IN cur_tables LOOP
    EXECUTE 'ALTER TABLE ' || cur_table.tablename || ' OWNER TO ' ||  USER_NAME || ';';
  END LOOP;
END; $$;

DO $$
DECLARE
  hist_username VARCHAR := 'hist';
  info_username VARCHAR := 'info';
  main_username VARCHAR := 'main';
  nnml_username VARCHAR := 'nnml';
  raw_username VARCHAR := 'raw';
  ref_username VARCHAR := 'ref';
  shot_username VARCHAR := 'shot';
  src_username VARCHAR := 'src';
  zbx_username VARCHAR := 'zbx';
  dbname VARCHAR;
BEGIN 
  SELECT current_database() INTO dbname;
  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_install_username (username VARCHAR(256) NOT NULL PRIMARY KEY);
  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_install_users (username VARCHAR(256) NOT NULL PRIMARY KEY);
  CREATE TEMPORARY TABLE IF NOT EXISTS tmp_install_tables (tablename VARCHAR(256) NOT NULL PRIMARY KEY);
  INSERT INTO tmp_install_username (username) VALUES (hist_username), (info_username), (main_username), (nnml_username), (raw_username), (ref_username), (shot_username), (src_username), (zbx_username);
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name IN (''cfg_parameter'', ''code_program'', ''code_program_query'', ''code_action'');', '');
  CALL grant_tables_rights('INSERT', dbname, 'AND table_name=''log_program''', '');
  CALL grant_tables_rights('SELECT', dbname, '', 'WHERE username=''' || hist_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name=''hist_dump''', 'WHERE username=''' || hist_username || '''');

  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''ref_%''', 'WHERE username<>''' || ref_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''ref_%''', 'WHERE username=''' || ref_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''raw_%''', 'WHERE username=''' || raw_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''info_%''', 'WHERE username=''' || info_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''src_%''', 'WHERE username=''' || src_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''nnml_%''', 'WHERE username=''' || nnml_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''shot_%''', 'WHERE username=''' || shot_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''main_%''', 'WHERE username=''' || main_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''zbx_%''', 'WHERE username=''' || zbx_username || '''');

  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''raw_%''', 'WHERE username=''' || info_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''raw_%''', 'WHERE username=''' || src_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''info_%''', 'WHERE username=''' || src_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''info_%''', 'WHERE username=''' || ref_username || '''');
  CALL grant_tables_rights('ALL PRIVILEGES', dbname, 'AND table_name LIKE ''info_%''', 'WHERE username=''' || nnml_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''src_%''', 'WHERE username=''' || nnml_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''src_%''', 'WHERE username=''' || shot_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''nnml_%''', 'WHERE username=''' || shot_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''src_%''', 'WHERE username=''' || main_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''shot_%''', 'WHERE username=''' || main_username || '''');
  CALL grant_tables_rights('SELECT', dbname, 'AND table_name LIKE ''main_%''', 'WHERE username=''' || zbx_username || '''');

  CALL set_ownership(dbname, 'AND table_name LIKE ''raw_%''', raw_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''ref_%''', ref_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''info_%''', info_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''src_%''', src_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''nnml_%''', nnml_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''shot_%''', shot_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''main_%''', main_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''zbx_%''', zbx_username);
  CALL set_ownership(dbname, 'AND table_name LIKE ''hist_%''', hist_username);

END; $$;

DROP PROCEDURE IF EXISTS grant_tables_rights;
DROP PROCEDURE IF EXISTS set_ownership;
