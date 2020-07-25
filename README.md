# Omnissiah
This project was born out of a real working system that is responsible for monitoring a large network of more than one hundred thousand devices. Zabbix is used as a monitoring system, but this project is not about Zabbix, or rather, not only about Zabbix.\
We had a problem how to collect and enter information about such a number of hosts into the chosen monitoring platform. And this must be done more than once. It is necessary to keep it up to date and make changes. We get information about hosts from different sources - from network scans, from various APIs, from manually filled tables. The received data is saved to the database. Further, using SQL, small programs and neural networks, they are filtered and processed. The ultimate goal is to understand what a particular host is - type, manufacturer, model, and so on.\
The resulting database is valuable in itself. But the ultimate goal is to automatically create and update hosts in Zabbix along with group memberships and group/statistical hosts.\
## Requirements
This product requires Linux. We use RH based distributions (RedHat Enterprise Linux, CentOS, Amazon Linux). But there should be no problem with other distributions either. MariaDB versions 10.X are used as a database. All programs are written in python. They require python 3.7 to work
## Downloading
We are using the /usr/local/src/omnissiah directory for the sources. You can use any other directory, but then you have to change the commands.\
If you have git on your system, then use the commands to download:\
mkdir /usr/local/src/omnissiah\
git clone https://github.com/DeusMechanicus/Omnissiah /usr/local/src/omnissiah\
or you can use wget:\
mkdir /usr/local/src/omnissiah\
cd /usr/local/src/omnissiah\
wget -O - https://github.com/DeusMechanicus/Omnissiah/archive/master.tar.gz | tar xz --strip-components=1\
## Installation
