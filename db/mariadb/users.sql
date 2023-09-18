SET @localhost='localhost';

SET @hist_username='hist';
SET @hist_password='hist';
SET @info_username='info';
SET @info_password='info';
SET @main_username='main';
SET @main_password='main';
SET @nnml_username='nnml';
SET @nnml_password='nnml';
SET @raw_username='raw';
SET @raw_password='raw';
SET @ref_username='ref';
SET @ref_password='ref';
SET @shot_username='shot';
SET @shot_password='shot';
SET @src_username='src';
SET @src_password='src';
SET @zbx_username='zbx';
SET @zbx_password='zbx';

SET @dbname=DATABASE();

PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @hist_username, "'@'", @localhost, "' IDENTIFIED BY '", @hist_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @info_username, "'@'", @localhost, "' IDENTIFIED BY '", @info_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @main_username, "'@'", @localhost, "' IDENTIFIED BY '", @main_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @nnml_username, "'@'", @localhost, "' IDENTIFIED BY '", @nnml_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @raw_username, "'@'", @localhost, "' IDENTIFIED BY '", @raw_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @ref_username, "'@'", @localhost, "' IDENTIFIED BY '", @ref_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @shot_username, "'@'", @localhost, "' IDENTIFIED BY '", @shot_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @src_username, "'@'", @localhost, "' IDENTIFIED BY '", @src_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @zbx_password, "'@'", @localhost, "' IDENTIFIED BY '", @zbx_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @hist_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @info_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @main_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @nnml_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @raw_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @ref_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @shot_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @src_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @zbx_password, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TEMPORARY TABLE tmp_install_username (
  username VARCHAR(256) NOT NULL PRIMARY KEY 
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_install_users (
  username VARCHAR(256) NOT NULL PRIMARY KEY 
) ENGINE=InnoDB;

CREATE TEMPORARY TABLE tmp_install_tables (
  tablename VARCHAR(256) NOT NULL PRIMARY KEY 
) ENGINE=InnoDB;

PREPARE stmt FROM CONCAT("INSERT INTO tmp_install_username (username) VALUES ('", @hist_username, "'), ('", @info_username, "'), ('", @main_username, "'), ('", @nnml_username, "'), ('", @raw_username, "'), ('", @ref_username, "'), ('", @shot_username, "'), ('", @src_username, "'), ('", @zbx_username, "');");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM CONCAT('DROP PROCEDURE IF EXISTS ', @dbname, '.grant_rights;');
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


DELIMITER //
CREATE PROCEDURE omnissiah.grant_rights (GRANT_RIGHTS varchar(256), DATABASE_NAME varchar(256), TABLES_WHERE varchar(256), USERS_WHERE varchar(256), LOCAL_HOSTNAME varchar(256))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_user varchar(256);
  DECLARE cur_table varchar(256);
  DECLARE cur_users CURSOR FOR SELECT username FROM tmp_install_users;
  DECLARE cur_tables CURSOR FOR SELECT tablename FROM tmp_install_tables;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  TRUNCATE TABLE tmp_install_users;
  TRUNCATE TABLE tmp_install_tables;
  PREPARE stmt FROM CONCAT('INSERT INTO tmp_install_users (username) SELECT username FROM tmp_install_username ', USERS_WHERE, ';');
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  PREPARE stmt FROM CONCAT("INSERT INTO tmp_install_tables (tablename) SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA='", DATABASE_NAME, "' ", TABLES_WHERE, ';');
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  OPEN cur_users;
  userloop: LOOP
    FETCH cur_users INTO cur_user;
    IF done THEN
      LEAVE userloop;
    END IF;
    OPEN cur_tables;
    tableloop: LOOP
      FETCH cur_tables INTO cur_table;
      IF done THEN
	    SET done = FALSE;
        LEAVE tableloop;
      END IF;
      SET @grant_query = CONCAT('GRANT ', GRANT_RIGHTS, ' ON ', DATABASE_NAME, '.', cur_table, " TO '", cur_user, "'@'", LOCAL_HOSTNAME, "';");
      PREPARE stmt FROM @grant_query;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
    END LOOP;
	CLOSE cur_tables;
  END LOOP;
  CLOSE cur_users;
END //
DELIMITER ;


CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME IN ('cfg_parameter', 'code_program', 'code_program_query', 'code_action')", '', @localhost);
CALL grant_rights('INSERT', @dbname, "AND TABLE_NAME='log_program'", '', @localhost);

PREPARE stmt FROM CONCAT('GRANT SELECT, LOCK TABLES ON ', @dbname, ".* TO '", @hist_username, "'@'", @localhost, "';");;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT('GRANT ALL PRIVILEGES ON ', @dbname, ".hist_dump TO '", @hist_username, "'@'", @localhost, "';");;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'ref_%'", CONCAT("WHERE username<>'", @ref_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'ref_%'", CONCAT("WHERE username='", @ref_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'raw_%'", CONCAT("WHERE username='", @raw_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'info_%'", CONCAT("WHERE username='", @info_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'src_%'", CONCAT("WHERE username='", @src_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'nnml_%'", CONCAT("WHERE username='", @nnml_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'shot_%'", CONCAT("WHERE username='", @shot_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'main_%'", CONCAT("WHERE username='", @main_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'zbx_%'", CONCAT("WHERE username='", @zbx_username, "'"), @localhost);

CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'raw_%'", CONCAT("WHERE username='", @info_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'raw_%'", CONCAT("WHERE username='", @src_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'info_%'", CONCAT("WHERE username='", @ref_username, "'"), @localhost);
CALL grant_rights('ALL PRIVILEGES', @dbname, "AND TABLE_NAME LIKE 'info_%'", CONCAT("WHERE username='", @nnml_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'src_%'", CONCAT("WHERE username='", @nnml_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'src_%'", CONCAT("WHERE username='", @shot_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'nnml_%'", CONCAT("WHERE username='", @shot_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'src_%'", CONCAT("WHERE username='", @main_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'shot_%'", CONCAT("WHERE username='", @main_username, "'"), @localhost);
CALL grant_rights('SELECT', @dbname, "AND TABLE_NAME LIKE 'main_%'", CONCAT("WHERE username='", @zbx_username, "'"), @localhost);

PREPARE stmt FROM CONCAT('DROP PROCEDURE IF EXISTS ', @dbname, '.grant_rights;');
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
