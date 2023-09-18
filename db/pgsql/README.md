# Database
The commands for creating the database are split into several files. The db.sql file creates a database named omnissiah. If you want to create a database with a different name, you need to make changes to this file and changes in commands.\
The files are listed in the order you should run them:
* db.sh - database creation script
* cfg.sql - creating cfg_ tables
* code.sql - creating code_ tables
* log.sql - creating log_ tables
* info.sql - creating info_ tables
* ref.sql - creating ref_ tables
* raw.sql - creating raw_ tables
* src.sql - creating src_ tables
* nnml.sql - creating nnml_ tables
* main.sql - creating main_ tables
* hist.sql -creating hist_ tables
* zbx.sql - creating zbx_ tables
* tmp.sql - creating tmp_ tables
* cfg_data.sql - filling cfg_ tables with records
* code_data.sql - filling code_ tables with records
* ref_data.sql - filling ref_ tables with records

No database or tables are dropped in these files. If you have not a new installation, then you need to delete the old tables, the old database or use a different database.
## Installation
edit and run install.sh script or run commands one by one step by step
## Database creation
edit and run db.sh script

## Tables creation
run command
```
psql <database> < <filename>
```
for every filename. Example for local server and omnissiah database
```
sudo -u postgres bash
psql omnissiah < cfg.sql
psql omnissiah < code.sql
psql omnissiah < log.sql
psql omnissiah < info.sql
psql omnissiah < ref.sql
psql omnissiah < raw.sql
psql omnissiah < src.sql
psql omnissiah < nnml.sql
psql omnissiah < main.sql
psql omnissiah < hist.sql
psql omnissiah < zbx.sql
psql omnissiah < tmp.sql
psql omnissiah < cfg_data.sql
psql omnissiah < code_data.sql
psql omnissiah < ref_data.sql
```
