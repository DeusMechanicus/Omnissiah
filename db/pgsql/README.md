# Database
The commands for creating the database are split into several files. The db.sql file creates a database named omnissiah. If you want to create a database with a different name, you need to make changes to this file and changes in commands.\
The files are listed in the order you should run them:
* db.sql - database and omnissiah user creation
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
* users.sql - creating users and assigning rights

No database or tables are dropped in these files. If you have not a new installation, then you need to delete the old tables, the old database or use a different database.
## Installation
edit and run install.sh script or run commands one by one step by step
```
sudo bash /usr/local/src/omnissiah/db/pgsql/install.sh
```
The script has four parameters. These parameters are set in the first lines of the script.
```
dbhost=localhost
dbport=5432
dbname=omnissiah
username=omnissiah
password=omnissiah
```
Change these settings if you are not happy with the default values. 
If you ran the install file, you do not need to run the commands manually.
## Database creation
run command (example for local server)
```
sudo -u postgres psql < db.sql
```
If you want to change the default names and passwords then edit the db.sql file. 
This script will create the database and users. This user <omnissiah. will have all rights to the omnissiah database.
## Creating tables and loading data
run command
```
psql -h <host> -p <port> -d omnissiah -U omnissiah < <filename>.sql
```
for every filename. Example for local server and omnissiah database
```
psql -h localhost -p 5432 -d omnissiah -U omnissiah < cfg.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < code.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < log.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < ref.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < raw.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < info.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < src.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < nnml.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < shot.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < main.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < hist.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < zbx.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < tmp.sql

psql -h localhost -p 5432 -d omnissiah -U omnissiah < cfg_data.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < code_data.sql
psql -h localhost -p 5432 -d omnissiah -U omnissiah < ref_data.sql
```
## Assigning rights
Each layer in Omnissiah has its own database user. The users.sql file specifies the names and passwords of these users. To assign these rights, execute this file.
Example for local server and omnissiah database
```
psql -h localhost -p 5432 -d omnissiah -U omnissiah < users.sql
```
