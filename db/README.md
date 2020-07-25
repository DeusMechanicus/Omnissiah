# Database
The commands for creating the database are split into several files. The db.sql file creates a database named omnissiah. If you want to create a database with a different name, you need to make changes to this file and changes in commands.\
The files are listed in the order you should run them:
* db.sql - database creation
* ref.sql - creating ref_ tables
* raw.sql - creating raw_ tables
* src.sql - creating src_ tables
* nnml.sql - creating nnml_ tables
* main.sql - creating main_ tables
* hist.sql -creating hist_ tables
* zbx.sql - creating zbx_ tables
* ref_data.sql - filling ref_ tables with records
No database or tables are dropped in these files. If you have not a new installation, then you need to delete the old tables, the old database or use a different database.
## Database creation
run command
'''
mysql -h <host> -u <username> -p<password> < db.sql
'''
example for local server
'''
mysql -h localhost -u root -p < db.sql
'''
## Tables creation
run coomand
'''
mysql -h <host> -u <username> -p<password> <database> < <filename>
'''
for every filename. Example for local server and omnissiah database
'''
mysql -h localhost -u root -p omnissiah < ref.sql
mysql -h localhost -u root -p omnissiah < raw.sql
mysql -h localhost -u root -p omnissiah < src.sql
mysql -h localhost -u root -p omnissiah < nnml.sql
mysql -h localhost -u root -p omnissiah < main.sql
mysql -h localhost -u root -p omnissiah < hist.sql
mysql -h localhost -u root -p omnissiah < zbx.sql
mysql -h localhost -u root -p omnissiah < ref_data.sql
'''
