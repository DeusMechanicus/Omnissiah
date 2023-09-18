SET @dbname='omnissiah';
SET @username='omnissiah';
SET @password='omnissiah';
SET @localhost='localhost';

SET @query = CONCAT('CREATE DATABASE IF NOT EXISTS ', @dbname, ' DEFAULT CHARACTER SET=utf8mb4 DEFAULT COLLATE=utf8mb4_bin;');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @query = CONCAT("CREATE USER IF NOT EXISTS '", @username, "'@'", @localhost, "' IDENTIFIED BY '", @password, "';");
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @query = CONCAT('GRANT ALL PRIVILEGES ON ', @dbname, ".* TO '", @username, "'@'", @localhost, "';");
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

