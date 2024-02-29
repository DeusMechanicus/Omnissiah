#!/bin/bash
dbhost=localhost
dbport=3306
dbname=omnissiah
username=omnissiah
password=omnissiah

cd /usr/local/src/omnissiah/db/mariadb

mysql -u root < db.sql

mysql -h $dbhost -P $dbport -u $username -p$password $dbname < cfg.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < code.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < log.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < ref.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < sec.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < raw.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < info.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < src.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < nnml.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < shot.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < main.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < hist.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < zbx.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < tmp.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < cfg_data.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < code_data.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < ref_data.sql
mysql -h $dbhost -P $dbport -u $username -p$password $dbname < sec_data.sql

mysql -h $dbhost -P $dbport -u $username -p$password $dbname < users.sql