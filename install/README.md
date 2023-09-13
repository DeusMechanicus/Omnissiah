# Omnissiah installation
To run the installation after downloading, run the command line:
```
sudo bash /usr/local/src/omnissiah/install/install.sh
```
If you downloaded the source code to a different directory then change /usr/local/src/omnissiah/ to your path.
Run the installation only once, do not run this script again.
The installation script was developed for Debian 12. If you are using a different version of Linux, then the script may not work partially, but you can always run unsuccessful commands later manually after editing them.
## Parameters
The script has four parameters. These parameters are set in the first lines of the script.
```
srcpath=/usr/local/src/omnissiah
usrpath=/usr/local/lib/omnissiah
homepath=/var/lib/omnissiah
logpath=/var/log/omnissiah
```
* srcpath - the path where you uploaded the source code of the project
* usrpath - the path where you want to install the program
* homepath - home directory for the system user on behalf of which programs will be launched
* logpath - directory for program logs
If you want to use paths other than the default paths, then you need to change these variables before running the install script.
## Actions
The installation script will do the following:
* сreates a system user and group named omnissiah
* creates the necessary directories and assigns access rights to them
* installs necessary system packages
* creates python virtual env
* installs the required python libraries into this virtual env
* copies the project files and sets their permissions
After that, the user will be asked in turn about the need to install Mariadb server, Postgresql server, netbox and Zabbix. Answering Yes(y) will install these programs. If you plan to install these programs on other servers or already have them, answer No(n) to the questions.
The purpose of the installed ones is described in more detail in the [Omnissiah architecture](../docs/architecture.pdf)
The installation process is described in more detail in the [documentation](../docs/install.pdf)
## Configure
The configuration consists of two parts:
* setting up programs that are used by omnissiah
* setting up omnissiah programs

## Configure programs used by omnissiah

### Configure databases
Omnissiah uses a database to store and process its results. Omnissiah can use one of two databases - mariadb or postgresql. Also Zabbix, if installed locally, requires a database (mariadb or postgresql). If Netbox is installed locally, it requires postgresql to work.
You can customize the database to suit your needs. We will only give small recommendations. 
### Configure mariadb
For mariadb client, add the following parameters:
```
ssl
ssl-verify-server-cert = off
```
For mariadb server, set the following parameters:
```
max_allowed_packet = 1G
max_connections = 1000
collation_server = utf8mb4_bin
character_set_server = utf8mb4
thread_handling = pool-of-threads
innodb_flush_method = O_DIRECT
event_scheduler = ON
binlog_format = MIXED
default_storage_engine = InnoDB
innodb_lock_wait_timeout = 60
innodb_deadlock_detect = 1
innodb_file_per_table = 1
local_infile = 1
sync_binlog = 1
performance_schema = 1
innodb_purge_threads = 2
max_heap_table_size = 2G
```
If mariadb is installed locally, then after configuration you need to activate and start the service
```
sudo systemctl enable mariadb
sudo systemctl start mariadb
```
### Configure postgresql
For postgresql server, set the following parameters:
```
max_connections = 1000
```
If Postgresql is installed locally, then after configuration you need to activate and start the service
```
sudo systemctl enable postgresql
sudo systemctl start postgresql
```
### Configure Netbox
Installing and configuring Netbox is a complex process. You'd better check the [documentation](https://docs.netbox.dev/en/stable/installation/) for this. After running install.sh Netbox will already be installed. If you are using an existing Netbox, there is no need to configure anything additional.
### Configure Zabbix
Installing, configuring and optimizing Zabbix is even more complex. After running install.sh Zabbix (server, proxy, agent and web interface) will already be installed. If you are using an existing Zabbix, there is no need to configure anything additional.
Read [Installation] (https://www.zabbix.com/download?zabbix=6.0&os_distribution=debian&os_version=12&components=server_frontend_agent&db=mysql&ws=nginx) and [configuration] (https://www.zabbix.com/documentation/6.0/en/manual/quickstart) documentation on Zabbix site.
## Configuring omnissiah

### Create database
You need to choose which database you will use for Omnissiah. After that, create a database, tables and load records. Instructions for [mariadb](../db/mariadb) and [postgresql](../db/psql) are in their respective sections.
### Configuration files
Omnissiah is located in the /usr/local/lib/omnissiah directory and has two configuration files. Both files are python scripts with variable values set.
* omni_config.py - file with variables controlling the work of omnissiah scripts
* omni_unpwd.py - file with usernames, passwords, tokens, keys and other sensitive information
