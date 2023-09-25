CREATE TABLE IF NOT EXISTS zbx_zbx_proxies ( 
  proxyid BIGINT PRIMARY KEY NOT NULL CHECK (proxyid>=0), 
  proxy VARCHAR(128) NOT NULL UNIQUE, 
  name VARCHAR(128) NOT NULL DEFAULT '' 
);
CREATE INDEX ON zbx_zbx_proxies (name);
  
CREATE TABLE IF NOT EXISTS zbx_zbx_maintenances (
  maintenanceid BIGINT PRIMARY KEY NOT NULL CHECK (maintenanceid>=0),
  name VARCHAR(128) NOT NULL UNIQUE,
  maintenance_type INT NOT NULL DEFAULT 0,
  active_since INT NOT NULL DEFAULT 0,
  active_till INT NOT NULL DEFAULT 0
);
CREATE INDEX ON zbx_zbx_maintenances (active_since, active_till);

CREATE TABLE IF NOT EXISTS zbx_zbx_hosts (
  hostid BIGINT PRIMARY KEY NOT NULL CHECK (hostid>=0), 
  proxy_hostid BIGINT DEFAULT NULL CHECK (proxy_hostid>=0), 
  host VARCHAR(128) NOT NULL UNIQUE, 
  status INT NOT NULL, 
  ipmi_authtype INT NOT NULL DEFAULT -1, 
  ipmi_privilege INT NOT NULL DEFAULT 2, 
  ipmi_username VARCHAR(16) NOT NULL DEFAULT '', 
  ipmi_password VARCHAR(20) NOT NULL DEFAULT '', 
  maintenanceid BIGINT DEFAULT NULL CHECK (maintenanceid>=0), 
  maintenance_status INT NOT NULL DEFAULT 0, 
  maintenance_type INT NOT NULL DEFAULT 0, 
  maintenance_from INT NOT NULL DEFAULT 0, 
  name VARCHAR(128) NOT NULL DEFAULT '', 
  flags INT NOT NULL DEFAULT 0, 
  description TEXT NOT NULL, 
  tls_connect INT NOT NULL DEFAULT 1, 
  tls_accept INT NOT NULL DEFAULT 1, 
  tls_issuer VARCHAR(1024) NOT NULL DEFAULT '', 
  tls_subject VARCHAR(1024) NOT NULL DEFAULT '', 
  lastaccess INT NOT NULL DEFAULT 0, 
  CONSTRAINT maintenanceid_zzh FOREIGN KEY (maintenanceid) REFERENCES zbx_zbx_maintenances (maintenanceid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT proxy_hostid_zzh FOREIGN KEY (proxy_hostid) REFERENCES zbx_zbx_proxies (proxyid) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE INDEX ON zbx_zbx_hosts (status);
CREATE INDEX ON zbx_zbx_hosts (proxy_hostid);
CREATE INDEX ON zbx_zbx_hosts (name);
CREATE INDEX ON zbx_zbx_hosts (maintenanceid);

CREATE TABLE IF NOT EXISTS zbx_zbx_hstgrp (
  groupid BIGINT PRIMARY KEY NOT NULL CHECK (groupid>=0), 
  name VARCHAR(255) NOT NULL UNIQUE, 
  internal INT NOT NULL DEFAULT 0, 
  flags INT NOT NULL DEFAULT 0 
);

CREATE TABLE IF NOT EXISTS zbx_zbx_hosts_templates (
  hosttemplateid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  templateid BIGINT NOT NULL CHECK (templateid>=0), 
  CONSTRAINT hostid_zzht FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT templateid_zzht FOREIGN KEY (templateid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_hosts_templates (hostid, templateid);
CREATE INDEX ON zbx_zbx_hosts_templates (hostid);
CREATE INDEX ON zbx_zbx_hosts_templates (templateid);

CREATE TABLE IF NOT EXISTS zbx_zbx_hosts_groups (
  hostgroupid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  groupid BIGINT NOT NULL CHECK (groupid>=0), 
  CONSTRAINT hostid_zzhg FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT groupid_zzhg FOREIGN KEY (groupid) REFERENCES zbx_zbx_hstgrp (groupid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_hosts_groups (hostid, groupid);
CREATE INDEX ON zbx_zbx_hosts_groups (hostid);
CREATE INDEX ON zbx_zbx_hosts_groups (groupid);

CREATE TABLE IF NOT EXISTS zbx_zbx_interface (
  interfaceid BIGINT PRIMARY KEY NOT NULL CHECK (interfaceid>=0), 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  main INT NOT NULL DEFAULT 0, 
  type INT NOT NULL DEFAULT 1, 
  useip INT NOT NULL DEFAULT 1, 
  ip VARCHAR(64) NOT NULL DEFAULT '127.0.0.1', 
  dns VARCHAR(255) NOT NULL DEFAULT '', 
  port VARCHAR(64) NOT NULL DEFAULT '10050', 
  available INT NOT NULL DEFAULT 0, 
  error VARCHAR(2048) NOT NULL DEFAULT '', 
  errors_from INT NOT NULL DEFAULT 0, 
  disable_until INT NOT NULL DEFAULT 0, 
  version INT DEFAULT NULL, 
  bulk INT DEFAULT NULL, 
  community VARCHAR(50) DEFAULT NULL, 
  securityname VARCHAR(50) DEFAULT NULL, 
  securitylevel INT DEFAULT NULL, 
  authpassphrase VARCHAR(50) DEFAULT NULL, 
  privpassphrase VARCHAR(50) DEFAULT NULL, 
  authprotocol INT DEFAULT NULL, 
  privprotocol INT DEFAULT NULL, 
  contextname VARCHAR(50) DEFAULT NULL, 
  CONSTRAINT hostid_zzi FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON zbx_zbx_interface (hostid, type, main);
CREATE INDEX ON zbx_zbx_interface (hostid, type);
CREATE INDEX ON zbx_zbx_interface (hostid);
CREATE INDEX ON zbx_zbx_interface (type);
CREATE INDEX ON zbx_zbx_interface (ip);
CREATE INDEX ON zbx_zbx_interface (ip, dns);
CREATE INDEX ON zbx_zbx_interface (main);
CREATE INDEX ON zbx_zbx_interface (available);

CREATE TABLE IF NOT EXISTS zbx_zbx_hostmacro (
  hostmacroid BIGINT PRIMARY KEY NOT NULL CHECK (hostmacroid>=0), 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  macro VARCHAR(255) NOT NULL DEFAULT '', 
  value VARCHAR(2048) DEFAULT NULL, 
  description TEXT NOT NULL, 
  type INT NOT NULL DEFAULT 0, 
  CONSTRAINT hostid_zzhm FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_hostmacro (hostid, macro);
CREATE INDEX ON zbx_zbx_hostmacro (hostid);
CREATE INDEX ON zbx_zbx_hostmacro (macro);

CREATE TABLE IF NOT EXISTS zbx_zbx_host_tag (
  hosttagid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  tag VARCHAR(255) NOT NULL DEFAULT '', 
  value VARCHAR(255) NOT NULL DEFAULT '', 
  CONSTRAINT hostid_zzhtg FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_host_tag (hostid, tag, value);
CREATE INDEX ON zbx_zbx_host_tag (hostid, tag);
CREATE INDEX ON zbx_zbx_host_tag (tag, value);
CREATE INDEX ON zbx_zbx_host_tag (hostid);
CREATE INDEX ON zbx_zbx_host_tag (tag);

CREATE TABLE IF NOT EXISTS zbx_zbx_host_inventory (
  hostid BIGINT PRIMARY KEY NOT NULL CHECK (hostid>=0), 
  inventory_mode INT NOT NULL DEFAULT 0,
  type VARCHAR(64) NOT NULL DEFAULT '',
  type_full VARCHAR(64) NOT NULL DEFAULT '',
  name VARCHAR(128) NOT NULL DEFAULT '',
  alias VARCHAR(128) NOT NULL DEFAULT '',
  os VARCHAR(128) NOT NULL DEFAULT '',
  os_full VARCHAR(255) NOT NULL DEFAULT '',
  os_short VARCHAR(128) NOT NULL DEFAULT '',
  serialno_a VARCHAR(64) NOT NULL DEFAULT '',
  serialno_b VARCHAR(64) NOT NULL DEFAULT '',
  tag VARCHAR(64) NOT NULL DEFAULT '',
  asset_tag VARCHAR(64) NOT NULL DEFAULT '',
  macaddress_a VARCHAR(64) NOT NULL DEFAULT '',
  macaddress_b VARCHAR(64) NOT NULL DEFAULT '',
  hardware VARCHAR(255) NOT NULL DEFAULT '',
  hardware_full TEXT NOT NULL,
  software VARCHAR(255) NOT NULL DEFAULT '',
  software_full TEXT NOT NULL,
  software_app_a VARCHAR(64) NOT NULL DEFAULT '',
  software_app_b VARCHAR(64) NOT NULL DEFAULT '',
  software_app_c VARCHAR(64) NOT NULL DEFAULT '',
  software_app_d VARCHAR(64) NOT NULL DEFAULT '',
  software_app_e VARCHAR(64) NOT NULL DEFAULT '',
  contact TEXT NOT NULL,
  location TEXT NOT NULL,
  location_lat VARCHAR(16) NOT NULL DEFAULT '',
  location_lon VARCHAR(16) NOT NULL DEFAULT '',
  notes TEXT NOT NULL,
  chassis VARCHAR(64) NOT NULL DEFAULT '',
  model VARCHAR(64) NOT NULL DEFAULT '',
  hw_arch VARCHAR(32) NOT NULL DEFAULT '',
  vendor VARCHAR(64) NOT NULL DEFAULT '',
  contract_number VARCHAR(64) NOT NULL DEFAULT '',
  installer_name VARCHAR(64) NOT NULL DEFAULT '',
  deployment_status VARCHAR(64) NOT NULL DEFAULT '',
  url_a VARCHAR(255) NOT NULL DEFAULT '',
  url_b VARCHAR(255) NOT NULL DEFAULT '',
  url_c VARCHAR(255) NOT NULL DEFAULT '',
  host_networks TEXT NOT NULL,
  host_netmask VARCHAR(39) NOT NULL DEFAULT '',
  host_router VARCHAR(39) NOT NULL DEFAULT '',
  oob_ip VARCHAR(39) NOT NULL DEFAULT '',
  oob_netmask VARCHAR(39) NOT NULL DEFAULT '',
  oob_router VARCHAR(39) NOT NULL DEFAULT '',
  date_hw_purchase VARCHAR(64) NOT NULL DEFAULT '',
  date_hw_install VARCHAR(64) NOT NULL DEFAULT '',
  date_hw_expiry VARCHAR(64) NOT NULL DEFAULT '',
  date_hw_decomm VARCHAR(64) NOT NULL DEFAULT '',
  site_address_a VARCHAR(128) NOT NULL DEFAULT '',
  site_address_b VARCHAR(128) NOT NULL DEFAULT '',
  site_address_c VARCHAR(128) NOT NULL DEFAULT '',
  site_city VARCHAR(128) NOT NULL DEFAULT '',
  site_state VARCHAR(64) NOT NULL DEFAULT '',
  site_country VARCHAR(64) NOT NULL DEFAULT '',
  site_zip VARCHAR(64) NOT NULL DEFAULT '',
  site_rack VARCHAR(128) NOT NULL DEFAULT '',
  site_notes TEXT NOT NULL,
  poc_1_name VARCHAR(128) NOT NULL DEFAULT '',
  poc_1_email VARCHAR(128) NOT NULL DEFAULT '',
  poc_1_phone_a VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_phone_b VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_cell VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_screen VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_notes TEXT NOT NULL,
  poc_2_name VARCHAR(128) NOT NULL DEFAULT '',
  poc_2_email VARCHAR(128) NOT NULL DEFAULT '',
  poc_2_phone_a VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_phone_b VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_cell VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_screen VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_notes TEXT NOT NULL,
  CONSTRAINT hostid_zzhi FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS zbx_zbx_items (
itemid BIGINT NOT NULL PRIMARY KEY CHECK (itemid>=0), 
type INT NOT NULL DEFAULT 0, 
snmp_oid VARCHAR(512) NOT NULL DEFAULT '', 
hostid BIGINT NOT NULL CHECK (hostid>=0), 
name VARCHAR(255) NOT NULL DEFAULT '', 
key_ VARCHAR(2048) NOT NULL DEFAULT '', 
delay VARCHAR(1024) NOT NULL DEFAULT '0', 
history VARCHAR(255) NOT NULL DEFAULT '90d', 
trends VARCHAR(255) NOT NULL DEFAULT '365d', 
status INT NOT NULL DEFAULT 0, 
value_type INT NOT NULL DEFAULT 0, 
trapper_hosts VARCHAR(255) NOT NULL DEFAULT '', 
units VARCHAR(255) NOT NULL DEFAULT '', 
logtimefmt VARCHAR(64) NOT NULL DEFAULT '', 
templateid BIGINT DEFAULT NULL CHECK (templateid>=0), 
valuemapid BIGINT DEFAULT NULL CHECK (valuemapid>=0), 
params TEXT NOT NULL, 
ipmi_sensor VARCHAR(128) NOT NULL DEFAULT '', 
authtype INT NOT NULL DEFAULT 0, 
username VARCHAR(64) NOT NULL DEFAULT '', 
password VARCHAR(64) NOT NULL DEFAULT '', 
publickey VARCHAR(64) NOT NULL DEFAULT '', 
privatekey VARCHAR(64) NOT NULL DEFAULT '', 
flags INT NOT NULL DEFAULT 0, 
interfaceid BIGINT DEFAULT NULL CHECK (interfaceid>=0), 
description TEXT NOT NULL, 
inventory_link INT NOT NULL DEFAULT 0, 
jmx_endpoint VARCHAR(255) NOT NULL DEFAULT '', 
master_itemid BIGINT DEFAULT NULL CHECK (master_itemid>=0), 
timeout VARCHAR(255) NOT NULL DEFAULT '3s', 
url VARCHAR(2048) NOT NULL DEFAULT '', 
query_fields VARCHAR(2048) NOT NULL DEFAULT '', 
posts TEXT NOT NULL, 
status_codes VARCHAR(255) NOT NULL DEFAULT '200', 
follow_redirects INT NOT NULL DEFAULT 1, 
post_type INT NOT NULL DEFAULT 0, 
http_proxy VARCHAR(255) NOT NULL DEFAULT '', 
headers TEXT NOT NULL, 
retrieve_mode INT NOT NULL DEFAULT 0, 
request_method INT NOT NULL DEFAULT 0, 
output_format INT NOT NULL DEFAULT 0, 
ssl_cert_file VARCHAR(255) NOT NULL DEFAULT '', 
ssl_key_file VARCHAR(255) NOT NULL DEFAULT '', 
ssl_key_password VARCHAR(64) NOT NULL DEFAULT '', 
verify_peer INT NOT NULL DEFAULT 0, 
verify_host INT NOT NULL DEFAULT 0, 
allow_traps INT NOT NULL DEFAULT 0, 
state INT NOT NULL, 
error VARCHAR(255) DEFAULT NULL, 
CONSTRAINT hostid_zzit FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
CONSTRAINT templateid_zzit FOREIGN KEY (templateid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE, 
CONSTRAINT interfaceid_zzit FOREIGN KEY (interfaceid) REFERENCES zbx_zbx_interface (interfaceid) ON DELETE SET NULL ON UPDATE CASCADE, 
CONSTRAINT master_itemid_zzit FOREIGN KEY (master_itemid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON zbx_zbx_items (hostid, key_);
CREATE INDEX ON zbx_zbx_items (status);
CREATE INDEX ON zbx_zbx_items (hostid);
CREATE INDEX ON zbx_zbx_items (templateid);
CREATE INDEX ON zbx_zbx_items (valuemapid);
CREATE INDEX ON zbx_zbx_items (interfaceid);
CREATE INDEX ON zbx_zbx_items (master_itemid);
CREATE INDEX ON zbx_zbx_items (key_);

CREATE TABLE IF NOT EXISTS zbx_zbx_triggers (
triggerid BIGINT NOT NULL PRIMARY KEY CHECK (triggerid>=0), 
hostid BIGINT NOT NULL CHECK (hostid>=0), 
expression VARCHAR(2048) NOT NULL DEFAULT '', 
description TEXT NOT NULL, 
url VARCHAR(255) NOT NULL DEFAULT '', 
status INT NOT NULL DEFAULT 0, 
value INT NOT NULL DEFAULT 0, 
priority INT NOT NULL DEFAULT 0, 
lastchange INT NOT NULL DEFAULT 0, 
comments TEXT NOT NULL, 
error VARCHAR(2048) NOT NULL DEFAULT '', 
templateid BIGINT DEFAULT NULL CHECK (templateid>=0), 
type INT NOT NULL DEFAULT 0, 
state INT NOT NULL DEFAULT 0, 
flags INT NOT NULL DEFAULT 0, 
recovery_mode INT NOT NULL DEFAULT 0, 
recovery_expression VARCHAR(2048) NOT NULL DEFAULT '', 
correlation_mode INT NOT NULL DEFAULT 0, 
correlation_tag VARCHAR(255) NOT NULL DEFAULT '', 
manual_close INT NOT NULL DEFAULT 0, 
opdata VARCHAR(255) NOT NULL DEFAULT '', 
event_name VARCHAR(2048) NOT NULL DEFAULT '', 
CONSTRAINT hostid_zzt FOREIGN KEY (hostid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON zbx_zbx_triggers (status);
CREATE INDEX ON zbx_zbx_triggers (templateid);
CREATE INDEX ON zbx_zbx_triggers (value, lastchange);
CREATE INDEX ON zbx_zbx_triggers (hostid);

CREATE TABLE IF NOT EXISTS zbx_zbx_history (
historyid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
itemid BIGINT NOT NULL CHECK (itemid>=0), 
clock INT NOT NULL DEFAULT 0, 
value DOUBLE PRECISION NOT NULL DEFAULT 0, 
ns INT NOT NULL DEFAULT 0, 
CONSTRAINT itemid_zzhi FOREIGN KEY (itemid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_history (itemid, clock, ns); 
CREATE INDEX ON zbx_zbx_history (itemid); 

CREATE TABLE IF NOT EXISTS zbx_zbx_history_uint (
historyid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
itemid BIGINT NOT NULL CHECK (itemid>=0), 
clock INT NOT NULL DEFAULT 0, 
value BIGINT NOT NULL DEFAULT 0 CHECK (value>=0), 
ns INT NOT NULL DEFAULT 0, 
CONSTRAINT itemid_zzhu FOREIGN KEY (itemid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_history_uint (itemid, clock, ns); 
CREATE INDEX ON zbx_zbx_history_uint (itemid); 

CREATE TABLE IF NOT EXISTS zbx_zbx_history_str (
historyid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
itemid BIGINT NOT NULL CHECK (itemid>=0), 
clock INT NOT NULL DEFAULT 0, 
value VARCHAR(255) NOT NULL DEFAULT '', 
ns INT NOT NULL DEFAULT 0, 
CONSTRAINT itemid_zzhs FOREIGN KEY (itemid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_history_str (itemid, clock, ns); 
CREATE INDEX ON zbx_zbx_history_str (itemid); 

CREATE TABLE IF NOT EXISTS zbx_zbx_history_text (
historyid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
itemid BIGINT NOT NULL CHECK (itemid>=0), 
clock INT NOT NULL DEFAULT 0, 
value TEXT NOT NULL, 
ns INT NOT NULL DEFAULT 0, 
CONSTRAINT itemid_zzht FOREIGN KEY (itemid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_history_text (itemid, clock, ns); 
CREATE INDEX ON zbx_zbx_history_text (itemid); 

CREATE TABLE IF NOT EXISTS zbx_zbx_history_log (
historyid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
itemid BIGINT NOT NULL CHECK (itemid>=0), 
clock INT NOT NULL DEFAULT 0, 
value TEXT NOT NULL, 
ns INT NOT NULL DEFAULT 0, 
CONSTRAINT itemid_zzhl FOREIGN KEY (itemid) REFERENCES zbx_zbx_items (itemid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_zbx_history_log (itemid, clock, ns); 
CREATE INDEX ON zbx_zbx_history_log (itemid); 

CREATE TABLE IF NOT EXISTS zbx_omni_maintenances (
  maintenanceid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  name VARCHAR(128) NOT NULL UNIQUE, 
  maintenance_type INT NOT NULL DEFAULT 0, 
  active_since INT NOT NULL DEFAULT 0, 
  active_till INT NOT NULL DEFAULT 0 
);
CREATE INDEX ON zbx_omni_maintenances (active_since, active_till);
  
CREATE TABLE IF NOT EXISTS zbx_omni_hstgrp (
  groupid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  name VARCHAR(255) NOT NULL UNIQUE, 
  internal INT NOT NULL DEFAULT 0, 
  flags INT NOT NULL DEFAULT 0,
  typeid INT NOT NULL CHECK (typeid>=0), 
  srcid BIGINT NOT NULL CHECK (srcid>=0), 
  CONSTRAINT typeid_zoh FOREIGN KEY (typeid) REFERENCES ref_zbx_group (groupid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_hstgrp (typeid, srcid);
CREATE INDEX ON zbx_omni_hstgrp (typeid);
CREATE INDEX ON zbx_omni_hstgrp (srcid);

CREATE TABLE IF NOT EXISTS zbx_omni_hosts (
  hostid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  proxy_hostid BIGINT DEFAULT NULL CHECK (proxy_hostid>=0), 
  host VARCHAR(128) NOT NULL UNIQUE, 
  status INT NOT NULL, 
  ipmi_authtype INT NOT NULL DEFAULT -1, 
  ipmi_privilege INT NOT NULL DEFAULT 2, 
  ipmi_username VARCHAR(16) NOT NULL DEFAULT '', 
  ipmi_password VARCHAR(20) NOT NULL DEFAULT '', 
  maintenanceid BIGINT DEFAULT NULL CHECK (maintenanceid>=0), 
  maintenance_status INT NOT NULL DEFAULT 0, 
  maintenance_type INT NOT NULL DEFAULT 0, 
  maintenance_from INT NOT NULL DEFAULT 0, 
  name VARCHAR(128) NOT NULL DEFAULT '', 
  flags INT NOT NULL DEFAULT 0, 
  description TEXT NOT NULL, 
  tls_connect INT NOT NULL DEFAULT 1, 
  tls_accept INT NOT NULL DEFAULT 1, 
  tls_issuer VARCHAR(1024) NOT NULL DEFAULT '', 
  tls_subject VARCHAR(1024) NOT NULL DEFAULT '', 
  main_hostid BIGINT DEFAULT NULL UNIQUE, 
  zbx_groupid BIGINT DEFAULT NULL UNIQUE CHECK (zbx_groupid>=0), 
  CONSTRAINT maintenanceid_zoh FOREIGN KEY (maintenanceid) REFERENCES zbx_omni_maintenances (maintenanceid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT proxy_hostid_zoh FOREIGN KEY (proxy_hostid) REFERENCES zbx_zbx_proxies (proxyid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT main_hostid_zoh FOREIGN KEY (main_hostid) REFERENCES main_host (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT zbx_groupid_zoh FOREIGN KEY (zbx_groupid) REFERENCES zbx_omni_hstgrp (groupid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON zbx_omni_hosts (status);
CREATE INDEX ON zbx_omni_hosts (proxy_hostid);
CREATE INDEX ON zbx_omni_hosts (name);
CREATE INDEX ON zbx_omni_hosts (maintenanceid);

CREATE TABLE IF NOT EXISTS zbx_omni_hosts_templates (
  hosttemplateid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  templateid BIGINT NOT NULL CHECK (templateid>=0), 
  CONSTRAINT hostid_zoht FOREIGN KEY (hostid) REFERENCES zbx_omni_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT templateid_zoht FOREIGN KEY (templateid) REFERENCES zbx_zbx_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_hosts_templates (hostid, templateid);
CREATE INDEX ON zbx_omni_hosts_templates (hostid);
CREATE INDEX ON zbx_omni_hosts_templates (templateid);

CREATE TABLE IF NOT EXISTS zbx_omni_hosts_groups (
  hostgroupid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  groupid BIGINT NOT NULL CHECK (groupid>=0), 
  CONSTRAINT hostid_zohg FOREIGN KEY (hostid) REFERENCES zbx_omni_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT groupid_zohg FOREIGN KEY (groupid) REFERENCES zbx_omni_hstgrp (groupid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_hosts_groups (hostid, groupid); 
CREATE INDEX ON zbx_omni_hosts_groups (hostid); 
CREATE INDEX ON zbx_omni_hosts_groups (groupid); 

CREATE TABLE IF NOT EXISTS zbx_omni_interface (
  interfaceid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  main INT NOT NULL DEFAULT 0, 
  type INT NOT NULL DEFAULT 1, 
  useip INT NOT NULL DEFAULT 1, 
  ip VARCHAR(64) NOT NULL DEFAULT '127.0.0.1', 
  dns VARCHAR(255) NOT NULL DEFAULT '', 
  port VARCHAR(64) NOT NULL DEFAULT '10050', 
  available INT NOT NULL DEFAULT 0, 
  error VARCHAR(2048) NOT NULL DEFAULT '', 
  errors_from INT NOT NULL DEFAULT 0, 
  disable_until INT NOT NULL DEFAULT 0, 
  version INT DEFAULT NULL, 
  bulk INT DEFAULT NULL, 
  community VARCHAR(50) DEFAULT NULL, 
  securityname VARCHAR(50) DEFAULT NULL, 
  securitylevel INT DEFAULT NULL, 
  authpassphrase VARCHAR(50) DEFAULT NULL, 
  privpassphrase VARCHAR(50) DEFAULT NULL, 
  authprotocol INT DEFAULT NULL, 
  privprotocol INT DEFAULT NULL, 
  contextname VARCHAR(50) DEFAULT NULL, 
  CONSTRAINT hostid_zoi FOREIGN KEY (hostid) REFERENCES zbx_omni_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_interface (hostid, type, main); 
CREATE INDEX ON zbx_omni_interface (hostid, type); 
CREATE INDEX ON zbx_omni_interface (hostid); 
CREATE INDEX ON zbx_omni_interface (type); 
CREATE INDEX ON zbx_omni_interface (ip); 
CREATE INDEX ON zbx_omni_interface (ip, dns); 
CREATE INDEX ON zbx_omni_interface (main); 
CREATE INDEX ON zbx_omni_interface (available); 

CREATE TABLE IF NOT EXISTS zbx_omni_hostmacro (
  hostmacroid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  macro VARCHAR(255) NOT NULL DEFAULT '', 
  value VARCHAR(2048) DEFAULT NULL, 
  description TEXT NOT NULL, 
  type INT NOT NULL DEFAULT 0, 
  CONSTRAINT hostid_zohm FOREIGN KEY (hostid) REFERENCES zbx_omni_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_hostmacro (hostid, macro); 
CREATE INDEX ON zbx_omni_hostmacro (hostid); 
CREATE INDEX ON zbx_omni_hostmacro (macro); 

CREATE TABLE IF NOT EXISTS zbx_omni_host_tag (
  hosttagid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  hostid BIGINT NOT NULL CHECK (hostid>=0), 
  tag VARCHAR(255) NOT NULL DEFAULT '', 
  value VARCHAR(255) NOT NULL DEFAULT '', 
  CONSTRAINT hostid_zohtg FOREIGN KEY (hostid) REFERENCES zbx_omni_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_host_tag (hostid, tag); 
CREATE INDEX ON zbx_omni_host_tag (tag, value); 
CREATE INDEX ON zbx_omni_host_tag (hostid); 
CREATE INDEX ON zbx_omni_host_tag (tag); 

CREATE TABLE IF NOT EXISTS zbx_omni_host_inventory (
  hostid BIGINT PRIMARY KEY NOT NULL CHECK (hostid>=0), 
  inventory_mode INT NOT NULL DEFAULT 0,
  type VARCHAR(64) NOT NULL DEFAULT '',
  type_full VARCHAR(64) NOT NULL DEFAULT '',
  name VARCHAR(128) NOT NULL DEFAULT '',
  alias VARCHAR(128) NOT NULL DEFAULT '',
  os VARCHAR(128) NOT NULL DEFAULT '',
  os_full VARCHAR(255) NOT NULL DEFAULT '',
  os_short VARCHAR(128) NOT NULL DEFAULT '',
  serialno_a VARCHAR(64) NOT NULL DEFAULT '',
  serialno_b VARCHAR(64) NOT NULL DEFAULT '',
  tag VARCHAR(64) NOT NULL DEFAULT '',
  asset_tag VARCHAR(64) NOT NULL DEFAULT '',
  macaddress_a VARCHAR(64) NOT NULL DEFAULT '',
  macaddress_b VARCHAR(64) NOT NULL DEFAULT '',
  hardware VARCHAR(255) NOT NULL DEFAULT '',
  hardware_full TEXT NOT NULL,
  software VARCHAR(255) NOT NULL DEFAULT '',
  software_full TEXT NOT NULL,
  software_app_a VARCHAR(64) NOT NULL DEFAULT '',
  software_app_b VARCHAR(64) NOT NULL DEFAULT '',
  software_app_c VARCHAR(64) NOT NULL DEFAULT '',
  software_app_d VARCHAR(64) NOT NULL DEFAULT '',
  software_app_e VARCHAR(64) NOT NULL DEFAULT '',
  contact TEXT NOT NULL,
  location TEXT NOT NULL,
  location_lat VARCHAR(16) NOT NULL DEFAULT '',
  location_lon VARCHAR(16) NOT NULL DEFAULT '',
  notes TEXT NOT NULL,
  chassis VARCHAR(64) NOT NULL DEFAULT '',
  model VARCHAR(64) NOT NULL DEFAULT '',
  hw_arch VARCHAR(32) NOT NULL DEFAULT '',
  vendor VARCHAR(64) NOT NULL DEFAULT '',
  contract_number VARCHAR(64) NOT NULL DEFAULT '',
  installer_name VARCHAR(64) NOT NULL DEFAULT '',
  deployment_status VARCHAR(64) NOT NULL DEFAULT '',
  url_a VARCHAR(255) NOT NULL DEFAULT '',
  url_b VARCHAR(255) NOT NULL DEFAULT '',
  url_c VARCHAR(255) NOT NULL DEFAULT '',
  host_networks TEXT NOT NULL,
  host_netmask VARCHAR(39) NOT NULL DEFAULT '',
  host_router VARCHAR(39) NOT NULL DEFAULT '',
  oob_ip VARCHAR(39) NOT NULL DEFAULT '',
  oob_netmask VARCHAR(39) NOT NULL DEFAULT '',
  oob_router VARCHAR(39) NOT NULL DEFAULT '',
  date_hw_purchase VARCHAR(64) NOT NULL DEFAULT '',
  date_hw_install VARCHAR(64) NOT NULL DEFAULT '',
  date_hw_expiry VARCHAR(64) NOT NULL DEFAULT '',
  date_hw_decomm VARCHAR(64) NOT NULL DEFAULT '',
  site_address_a VARCHAR(128) NOT NULL DEFAULT '',
  site_address_b VARCHAR(128) NOT NULL DEFAULT '',
  site_address_c VARCHAR(128) NOT NULL DEFAULT '',
  site_city VARCHAR(128) NOT NULL DEFAULT '',
  site_state VARCHAR(64) NOT NULL DEFAULT '',
  site_country VARCHAR(64) NOT NULL DEFAULT '',
  site_zip VARCHAR(64) NOT NULL DEFAULT '',
  site_rack VARCHAR(128) NOT NULL DEFAULT '',
  site_notes TEXT NOT NULL,
  poc_1_name VARCHAR(128) NOT NULL DEFAULT '',
  poc_1_email VARCHAR(128) NOT NULL DEFAULT '',
  poc_1_phone_a VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_phone_b VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_cell VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_screen VARCHAR(64) NOT NULL DEFAULT '',
  poc_1_notes TEXT NOT NULL,
  poc_2_name VARCHAR(128) NOT NULL DEFAULT '',
  poc_2_email VARCHAR(128) NOT NULL DEFAULT '',
  poc_2_phone_a VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_phone_b VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_cell VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_screen VARCHAR(64) NOT NULL DEFAULT '',
  poc_2_notes TEXT NOT NULL,
  CONSTRAINT hostid_zohi FOREIGN KEY (hostid) REFERENCES zbx_omni_hosts (hostid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS zbx_omni_map (
  mapid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  typeid INT NOT NULL CHECK (typeid>=0),
  omniid BIGINT DEFAULT NULL CHECK (omniid>=0), 
  zbxid BIGINT DEFAULT NULL CHECK (zbxid>=0), 
  CONSTRAINT typeid_zop FOREIGN KEY (typeid) REFERENCES ref_zbx_omni_map (mapid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON zbx_omni_map (omniid, typeid);
CREATE UNIQUE INDEX ON zbx_omni_map (zbxid, typeid);
CREATE INDEX ON zbx_omni_map (typeid);
CREATE INDEX ON zbx_omni_map (omniid);
CREATE INDEX ON zbx_omni_map (zbxid);
