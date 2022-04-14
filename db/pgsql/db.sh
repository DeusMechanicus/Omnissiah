#!/bin/bash
sudo -u postgres bash
createuser --pwomnissiah omnissiah
createdb -O omnissiah -E Unicode -T template0 omnissiah
