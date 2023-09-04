#!/bin/bash
usergroup=omnissiah
srcpath=/usr/local/src/omnissiah
usrpath=/usr/local/lib/omnissiah
homepath=/var/lib/omnissiah
logpath=/var/log/omnissiah

sudo -u $usergroup cp -r $srcpath/code/* $usrpath
