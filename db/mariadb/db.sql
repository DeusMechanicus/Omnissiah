SET @dbname='omnissiah';
SET @username='omnissiah';
SET @password='omnissiah';
SET @localhost='localhost';

PREPARE stmt FROM CONCAT('CREATE DATABASE IF NOT EXISTS ', @dbname, ' DEFAULT CHARACTER SET=utf8mb4 DEFAULT COLLATE=utf8mb4_bin;');;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @username, "'@'", @localhost, "' IDENTIFIED BY '", @password, "';");;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM CONCAT('GRANT ALL PRIVILEGES ON ', @dbname, ".* TO '", @username, "'@'", @localhost, "';");;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM CONCAT('GRANT GRANT OPTION ON ', @dbname, ".* TO '", @username, "'@'", @localhost, "';");;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

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
SET @sec_username='sec';
SET @sec_password='sec';
SET @shot_username='shot';
SET @shot_password='shot';
SET @src_username='src';
SET @src_password='src';
SET @zbx_username='zbx';
SET @zbx_password='zbx';
SET @api_onvif_username='api_onvif';
SET @api_onvif_password='api_onvif';

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
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @sec_username, "'@'", @localhost, "' IDENTIFIED BY '", @sec_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @shot_username, "'@'", @localhost, "' IDENTIFIED BY '", @shot_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @src_username, "'@'", @localhost, "' IDENTIFIED BY '", @src_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @zbx_username, "'@'", @localhost, "' IDENTIFIED BY '", @zbx_password, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("CREATE USER IF NOT EXISTS '", @api_onvif_username, "'@'", @localhost, "' IDENTIFIED BY '", @api_onvif_password, "';");
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
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @sec_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @shot_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @src_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @zbx_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
PREPARE stmt FROM CONCAT("GRANT CREATE TEMPORARY TABLES ON *.* TO '", @api_onvif_username, "'@'", @localhost, "';");
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
