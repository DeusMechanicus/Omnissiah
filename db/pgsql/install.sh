#!/bin/bash
sudo -u postgres bash
createuser --pwomnissiah omnissiah
createdb -O omnissiah -E Unicode -T template0 omnissiah

psql omnissiah < cfg.sql
psql omnissiah < code.sql
psql omnissiah < log.sql
psql omnissiah < pre.sql
psql omnissiah < ref.sql
psql omnissiah < raw.sql
psql omnissiah < info.sql
psql omnissiah < src.sql
psql omnissiah < nnml.sql
psql omnissiah < main.sql
psql omnissiah < hist.sql
psql omnissiah < zbx.sql
psql omnissiah < tmp.sql
psql omnissiah < cfg_data.sql
psql omnissiah < code_data.sql
psql omnissiah < ref_data.sql
