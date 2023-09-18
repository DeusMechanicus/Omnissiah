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
sudo cd /usr/local/src/omnissiah/db/mariadb
sudo bash /usr/local/src/omnissiah/db/mariadb/install.sh
```
The script has four parameters. These parameters are set in the first lines of the script.
```
dbhost=localhost
dbport=3306
dbname=omnissiah
username=omnissiah
password=omnissiah
```
Change these settings if you are not happy with the default values. 
If you ran the install file, you do not need to run the commands manually.
## Database creation
run command (example for local server)
```
mysql -u root < db.sql
```
The script db.sql has four parameters. These parameters are set in the first lines of the script.
```
SET @dbname='omnissiah';
SET @username='omnissiah';
SET @password='omnissiah';
SET @localhost='localhost';
```
This script will create the database and database user omnissiah. This user will have all rights to the omnissiah database.

## Creating tables and loading data
run command
```
mysql -h <host> -P <port> -u omnissiah -pomnissiah omnissiah < <filename>.sql
```
for every filename. Example for local server and omnissiah database
```
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < cfg.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < code.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < log.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < ref.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < raw.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < info.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < src.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < nnml.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < shot.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < main.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < hist.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < zbx.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < tmp.sql

mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < cfg_data.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < code_data.sql
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < ref_data.sql
```
## Creating users and assigning rights
Each layer in Omnissiah has its own database user. The users.sql file specifies the names and passwords of these users. To create users and assign these rights, execute this file.
Example for local server and omnissiah database
```
mysql -h localhost -P 3306 -u omnissiah -pomnissiah omnissiah < users.sql
```
