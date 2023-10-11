CREATE TABLE IF NOT EXISTS src_enplug_venue (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  venueid VARCHAR(256) NOT NULL UNIQUE,
  venuename VARCHAR(256) NOT NULL,
  venue_timezone VARCHAR(100) NOT NULL 
);
CREATE INDEX ON src_enplug_venue (venuename);
  
CREATE TABLE IF NOT EXISTS src_enplug_edu (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  eduid VARCHAR(256) NOT NULL UNIQUE, 
  venueid VARCHAR(256) NOT NULL, 
  eduname VARCHAR(256) NOT NULL, 
  mac_eth VARCHAR(12) DEFAULT NULL, 
  mac_wifi VARCHAR(12) DEFAULT NULL, 
  ip VARCHAR(39) DEFAULT NULL, 
  ip_public VARCHAR(39) DEFAULT NULL, 
  status_code VARCHAR(20) NOT NULL,
  status_message VARCHAR(1024) DEFAULT NULL,
  tvstatus VARCHAR(100) DEFAULT NULL,
  player_version VARCHAR(20) DEFAULT NULL, 
  player_uptime INT DEFAULT NULL, 
  last_player_heartbeat TIMESTAMP DEFAULT NULL, 
  CONSTRAINT venueid_see FOREIGN KEY (venueid) REFERENCES src_enplug_venue (venueid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_enplug_edu (venueid);
CREATE INDEX ON src_enplug_edu (eduname);
CREATE INDEX ON src_enplug_edu (mac_eth);
CREATE INDEX ON src_enplug_edu (mac_wifi);
CREATE INDEX ON src_enplug_edu (ip);
CREATE INDEX ON src_enplug_edu (ip_public);
CREATE INDEX ON src_enplug_edu (status_code);

CREATE TABLE IF NOT EXISTS src_activaire (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  activaireid VARCHAR(256) NOT NULL UNIQUE, 
  activairename VARCHAR(256) NOT NULL, 
  mac VARCHAR(12) DEFAULT NULL,
  mac_eth VARCHAR(12) DEFAULT NULL, 
  lastonline TIMESTAMP DEFAULT NULL, 
  isplaying SMALLINT DEFAULT NULL,
  device_status VARCHAR(20) NOT NULL,
  ip VARCHAR(39) DEFAULT NULL, 
  ip_public VARCHAR(39) DEFAULT NULL, 
  make_model VARCHAR(256) DEFAULT NULL,   
  app_version VARCHAR(20) DEFAULT NULL 
);
CREATE INDEX ON src_activaire (activairename);
CREATE INDEX ON src_activaire (mac);
CREATE INDEX ON src_activaire (mac_eth);
CREATE INDEX ON src_activaire (device_status);
CREATE INDEX ON src_activaire (ip);
CREATE INDEX ON src_activaire (ip_public);

CREATE TABLE IF NOT EXISTS src_scan_ip (
  ipid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  refid INT NOT NULL CHECK (refid>=0),  
  sourceid INT NOT NULL, 
  ispublic SMALLINT NOT NULL DEFAULT 0, 
  CONSTRAINT sourceid_ssi FOREIGN KEY (sourceid) REFERENCES ref_ipaddress_source (sourceid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_scan_ip (refid);
CREATE INDEX ON src_scan_ip (sourceid);
CREATE INDEX ON src_scan_ip (ispublic);


CREATE TABLE IF NOT EXISTS src_scan_arp (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  CONSTRAINT routerid_ssa FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_scan_arp (routerid, ip);
CREATE INDEX ON src_scan_arp (ip);
CREATE INDEX ON src_scan_arp (routerid);
CREATE INDEX ON src_scan_arp (mac);

CREATE TABLE IF NOT EXISTS src_scan_dhcp (
  dhcpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  CONSTRAINT routerid_ssa FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_scan_dhcp (routerid, ip);
CREATE INDEX ON src_scan_dhcp (ip);
CREATE INDEX ON src_scan_dhcp (routerid);
CREATE INDEX ON src_scan_dhcp (mac);

CREATE TABLE IF NOT EXISTS src_scan_ip_info (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL,
  infoid INT NOT NULL CHECK (infoid>=1),
  value VARCHAR(256) NOT NULL, 
  CONSTRAINT ipid_ssii FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT infoid_ssii FOREIGN KEY (infoid) REFERENCES ref_scan_ip_info (infoid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_scan_ip_info (ipid, infoid);
CREATE INDEX ON src_scan_ip_info (ipid);
CREATE INDEX ON src_scan_ip_info (infoid);

CREATE TABLE IF NOT EXISTS src_scan_port (
  portid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL,
  type VARCHAR(20) NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  state VARCHAR(20) NOT NULL, 
  reason VARCHAR(20) NOT NULL, 
  CONSTRAINT ipid_ssp FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_scan_port (ipid, type, port);
CREATE INDEX ON src_scan_port (ipid);
CREATE INDEX ON src_scan_port (type);
CREATE INDEX ON src_scan_port (port);
CREATE INDEX ON src_scan_port (state);

CREATE TABLE IF NOT EXISTS src_scan_osmatch (
  osmatchid INT NOT NULL PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  name VARCHAR(256) NOT NULL,
  accuracy INT NOT NULL CHECK (accuracy>=0),
  CONSTRAINT ipid_sso FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_scan_osmatch (ipid);
CREATE INDEX ON src_scan_osmatch (name);
CREATE INDEX ON src_scan_osmatch (accuracy);

CREATE TABLE IF NOT EXISTS src_scan_osclass (
  osclassid INT NOT NULL PRIMARY KEY, 
  osmatchid INT NOT NULL, 
  type VARCHAR(50) DEFAULT NULL, 
  vendor VARCHAR(50) DEFAULT NULL, 
  osfamily VARCHAR(50) DEFAULT NULL, 
  osgen VARCHAR(20) DEFAULT NULL, 
  accuracy INT NOT NULL CHECK (accuracy>=0),
  cpe VARCHAR(100) DEFAULT NULL, 
  CONSTRAINT osmatchid_sso FOREIGN KEY (osmatchid) REFERENCES src_scan_osmatch (osmatchid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_scan_osclass (osmatchid);

CREATE TABLE IF NOT EXISTS src_scan_service (
  portid BIGINT NOT NULL PRIMARY KEY, 
  product VARCHAR(100) DEFAULT NULL, 
  version VARCHAR(50) DEFAULT NULL, 
  extrainfo VARCHAR(256) DEFAULT NULL, 
  conf INT DEFAULT NULL, 
  cpe VARCHAR(100) DEFAULT NULL, 
  name VARCHAR(50) DEFAULT NULL, 
  CONSTRAINT portid_ssse FOREIGN KEY (portid) REFERENCES src_scan_port (portid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_scan_service (product);
CREATE INDEX ON src_scan_service (cpe);

CREATE TABLE IF NOT EXISTS src_scan_script (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  portid BIGINT NOT NULL, 
  script VARCHAR(100) NOT NULL, 
  value VARCHAR(16100) NOT NULL, 
  CONSTRAINT portid_sssc FOREIGN KEY (portid) REFERENCES src_scan_port (portid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_scan_script (portid, script);
CREATE INDEX ON src_scan_script (portid);
CREATE INDEX ON src_scan_script (script);

CREATE TABLE IF NOT EXISTS src_snmp (
  snmpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  oidid INT DEFAULT NULL, 
  oid VARCHAR(256) NOT NULL,
  snmp_type VARCHAR(20) NOT NULL,
  value VARCHAR(1000) NOT NULL, 
  value_hex VARCHAR(2000) NOT NULL, 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  CONSTRAINT ipid_ss FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT oidid_ss FOREIGN KEY (oidid) REFERENCES ref_scan_snmp_oid (oidid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp (ipid, oid);
CREATE INDEX ON src_snmp (ipid);
CREATE INDEX ON src_snmp (oidid);
CREATE INDEX ON src_snmp (oid);
CREATE INDEX ON src_snmp (snmp_type);
CREATE INDEX ON src_snmp (vlan);
  
CREATE TABLE IF NOT EXISTS src_snmp_arp (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  CONSTRAINT routerid_ssna FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_arp (routerid, ip);
CREATE INDEX ON src_snmp_arp (ip);
CREATE INDEX ON src_snmp_arp (routerid);
CREATE INDEX ON src_snmp_arp (mac);

CREATE TABLE IF NOT EXISTS src_snmp_mac (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mac VARCHAR(12) NOT NULL,
  switchid BIGINT NOT NULL,
  port INT NOT NULL CHECK (port>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  CONSTRAINT switchid_ssm FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_mac (switchid, mac, vlan);
CREATE INDEX ON src_snmp_mac (mac);
CREATE INDEX ON src_snmp_mac (switchid);
CREATE INDEX ON src_snmp_mac (port);
CREATE INDEX ON src_snmp_mac (vlan);

CREATE TABLE IF NOT EXISTS src_snmp_dhcp (
  dhcpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  CONSTRAINT routerid_ssnd FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_dhcp (routerid, ip);
CREATE INDEX ON src_snmp_dhcp (ip);
CREATE INDEX ON src_snmp_dhcp (routerid);
CREATE INDEX ON src_snmp_dhcp (mac);

CREATE TABLE IF NOT EXISTS src_snmp_vlan (
  vlanid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  switchid BIGINT NOT NULL,
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  active SMALLINT NOT NULL DEFAULT 1, 
  CONSTRAINT switchid_ssv FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_vlan (switchid, vlan);
CREATE INDEX ON src_snmp_vlan (switchid);
CREATE INDEX ON src_snmp_vlan (vlan);
CREATE INDEX ON src_snmp_vlan (active);

CREATE TABLE IF NOT EXISTS src_snmp_if (
  ifid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  ifindexid INT NOT NULL CHECK (ifindexid>=0), 
  ifindex INT NOT NULL CHECK (ifindex>=0), 
  ifdescr VARCHAR(256) DEFAULT NULL,
  ifname VARCHAR(100) DEFAULT NULL,
  ifalias VARCHAR(256) DEFAULT NULL,
  ifadminstatus SMALLINT NOT NULL DEFAULT 2 CHECK (ifadminstatus>=0), 
  ifoperstatus SMALLINT NOT NULL DEFAULT 4 CHECK (ifoperstatus>=0), 
  ifphysaddress VARCHAR(12) DEFAULT NULL,
  ifphysaddressnum BIGINT DEFAULT NULL CHECK (ifphysaddressnum>=0),
  macvendorid VARCHAR(12) DEFAULT NULL,
  CONSTRAINT ipid_ssi FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_ssi FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE UNIQUE INDEX ON src_snmp_if (ipid, ifindexid);
CREATE INDEX ON src_snmp_if (ipid);
CREATE INDEX ON src_snmp_if (ifindexid);
CREATE INDEX ON src_snmp_if (ifindex);
CREATE INDEX ON src_snmp_if (ifdescr);
CREATE INDEX ON src_snmp_if (ifname);
CREATE INDEX ON src_snmp_if (ifalias);
CREATE INDEX ON src_snmp_if (ifadminstatus);
CREATE INDEX ON src_snmp_if (ifoperstatus);
CREATE INDEX ON src_snmp_if (ifphysaddress);
CREATE INDEX ON src_snmp_if (ifphysaddressnum);
CREATE INDEX ON src_snmp_if (macvendorid);

CREATE TABLE IF NOT EXISTS src_snmp_system (
  ipid BIGINT NOT NULL PRIMARY KEY, 
  sysdescr VARCHAR(256) DEFAULT NULL, 
  sysobjectid VARCHAR(100) DEFAULT NULL, 
  sysuptime BIGINT DEFAULT NULL CHECK (sysuptime>=0), 
  syscontact VARCHAR(256) DEFAULT NULL, 
  sysname VARCHAR(100) DEFAULT NULL, 
  syslocation VARCHAR(256) DEFAULT NULL, 
  sysservices INT DEFAULT NULL CHECK (sysservices>=0), 
  CONSTRAINT ipid_sss FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_snmp_system (sysname);

CREATE TABLE IF NOT EXISTS src_snmp_sysor (
  orid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  
  ipid BIGINT NOT NULL, 
  orindex INT NOT NULL CHECK (orindex>=0), 
  sysorid VARCHAR(100) DEFAULT NULL, 
  sysordescr VARCHAR(1000) DEFAULT NULL, 
  CONSTRAINT ipid_sssr FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_sysor (ipid, orindex);
CREATE INDEX ON src_snmp_sysor (ipid);
CREATE INDEX ON src_snmp_sysor (orindex);

CREATE TABLE IF NOT EXISTS src_snmp_router (
  routerid BIGINT NOT NULL PRIMARY KEY, 
  ipforwarding SMALLINT DEFAULT NULL, 
  ipcidrroutenumber INT DEFAULT NULL CHECK (ipcidrroutenumber>=0), 
  ipaddrnumber INT DEFAULT NULL CHECK (ipaddrnumber>=0), 
  CONSTRAINT ipid_ssr FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_snmp_router (ipforwarding);

CREATE TABLE IF NOT EXISTS src_snmp_ipaddr (
  ipid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  routerid BIGINT NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  ifindex INT DEFAULT NULL CHECK (ifindex>=0), 
  netmask VARCHAR(39) DEFAULT NULL, 
  netnum INT DEFAULT NULL CHECK (netnum>=0), 
  reasmmaxsize INT DEFAULT NULL, 
  CONSTRAINT ipid_ssip FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_ipaddr (routerid, ip);
CREATE INDEX ON src_snmp_ipaddr (routerid);
CREATE INDEX ON src_snmp_ipaddr (ip);
CREATE INDEX ON src_snmp_ipaddr (ifindex);
CREATE INDEX ON src_snmp_ipaddr (netnum);

CREATE TABLE IF NOT EXISTS src_snmp_wlc (
  ipid BIGINT NOT NULL PRIMARY KEY, 
  wlcid INT NOT NULL, 
  wapnum INT DEFAULT NULL CHECK (wapnum>=0), 
  CONSTRAINT ipid_sswl FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT wlcid_sswl FOREIGN KEY (wlcid) REFERENCES ref_wlc_type (wlcid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE INDEX ON src_snmp_wlc (wlcid);

CREATE TABLE IF NOT EXISTS src_snmp_portif_map (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  port INT NOT NULL CHECK (port>=0),
  ifindex INT NOT NULL CHECK (ifindex>=0), 
  CONSTRAINT ipid_sspm FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_portif_map (ipid, port); 
CREATE INDEX ON src_snmp_portif_map (ipid);
CREATE INDEX ON src_snmp_portif_map (port);
CREATE INDEX ON src_snmp_portif_map (ifindex);

CREATE TABLE IF NOT EXISTS src_snmp_wap (
  wapid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  wlcid BIGINT NOT NULL, 
  mac VARCHAR(12) NOT NULL, 
  ip VARCHAR(39) DEFAULT NULL, 
  hostname VARCHAR(100) DEFAULT NULL, 
  CONSTRAINT wlcid_sswp FOREIGN KEY (wlcid) REFERENCES src_snmp_wlc (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_wap (wlcid, mac);
CREATE INDEX ON src_snmp_wap (wlcid);
CREATE INDEX ON src_snmp_wap (mac);
CREATE INDEX ON src_snmp_wap (ip);

CREATE TABLE IF NOT EXISTS src_mist (
  mistid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mac VARCHAR(17) NOT NULL UNIQUE,
  ip VARCHAR(39) DEFAULT NULL,
  ext_ip VARCHAR(39) DEFAULT NULL,
  status VARCHAR(20) DEFAULT NULL,
  type VARCHAR(20) DEFAULT NULL,
  last_seen BIGINT DEFAULT NULL,
  uptime BIGINT DEFAULT NULL,
  name VARCHAR(100) DEFAULT NULL,
  model VARCHAR(20) DEFAULT NULL,
  lldp_stat_chassis_id VARCHAR(17) DEFAULT NULL,
  lldp_stat_system_name VARCHAR(100) DEFAULT NULL,
  lldp_stat_system_desc VARCHAR(256) DEFAULT NULL,
  lldp_stat_port_desc VARCHAR(100) DEFAULT NULL,
  lldp_stat_port_id VARCHAR(50) DEFAULT NULL 
);
CREATE INDEX ON src_mist (ip);
CREATE INDEX ON src_mist (ext_ip); 
CREATE INDEX ON src_mist (status); 
CREATE INDEX ON src_mist (last_seen); 

CREATE TABLE IF NOT EXISTS src_ruckussz_wlc (
  ipid BIGINT NOT NULL PRIMARY KEY, 
  wapnum INT DEFAULT NULL CHECK (wapnum>=0), 
  CONSTRAINT ipid_srwl FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE IF NOT EXISTS src_ruckussz_wap (
  wapid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  wlcid BIGINT NOT NULL, 
  mac VARCHAR(12) NOT NULL, 
  ip VARCHAR(39) DEFAULT NULL,
  externalip VARCHAR(39) DEFAULT NULL,
  name VARCHAR(100) DEFAULT NULL,
  model VARCHAR(20) DEFAULT NULL,
  location VARCHAR(100) DEFAULT NULL,
  administrativestate VARCHAR(20) DEFAULT NULL,
  countrycode VARCHAR(20) DEFAULT NULL,
  configstate VARCHAR(20) DEFAULT NULL,
  connectionstate VARCHAR(20) DEFAULT NULL,
  registrationstate VARCHAR(20) DEFAULT NULL,
  lastseentime BIGINT DEFAULT NULL CHECK (lastseentime>=0),
  approvedtime BIGINT DEFAULT NULL CHECK (approvedtime>=0),
  uptime BIGINT DEFAULT NULL CHECK (uptime>=0),
  clientcount INT DEFAULT NULL CHECK (clientcount>=0),
  CONSTRAINT wlcid_srwp FOREIGN KEY (wlcid) REFERENCES src_ruckussz_wlc (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_ruckussz_wap (wlcid, mac);
CREATE INDEX ON src_ruckussz_wap (wlcid);
CREATE INDEX ON src_ruckussz_wap (mac);
CREATE INDEX ON src_ruckussz_wap (ip);
CREATE INDEX ON src_ruckussz_wap (externalip);
CREATE INDEX ON src_ruckussz_wap (connectionstate);

CREATE TABLE IF NOT EXISTS src_snmp_cdp (
  cdpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  switchid BIGINT NOT NULL, 
  ifindex INT NOT NULL, 
  cdpcacheaddresstype INT DEFAULT NULL, 
  cdpcacheaddress VARCHAR(39) DEFAULT NULL, 
  cdpcacheversion VARCHAR(512) DEFAULT NULL, 
  cdpcachedeviceid VARCHAR(100) DEFAULT NULL, 
  cdpcachedeviceport VARCHAR(50) DEFAULT NULL, 
  cdpcacheplatform VARCHAR(100) DEFAULT NULL, 
  CONSTRAINT ipid_ssc FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_cdp (switchid, ifindex);
CREATE INDEX ON src_snmp_cdp (switchid);
CREATE INDEX ON src_snmp_cdp (ifindex);
CREATE INDEX ON src_snmp_cdp (cdpcacheaddresstype);
CREATE INDEX ON src_snmp_cdp (cdpcacheaddress);
CREATE INDEX ON src_snmp_cdp (cdpcachedeviceid);
CREATE INDEX ON src_snmp_cdp (cdpcachedeviceport);
CREATE INDEX ON src_snmp_cdp (cdpcacheplatform);

CREATE TABLE IF NOT EXISTS src_snmp_lldp (
  lldpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  switchid BIGINT NOT NULL, 
  ifindex INT NOT NULL, 
  lldpremchassisidsubtype INT DEFAULT NULL, 
  lldpremchassisid VARCHAR(50) DEFAULT NULL, 
  lldpremportidsubtype INT DEFAULT NULL, 
  lldpremportid VARCHAR(100) DEFAULT NULL, 
  lldpremportdesc VARCHAR(256) DEFAULT NULL, 
  lldpremsysname VARCHAR(100) DEFAULT NULL, 
  lldpremsysdesc VARCHAR(256) DEFAULT NULL, 
  CONSTRAINT ipid_ssl FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_snmp_lldp (switchid, ifindex);
CREATE INDEX ON src_snmp_lldp (switchid);
CREATE INDEX ON src_snmp_lldp (ifindex);
CREATE INDEX ON src_snmp_lldp (lldpremchassisidsubtype);
CREATE INDEX ON src_snmp_lldp (lldpremportidsubtype);

CREATE TABLE IF NOT EXISTS src_ip (
  ipid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  refid INT NOT NULL CHECK (refid>=0),  
  sourceid INT NOT NULL, 
  mac VARCHAR(12) DEFAULT NULL, 
  ispublic SMALLINT NOT NULL DEFAULT 0, 
  parent_ipid BIGINT DEFAULT NULL, 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  macnum BIGINT DEFAULT NULL CHECK (macnum>=0), 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  CONSTRAINT sourceid_si FOREIGN KEY (sourceid) REFERENCES ref_ipaddress_source (sourceid) ON DELETE CASCADE ON UPDATE CASCADE,   
  CONSTRAINT parent_ipid_si FOREIGN KEY (parent_ipid) REFERENCES src_ip (ipid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_si FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_si FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_si FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT vlanid_si FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_si FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE INDEX ON src_ip (refid);
CREATE INDEX ON src_ip (sourceid);
CREATE INDEX ON src_ip (mac);
CREATE INDEX ON src_ip (ispublic);
CREATE INDEX ON src_ip (parent_ipid);
CREATE INDEX ON src_ip (siteid);
CREATE INDEX ON src_ip (ipprefixid);
CREATE INDEX ON src_ip (roleid);
CREATE INDEX ON src_ip (vlanid);
CREATE INDEX ON src_ip (vlan);
CREATE INDEX ON src_ip (ipnum);
CREATE INDEX ON src_ip (macnum);
CREATE INDEX ON src_ip (macvendorid);

CREATE TABLE IF NOT EXISTS src_arp_device (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  device VARCHAR(39) NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  ifindex INT DEFAULT NULL CHECK (ifindex>=0), 
  ispublic SMALLINT DEFAULT 1, 
  CONSTRAINT vlanid_sar FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sar FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sar FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sar FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_arp_device (device,ip);
CREATE INDEX ON src_arp_device (device);
CREATE INDEX ON src_arp_device (ip);
CREATE INDEX ON src_arp_device (ipnum);
CREATE INDEX ON src_arp_device (mac);
CREATE INDEX ON src_arp_device (vlanid);
CREATE INDEX ON src_arp_device (vlan);
CREATE INDEX ON src_arp_device (roleid); 
CREATE INDEX ON src_arp_device (siteid);
CREATE INDEX ON src_arp_device (ipprefixid);
CREATE INDEX ON src_arp_device (ifindex);
CREATE INDEX ON src_arp_device (ispublic);

CREATE TABLE IF NOT EXISTS src_arp_site (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  ispublic SMALLINT DEFAULT 1, 
  CONSTRAINT vlanid_sas FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sas FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sas FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sas FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_arp_site (ip, siteid);
CREATE INDEX ON src_arp_site (ip);
CREATE INDEX ON src_arp_site (ipnum);
CREATE INDEX ON src_arp_site (mac);
CREATE INDEX ON src_arp_site (vlanid);
CREATE INDEX ON src_arp_site (vlan);
CREATE INDEX ON src_arp_site (roleid);
CREATE INDEX ON src_arp_site (ipprefixid);
CREATE INDEX ON src_arp_site (siteid);
CREATE INDEX ON src_arp_site (ispublic);

CREATE TABLE IF NOT EXISTS src_arp (
  arpid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  ipnum BIGINT NOT NULL CHECK (ipnum>=0), 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  ipprefixid INT DEFAULT NULL CHECK (ipprefixid>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  ispublic SMALLINT DEFAULT 1, 
  CONSTRAINT vlanid_sa FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sa FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sa FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sa FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE INDEX ON src_arp (ipnum);
CREATE INDEX ON src_arp (mac);
CREATE INDEX ON src_arp (vlanid);
CREATE INDEX ON src_arp (vlan);
CREATE INDEX ON src_arp (ipprefixid);
CREATE INDEX ON src_arp (siteid);
CREATE INDEX ON src_arp (roleid);
CREATE INDEX ON src_arp (ispublic);

CREATE TABLE IF NOT EXISTS src_vlan_device (
  vlid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  active SMALLINT NOT NULL DEFAULT 1, 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  CONSTRAINT vlanid_svd FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_svd FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_svd FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_vlan_device (device, vlan);
CREATE INDEX ON src_vlan_device (device);
CREATE INDEX ON src_vlan_device (vlan);
CREATE INDEX ON src_vlan_device (active); 
CREATE INDEX ON src_vlan_device (siteid); 
CREATE INDEX ON src_vlan_device (vlanid); 
CREATE INDEX ON src_vlan_device (roleid);

CREATE TABLE IF NOT EXISTS src_if (
  ifid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  device VARCHAR(39) NOT NULL, 
  ifindex INT NOT NULL CHECK (ifindex>=0), 
  ifdescr VARCHAR(256) DEFAULT NULL,
  ifname VARCHAR(100) DEFAULT NULL,
  ifalias VARCHAR(256) DEFAULT NULL,
  ifadminstatus SMALLINT NOT NULL DEFAULT 2 CHECK (ifadminstatus>=0), 
  ifoperstatus SMALLINT NOT NULL DEFAULT 4 CHECK (ifoperstatus>=0), 
  ip VARCHAR(39) DEFAULT NULL, 
  netmask VARCHAR(39) DEFAULT NULL, 
  netnum INT DEFAULT NULL CHECK (netnum>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  connectedto BIGINT DEFAULT NULL, 
  macs INT NOT NULL DEFAULT 0 CHECK (macs>=0),
  ifphysaddress VARCHAR(12) DEFAULT NULL, 
  ifphysaddressnum BIGINT DEFAULT NULL CHECK (ifphysaddressnum>=0), 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  CONSTRAINT vlanid_sif FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sif FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sif FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT connectedto_sif FOREIGN KEY (connectedto) REFERENCES src_if (ifid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_sif FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_if (device, ifindex);
CREATE INDEX ON src_if (device);
CREATE INDEX ON src_if (ifindex);
CREATE INDEX ON src_if (ifdescr);
CREATE INDEX ON src_if (ifname);
CREATE INDEX ON src_if (ifalias);
CREATE INDEX ON src_if (ifadminstatus);
CREATE INDEX ON src_if (ifoperstatus);
CREATE INDEX ON src_if (ip);
CREATE INDEX ON src_if (netnum);
CREATE INDEX ON src_if (siteid);
CREATE INDEX ON src_if (vlanid);
CREATE INDEX ON src_if (vlan);
CREATE INDEX ON src_if (roleid);
CREATE INDEX ON src_if (macs);
CREATE INDEX ON src_if (connectedto);
CREATE INDEX ON src_if (ifphysaddress);
CREATE INDEX ON src_if (ifphysaddressnum);
CREATE INDEX ON src_if (macvendorid);

CREATE TABLE IF NOT EXISTS src_mac_device (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT NOT NULL CHECK (macnum>=0), 
  port INT NOT NULL CHECK (port>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vendorid VARCHAR(12) DEFAULT NULL,
  CONSTRAINT vlanid_smd FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_smd FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_smd FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT macid_smd FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_mac_device (device, mac, vlan);
CREATE INDEX ON src_mac_device (device, mac);
CREATE INDEX ON src_mac_device (mac);
CREATE INDEX ON src_mac_device (macnum);
CREATE INDEX ON src_mac_device (device);
CREATE INDEX ON src_mac_device (port);
CREATE INDEX ON src_mac_device (vlan);
CREATE INDEX ON src_mac_device (siteid);
CREATE INDEX ON src_mac_device (vlanid);
CREATE INDEX ON src_mac_device (roleid);
CREATE INDEX ON src_mac_device (vendorid);

CREATE TABLE IF NOT EXISTS src_vlan_site (
  vlid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  CONSTRAINT roleid_svs FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_svs FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_vlan_site (siteid, vlan);
CREATE INDEX ON src_vlan_site (vlan);
CREATE INDEX ON src_vlan_site (siteid);
CREATE INDEX ON src_vlan_site (roleid);

CREATE TABLE IF NOT EXISTS src_vlan (
  vlid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  vlan INT NOT NULL UNIQUE CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  CONSTRAINT roleid_sv FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE INDEX ON src_vlan (roleid);

CREATE TABLE IF NOT EXISTS src_mac_site (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT NOT NULL CHECK (macnum>=0), 
  port INT NOT NULL CHECK (port>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlanid INT DEFAULT NULL CHECK (vlanid>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vendorid VARCHAR(12) DEFAULT NULL,
  CONSTRAINT vlanid_sms FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sms FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sms FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT macid_sms FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_mac_site (siteid, mac, vlan);
CREATE INDEX ON src_mac_site (siteid, mac);
CREATE INDEX ON src_mac_site (mac);
CREATE INDEX ON src_mac_site (macnum);
CREATE INDEX ON src_mac_site (device);
CREATE INDEX ON src_mac_site (port);
CREATE INDEX ON src_mac_site (vlan);
CREATE INDEX ON src_mac_site (siteid);
CREATE INDEX ON src_mac_site (vlanid);
CREATE INDEX ON src_mac_site (roleid);
CREATE INDEX ON src_mac_site (vendorid);

CREATE TABLE IF NOT EXISTS src_mac (
  macid BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT NOT NULL CHECK (macnum>=0), 
  port INT NOT NULL CHECK (port>=0), 
  siteid INT NOT NULL DEFAULT 0 CHECK (siteid>=0), 
  vlan INT NOT NULL DEFAULT 0 CHECK (vlan>=0), 
  roleid INT DEFAULT NULL CHECK (roleid>=0), 
  vendorid VARCHAR(12) DEFAULT NULL,
  CONSTRAINT roleid_sm FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macid_sm FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sm FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
);
CREATE UNIQUE INDEX ON src_mac (mac, vlan);
CREATE INDEX ON src_mac (mac);
CREATE INDEX ON src_mac (macnum); 
CREATE INDEX ON src_mac (device);
CREATE INDEX ON src_mac (port);
CREATE INDEX ON src_mac (vlan);
CREATE INDEX ON src_mac (siteid); 
CREATE INDEX ON src_mac (roleid);
CREATE INDEX ON src_mac (vendorid);

CREATE TABLE IF NOT EXISTS src_ip_info (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  ipid BIGINT NOT NULL,
  infoid INT NOT NULL CHECK (infoid>=0),
  value VARCHAR(256) NOT NULL, 
  CONSTRAINT ipid_sii FOREIGN KEY (ipid) REFERENCES src_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT infoid_sii FOREIGN KEY (infoid) REFERENCES ref_scan_ip_info (infoid) ON DELETE CASCADE ON UPDATE CASCADE   
);
CREATE UNIQUE INDEX ON src_ip_info (ipid, infoid);
CREATE INDEX ON src_ip_info (ipid);
CREATE INDEX ON src_ip_info (infoid);
