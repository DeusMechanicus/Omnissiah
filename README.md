# Omnissiah V0.1
> *The ultimate goal of the Cult Mechanicus is to understand and fully comprehend the glory of the Machine God. The communal and personal attempt at this form of enlightenment is known as the Quest for Knowledge. The Cult believes that all knowledge already exists in the universe, and it is primarily a matter of time before it can be gathered together to complete the Quest.*

This project was born out of a real working system that is responsible for monitoring a large network of more than one hundred thousand devices. Zabbix is used as a monitoring system, but this project is not about Zabbix, or rather, not only about Zabbix.\
We had a problem how to collect and enter information about such a number of hosts into the chosen monitoring platform. And this must be done more than once. It is necessary to keep it up to date and make changes. We get information about hosts from different sources - from network scans, from various APIs, from manually filled tables. The received data is saved to the database. Further, using SQL, small programs and neural networks, they are filtered and processed. The ultimate goal is to understand what a particular host is - type, manufacturer, model, and so on.\
The resulting database is valuable in itself. But the ultimate goal is to automatically create and update hosts in Zabbix along with group memberships and group/statistical hosts.
## Requirements
This product requires Linux. We use Debian 12. But there should be no problem with other distributions either. MariaDB and PostgreSQL may be used as a database. All programs are written in python or shell. They require python 3.9 or later to work.
## Preparation
Update Linux first:
```
sudo apt-get -y update
sudo apt-get -y upgrade
```
If you are planning to use git then you need to install git client (if it's not already installed). In the case of Debian, this is done with the following command:
```
sudo apt-get -y install git wget
```
## Downloading
You can download the source code of the project or the virtual machine image. The virtual machine image can be downloaded here - (URL with download options will be here)\
We are using the /usr/local/src/omnissiah directory for the sources. You can use any other directory, but then you have to change the commands.\
If you have git on your system, then use the commands to download:
```
sudo mkdir /usr/local/src/omnissiah
sudo git clone https://github.com/DeusMechanicus/Omnissiah /usr/local/src/omnissiah
```
or you can use wget:
```
sudo mkdir /usr/local/src/omnissiah
cd /usr/local/src/omnissiah
sudo wget -O - https://github.com/DeusMechanicus/Omnissiah/archive/master.tar.gz | sudo tar xz --strip-components=1
```
## Installation
Installation is described in the install [section](/install) or in the [documentation](/docs/install.pdf)

## Directories
* code - project code
* db - SQL commands for creating the structure of the database and filling the reference tables.
* docs - documentation and manuals
* install - preparation and installation
* share - data for other applications in use
## Documentation
The documentation and manuals are located in the [docs](/docs/) directory.
