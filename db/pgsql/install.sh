#!/bin/bash
dbhost=localhost
dbport=5432
dbname=omnissiah
username=omnissiah
password=omnissiah

cd /usr/local/src/omnissiah/db/pgsql
sudo -u postgres psql < db.sql

export PGPASSWORD="$password"

psql -h $dbhost -p $dbport -d $dbname -U $username < cfg.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < code.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < log.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < ref.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < raw.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < info.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < src.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < nnml.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < shot.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < main.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < hist.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < zbx.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < tmp.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < cfg_data.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < code_data.sql
psql -h $dbhost -p $dbport -d $dbname -U $username < ref_data.sql

psql -h $dbhost -p $dbport -d $dbname -U $username < users.sql
