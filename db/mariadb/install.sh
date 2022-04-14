#!/bin/bash
mysql -h localhost -u root -pomnissiah < db.sql

mysql -h localhost -u root -pomnissiah < cfg.sql
mysql -h localhost -u root -pomnissiah < code.sql
mysql -h localhost -u root -pomnissiah < log.sql
mysql -h localhost -u root -pomnissiah < pre.sql
mysql -h localhost -u root -pomnissiah < ref.sql
mysql -h localhost -u root -pomnissiah < raw.sql
mysql -h localhost -u root -pomnissiah < src.sql
mysql -h localhost -u root -pomnissiah < nnml.sql
mysql -h localhost -u root -pomnissiah < main.sql
mysql -h localhost -u root -pomnissiah < hist.sql
mysql -h localhost -u root -pomnissiah < zbx.sql
mysql -h localhost -u root -pomnissiah < tmp.sql
mysql -h localhost -u root -pomnissiah < cfg_data.sql
mysql -h localhost -u root -pomnissiah < code_data.sql
mysql -h localhost -u root -pomnissiah < ref_data.sql
