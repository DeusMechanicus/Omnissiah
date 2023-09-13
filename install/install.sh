#!/bin/bash
usergroup=omnissiah
srcpath=/usr/local/src/omnissiah
usrpath=/usr/local/lib/omnissiah
homepath=/var/lib/omnissiah
logpath=/var/log/omnissiah

adduser --system --home $homepath --group --disabled-login $usergroup
usermod -aG sudo omnissiah
chmod 750 $homepath
mkdir $usrpath
chown $usergroup $usrpath
chmod 750 $usrpath
mkdir $logpath
chown $usergroup $logpath
chmod 750 $logpath

sudo -u $usergroup cp -r $srcpath/code/* $usrpath
sudo -u $usergroup cp -r $srcpath/install/cfg/* $usrpath
chmod -R 640 $usrpath/*
chmod u+x,g+x $usrpath/*.py

apt install -y gcc
apt install -y snmp libsnmp-dev
apt install -y mariadb-client libmariadb-dev
apt install -y postgresql-client
apt install -y python3-pip
apt install -y python3-venv
apt install -y nmap
cp $srcpath/share/nmap/*.lua /usr/share/nmap/nselib
cp $srcpath/share/nmap/*.nse /usr/share/nmap/scripts

cd $usrpath
sudo -u $usergroup mkdir omnienv
python3 -m venv omnienv
source omnienv/bin/activate
pip3 install wheel
pip3 install requests
pip3 install setproctitle
pip3 install munch
pip3 install pyparsing
pip3 install pyzabbix
pip3 install pynetbox
pip3 install easysnmp
pip3 install python-nmap
pip3 install mariadb
pip3 install psycopg2-binary
pip3 install torch
deactivate

read -p "Do you need to install Mariadb server? (yes/No) " yn
case $yn in 
    yes | y | Yes | YES | Y ) apt install -y mariadb-server;;
esac

read -p "Do you need to install PostgreSQL server? (yes/No) " yn
case $yn in 
    yes | y | Yes | YES | Y ) apt install -y postgresql postgresql-contrib postgresql-common;;
esac

read -p "Do you need to install Netbox? (yes/No) " yn
case $yn in 
    yes | y | Yes | YES | Y ) apt install -y redis-server;
        apt install -y postgresql postgresql-contrib postgresql-common;
		useradd -r -d /opt/netbox -s /usr/sbin/nologin netbox;
		apt install -y python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev;
		mkdir -p /opt/netbox; 
		git clone -b master --depth 1 https://github.com/netbox-community/netbox.git /opt/netbox;
		chown -R netbox:netbox /opt/netbox;;
esac

read -p "Do you need to install Zabbix server? (yes/No) " yn
case $yn in 
    yes | y | Yes | YES | Y ) apt install -y nginx;
		wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-5+debian12_all.deb;
		dpkg -i zabbix-release_6.0-5+debian12_all.deb;
		apt -y update;
		rm zabbix-release_6.0-5+debian12_all.deb;
        read -p "Do you want use mariadb or postgresql? (Mariadb/postgresql) " dyn;
        case $dyn in 
            P | p | postgresql | Postgresql | POSTGRESQL ) apt install -y zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent zabbix-proxy-pgsql;;
            * ) apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent zabbix-proxy-mysql;;
	    esac;;
esac
