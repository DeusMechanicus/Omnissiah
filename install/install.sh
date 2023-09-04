#!/bin/bash
usergroup=omnissiah
srcpath=/usr/local/src/omnissiah
usrpath=/usr/local/lib/omnissiah
homepath=/var/lib/omnissiah
logpath=/var/log/omnissiah

adduser --system --home $homepath --group --disabled-login $usergroup
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

apt install -y gcc python-dev
apt install -y snmp libsnmp-dev
apt install -y mariadb-client libmariadb-dev
apt install -y postgresql-client
apt install -y python3-pip
apt install -y python3-venv
apt install -y nmap
cp $srcpath/share/nmap/*.lua /usr/share/nmap/nselib
cp $srcpath/share/nmap/*.nse /usr/share/nmap/scripts

cd $usrpath
mkdir omnienv
sudo -u $usergroup python3 -m venv omnienv
source omnienv/bin/activate
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
