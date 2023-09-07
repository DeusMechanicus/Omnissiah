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

###Configure programs used by omnissiah

###Configure databases

###Configure mariadb

###Configure postgresql

###Configure Netbox

###Configure Zabbix

###Configuring omnissiah

###Create database

###Configuration files
Omnissiah is located in the /usr/local/lib/omnissiah directory and has two configuration files. Both files are python scripts with variable values set.
* omni_config.py - file with variables controlling the work of omnissiah scripts
* omni_unpwd.py - file with usernames, passwords, tokens, keys and other sensitive information
