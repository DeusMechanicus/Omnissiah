# Database
The commands for creating the database are split into several files. The db.sql file creates a database named omnissiah. If you want to create a database with a different name, you need to make changes to this file and changes in commands.\
The files are listed in the order you should run them:
* db.sql - database creation
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
run command
```
mysql -h <host> -u <username> -p<password> < db.sql
```
example for local server
```
mysql -h localhost -u root -pomnissiah < db.sql
```
## Tables creation
run command
```
mysql -h <host> -u <username> -p<password> <database> < <filename>
```
for every filename. Example for local server and omnissiah database
```
mysql -h localhost -u root -pomnissiah < cfg.sql
mysql -h localhost -u root -pomnissiah < code.sql
mysql -h localhost -u root -pomnissiah < log.sql
mysql -h localhost -u root -pomnissiah < info.sql
mysql -h localhost -u root -pomnissiah < ref.sql
mysql -h localhost -u root -pomnissiah < raw.sql
mysql -h localhost -u root -pomnissiah < src.sql
mysql -h localhost -u root -pomnissiah < nnml.sql
mysql -h localhost -u root -pomnissiah < main.sql
mysql -h localhost -u root -pomnissiah < hist.sql
mysql -h localhost -u root -pomnissiah < zbx.sql
mysql -h localhost -u root -pomnissiah < tmp.sql
mysql -h localhost -u root -pomnissiah < cfg_data.sql
mysql -h localhost -u root -pomnissiah < code_data.sql
mysql -h localhost -u root -pomnissiah < ref_data.sql
```
