TABLE IF NOT EXISTS src_enplug_venue (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  venueid VARCHAR(256) NOT NULL UNIQUE,
  venuename VARCHAR(256) NOT NULL,
  venue_timezone VARCHAR(100) NOT NULL, 
  KEY venuename (venuename)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_enplug_edu (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
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
  last_player_heartbeat DATETIME DEFAULT NULL, 
  KEY venueid (venueid), 
  KEY eduname (eduname), 
  KEY mac_eth (mac_eth), 
  KEY mac_wifi (mac_wifi), 
  KEY ip (ip), 
  KEY ip_public (ip_public), 
  KEY status_code (status_code), 
  CONSTRAINT venueid_see FOREIGN KEY (venueid) REFERENCES src_enplug_venue (venueid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_activaire (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  activaireid VARCHAR(256) NOT NULL UNIQUE, 
  activairename VARCHAR(256) NOT NULL, 
  mac VARCHAR(12) DEFAULT NULL,
  mac_eth VARCHAR(12) DEFAULT NULL, 
  lastonline DATETIME DEFAULT NULL, 
  isplaying BOOLEAN DEFAULT NULL,
  device_status VARCHAR(20) NOT NULL,
  ip VARCHAR(39) DEFAULT NULL, 
  ip_public VARCHAR(39) DEFAULT NULL, 
  make_model VARCHAR(256) DEFAULT NULL,   
  app_version VARCHAR(20) DEFAULT NULL, 
  KEY activairename (activairename), 
  KEY mac (mac), 
  KEY mac_eth (mac_eth), 
  KEY device_status (device_status), 
  KEY ip (ip), 
  KEY ip_public (ip_public) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_ip (
  ipid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  refid INT UNSIGNED NOT NULL, 
  sourceid INT UNSIGNED NOT NULL, 
  ispublic BOOLEAN NOT NULL DEFAULT FALSE, 
  KEY refid (refid), 
  KEY sourceid (sourceid), 
  KEY ispublic (ispublic), 
  CONSTRAINT sourceid_ssi FOREIGN KEY (sourceid) REFERENCES ref_ipaddress_source (sourceid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_arp (
  arpid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  UNIQUE KEY routerip (routerid, ip), 
  KEY ip (ip),
  KEY routerid (routerid),
  KEY mac (mac), 
  CONSTRAINT routerid_ssa FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_dhcp (
  dhcpid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  UNIQUE KEY routerip (routerid, ip), 
  KEY ip (ip),
  KEY routerid (routerid),
  KEY mac (mac), 
  CONSTRAINT routerid_ssd FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_ip_info (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  ipid BIGINT NOT NULL,
  infoid INT UNSIGNED NOT NULL,
  value VARCHAR(256) NOT NULL, 
  UNIQUE KEY ipinfo (ipid, infoid), 
  KEY `ipid` (`ipid`),
  KEY `infoid` (`infoid`), 
  CONSTRAINT ipid_ssii FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT infoid_ssii FOREIGN KEY (infoid) REFERENCES ref_scan_ip_info (infoid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_port (
  portid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  ipid BIGINT NOT NULL,
  type VARCHAR(20) NOT NULL, 
  port INT UNSIGNED NOT NULL,
  state VARCHAR(20) NOT NULL, 
  reason VARCHAR(20) NOT NULL, 
  UNIQUE KEY iptypeport (ipid, type, port), 
  KEY ipid (ipid), 
  KEY type (type), 
  KEY port (port), 
  KEY state (state), 
  CONSTRAINT ipid_ssp FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_osmatch (
  osmatchid INT NOT NULL PRIMARY KEY, 
  ipid BIGINT NOT NULL, 
  name VARCHAR(256) NOT NULL,
  accuracy INT UNSIGNED NOT NULL,
  KEY ipid (ipid), 
  KEY name (name), 
  KEY accuracy (accuracy), 
  CONSTRAINT ipid_sso FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_osclass (
  osclassid INT NOT NULL PRIMARY KEY, 
  osmatchid INT NOT NULL, 
  type VARCHAR(256) DEFAULT NULL, 
  vendor VARCHAR(256) DEFAULT NULL, 
  osfamily VARCHAR(256) DEFAULT NULL, 
  osgen VARCHAR(256) DEFAULT NULL, 
  accuracy INT UNSIGNED NOT NULL,
  cpe VARCHAR(256) DEFAULT NULL, 
  KEY osmatchid (osmatchid), 
  CONSTRAINT osmatchid_sso FOREIGN KEY (osmatchid) REFERENCES src_scan_osmatch (osmatchid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_service (
  portid BIGINT NOT NULL PRIMARY KEY, 
  product VARCHAR(100) DEFAULT NULL, 
  version VARCHAR(50) DEFAULT NULL, 
  extrainfo VARCHAR(256) DEFAULT NULL, 
  conf INT DEFAULT NULL, 
  cpe VARCHAR(100) DEFAULT NULL, 
  name VARCHAR(50) DEFAULT NULL, 
  KEY product (product), 
  KEY cpe (cpe), 
  CONSTRAINT portid_ssse FOREIGN KEY (portid) REFERENCES src_scan_port (portid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_scan_script (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  portid BIGINT NOT NULL, 
  script VARCHAR(100) NOT NULL, 
  value VARCHAR(16100) NOT NULL, 
  UNIQUE KEY portscript (portid, script), 
  KEY portid (portid), 
  KEY script (script), 
  CONSTRAINT portid_sssc FOREIGN KEY (portid) REFERENCES src_scan_port (portid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp (
  snmpid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid BIGINT NOT NULL, 
  oidid INT DEFAULT NULL, 
  oid VARCHAR(256) NOT NULL,
  snmp_type VARCHAR(20) NOT NULL,
  value VARCHAR(1000) NOT NULL, 
  value_hex VARCHAR(2000) NOT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  UNIQUE KEY ipoid (ipid, oid), 
  KEY ipid (ipid),
  KEY oidid (oidid),
  KEY oid (oid),
  KEY snmp_type (snmp_type), 
  KEY vlan (vlan), 
  CONSTRAINT ipid_ss FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT oidid_ss FOREIGN KEY (oidid) REFERENCES ref_scan_snmp_oid (oidid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_arp (
  arpid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  UNIQUE KEY routerip (routerid, ip), 
  KEY ip (ip),
  KEY routerid (routerid),
  KEY mac (mac), 
  CONSTRAINT routerid_ssna FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_mac (
  macid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  mac VARCHAR(12) NOT NULL,
  switchid BIGINT NOT NULL,
  port INT UNSIGNED NOT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  UNIQUE KEY switchmacvlan (switchid, mac, vlan), 
  KEY mac (mac), 
  KEY switchid (switchid),
  KEY port (port),
  KEY vlan (vlan),
  CONSTRAINT switchid_ssm FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_dhcp (
  dhcpid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  ip VARCHAR(39) NOT NULL,
  routerid BIGINT NOT NULL,
  mac VARCHAR(12) NOT NULL,
  UNIQUE KEY routerip (routerid, ip), 
  KEY ip (ip),
  KEY routerid (routerid),
  KEY mac (mac), 
  CONSTRAINT routerid_ssnd FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_vlan (
  vlanid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  switchid BIGINT NOT NULL,
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  active BOOLEAN NOT NULL DEFAULT TRUE, 
  UNIQUE KEY switchvlan (switchid, vlan), 
  KEY switchid (switchid),
  KEY vlan (vlan), 
  KEY active (active), 
  CONSTRAINT switchid_ssv FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_if (
  ifid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid BIGINT NOT NULL, 
  ifindexid INT UNSIGNED NOT NULL, 
  ifindex INT UNSIGNED NOT NULL, 
  ifdescr VARCHAR(256) DEFAULT NULL,
  ifname VARCHAR(100) DEFAULT NULL,
  ifalias VARCHAR(256) DEFAULT NULL,
  ifadminstatus SMALLINT UNSIGNED NOT NULL DEFAULT 2, 
  ifoperstatus SMALLINT UNSIGNED NOT NULL DEFAULT 4, 
  ifphysaddress VARCHAR(12) DEFAULT NULL,
  ifphysaddressnum BIGINT UNSIGNED DEFAULT NULL,
  macvendorid VARCHAR(12) DEFAULT NULL,
  UNIQUE KEY ipifindexid (ipid, ifindexid), 
  KEY ipid (ipid),
  KEY ifindexid (ifindexid),
  KEY ifindex (ifindex),
  KEY ifdescr (ifdescr), 
  KEY ifname (ifname), 
  KEY ifalias (ifalias), 
  KEY ifadminstatus (ifadminstatus), 
  KEY ifoperstatus (ifoperstatus), 
  KEY ifphysaddress (ifphysaddress),
  KEY ifphysaddressnum (ifphysaddressnum),
  KEY macvendorid (macvendorid),
  CONSTRAINT ipid_ssi FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_ssi FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_system (
  ipid BIGINT NOT NULL PRIMARY KEY, 
  sysdescr VARCHAR(256) DEFAULT NULL, 
  sysobjectid VARCHAR(100) DEFAULT NULL, 
  sysuptime BIGINT UNSIGNED DEFAULT NULL, 
  syscontact VARCHAR(100) DEFAULT NULL, 
  sysname VARCHAR(100) DEFAULT NULL, 
  syslocation VARCHAR(256) DEFAULT NULL, 
  sysservices INT UNSIGNED DEFAULT NULL, 
  KEY sysname (sysname),
  CONSTRAINT ipid_sss FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_sysor (
  orid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,  
  ipid BIGINT NOT NULL, 
  orindex INT UNSIGNED NOT NULL, 
  sysorid VARCHAR(100) DEFAULT NULL, 
  sysordescr VARCHAR(1000) DEFAULT NULL, 
  UNIQUE KEY ipindex (ipid, orindex),
  KEY ipid (ipid), 
  KEY orindex (orindex), 
  CONSTRAINT ipid_sssr FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_router (
  routerid BIGINT NOT NULL PRIMARY KEY, 
  ipforwarding BOOLEAN DEFAULT NULL, 
  ipcidrroutenumber INT UNSIGNED DEFAULT NULL, 
  ipaddrnumber INT UNSIGNED DEFAULT NULL, 
  KEY ipforwarding (ipforwarding),
  CONSTRAINT ipid_ssr FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_ipaddr (
  ipid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  routerid BIGINT NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  ifindex INT UNSIGNED DEFAULT NULL, 
  netmask VARCHAR(39) DEFAULT NULL, 
  netnum INT UNSIGNED DEFAULT NULL, 
  reasmmaxsize INT DEFAULT NULL, 
  UNIQUE KEY routerip (routerid, ip),
  KEY routerid (routerid),
  KEY ip (ip),
  KEY ifindex (ifindex),
  KEY netnum (netnum),
  CONSTRAINT ipid_ssip FOREIGN KEY (routerid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_wlc (
  ipid BIGINT NOT NULL PRIMARY KEY, 
  wlcid INT NOT NULL, 
  wapnum INT UNSIGNED DEFAULT NULL, 
  KEY wlcid (wlcid),
  CONSTRAINT ipid_sswl FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT wlcid_sswl FOREIGN KEY (wlcid) REFERENCES ref_wlc_type (wlcid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_wap (
  wapid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  wlcid BIGINT NOT NULL, 
  mac VARCHAR(12) NOT NULL, 
  ip VARCHAR(39) DEFAULT NULL, 
  hostname VARCHAR(100) DEFAULT NULL, 
  UNIQUE KEY wlcmac (wlcid, mac),
  KEY wlcid (wlcid), 
  KEY mac (mac), 
  KEY ip (ip), 
  CONSTRAINT wlcid_sswp FOREIGN KEY (wlcid) REFERENCES src_snmp_wlc (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_mist (
  mistid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  mac VARCHAR(12) NOT NULL UNIQUE,
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
  lldp_stat_port_id VARCHAR(50) DEFAULT NULL,
  KEY ip (ip),
  KEY ext_ip (ext_ip),
  KEY status (status),
  KEY last_seen (last_seen)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_ruckussz_wlc (
  ipid BIGINT NOT NULL PRIMARY KEY, 
  wapnum INT UNSIGNED DEFAULT NULL, 
  CONSTRAINT ipid_srwl FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_ruckussz_wap (
  wapid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
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
  lastseentime BIGINT UNSIGNED DEFAULT NULL,
  approvedtime BIGINT UNSIGNED DEFAULT NULL,
  uptime BIGINT UNSIGNED DEFAULT NULL,
  clientcount INT UNSIGNED DEFAULT NULL,
  UNIQUE KEY wlcmac (wlcid, mac),
  KEY wlcid (wlcid), 
  KEY mac (mac), 
  KEY ip (ip), 
  KEY externalip (externalip), 
  KEY connectionstate (connectionstate), 
  CONSTRAINT wlcid_srwp FOREIGN KEY (wlcid) REFERENCES src_ruckussz_wlc (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_cdp (
  cdpid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  switchid BIGINT NOT NULL, 
  ifindex INT NOT NULL, 
  cdpcacheaddresstype INT DEFAULT NULL, 
  cdpcacheaddress VARCHAR(39) DEFAULT NULL, 
  cdpcacheversion VARCHAR(512) DEFAULT NULL, 
  cdpcachedeviceid VARCHAR(100) DEFAULT NULL, 
  cdpcachedeviceport VARCHAR(50) DEFAULT NULL, 
  cdpcacheplatform VARCHAR(100) DEFAULT NULL, 
  UNIQUE KEY swif (switchid, ifindex),
  KEY switchid (switchid), 
  KEY ifindex (ifindex),
  KEY cdpcacheaddresstype (cdpcacheaddresstype),
  KEY cdpcacheaddress (cdpcacheaddress),
  KEY cdpcachedeviceid (cdpcachedeviceid),
  KEY cdpcachedeviceport (cdpcachedeviceport),
  KEY cdpcacheplatform (cdpcacheplatform),
  CONSTRAINT ipid_ssc FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_lldp (
  lldpid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  switchid BIGINT NOT NULL, 
  ifindex INT NOT NULL, 
  lldpremchassisidsubtype INT DEFAULT NULL, 
  lldpremchassisid VARCHAR(50) DEFAULT NULL, 
  lldpremportidsubtype INT DEFAULT NULL, 
  lldpremportid VARCHAR(100) DEFAULT NULL, 
  lldpremportdesc VARCHAR(256) DEFAULT NULL, 
  lldpremsysname VARCHAR(100) DEFAULT NULL, 
  lldpremsysdesc VARCHAR(256) DEFAULT NULL, 
  UNIQUE KEY switchif (switchid, ifindex), 
  KEY switchid (switchid), 
  KEY ifindex (ifindex), 
  KEY lldpremchassisidsubtype (lldpremchassisidsubtype), 
  KEY lldpremportidsubtype (lldpremportidsubtype), 
  CONSTRAINT ipid_ssl FOREIGN KEY (switchid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_snmp_portif_map (
  id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ipid BIGINT NOT NULL, 
  port INT UNSIGNED NOT NULL,
  ifindex INT UNSIGNED NOT NULL, 
  UNIQUE KEY ipport (ipid, port), 
  KEY ipid (ipid),
  KEY port (port),
  KEY ifindex (ifindex),
  CONSTRAINT ipid_sspm FOREIGN KEY (ipid) REFERENCES src_scan_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_ip (
  ipid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  refid INT UNSIGNED NOT NULL, 
  sourceid INT UNSIGNED NOT NULL, 
  mac VARCHAR(12) DEFAULT NULL, 
  ispublic BOOLEAN NOT NULL DEFAULT FALSE, 
  parent_ipid BIGINT DEFAULT NULL, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  ipprefixid INT UNSIGNED DEFAULT NULL, 
  roleid INT UNSIGNED DEFAULT NULL, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  ipnum BIGINT UNSIGNED NOT NULL, 
  macnum BIGINT UNSIGNED DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  KEY refid (refid), 
  KEY sourceid (sourceid), 
  KEY mac (mac), 
  KEY ispublic (ispublic), 
  KEY parent_ipid (parent_ipid), 
  KEY siteid (siteid), 
  KEY ipprefixid (ipprefixid), 
  KEY roleid (roleid), 
  KEY vlanid (vlanid), 
  KEY vlan (vlan), 
  KEY ipnum (ipnum), 
  KEY macnum (macnum), 
  KEY macvendorid (macvendorid), 
  CONSTRAINT sourceid_si FOREIGN KEY (sourceid) REFERENCES ref_ipaddress_source (sourceid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT parent_ipid_si FOREIGN KEY (parent_ipid) REFERENCES src_ip (ipid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_si FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_si FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_si FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT vlanid_si FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_si FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_arp_device (
  arpid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  device VARCHAR(39) NOT NULL, 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT UNSIGNED NOT NULL, 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  ipprefixid INT UNSIGNED DEFAULT NULL, 
  ifindex INT UNSIGNED DEFAULT NULL, 
  ispublic BOOLEAN DEFAULT TRUE, 
  UNIQUE KEY deviceip (device, ip), 
  KEY device (device), 
  KEY ip (ip), 
  KEY ipnum (ipnum), 
  KEY mac (mac), 
  KEY vlanid (vlanid), 
  KEY vlan (vlan), 
  KEY roleid (roleid), 
  KEY siteid (siteid), 
  KEY ipprefixid (ipprefixid), 
  KEY ifindex (ifindex), 
  KEY ispublic (ispublic), 
  CONSTRAINT vlanid_sar FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sar FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sar FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sar FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_arp_site (
  arpid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  ip VARCHAR(39) NOT NULL, 
  ipnum BIGINT UNSIGNED NOT NULL, 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  ipprefixid INT UNSIGNED DEFAULT NULL, 
  ispublic BOOLEAN DEFAULT TRUE, 
  UNIQUE KEY ipsite (ip, siteid), 
  KEY ip (ip), 
  KEY ipnum (ipnum), 
  KEY mac (mac), 
  KEY vlanid (vlanid), 
  KEY vlan (vlan), 
  KEY roleid (roleid), 
  KEY ipprefixid (ipprefixid), 
  KEY siteid (siteid), 
  KEY ispublic (ispublic), 
  CONSTRAINT vlanid_sas FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sas FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sas FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sas FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_arp (
  arpid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  ip VARCHAR(39) NOT NULL UNIQUE, 
  ipnum BIGINT UNSIGNED NOT NULL, 
  mac VARCHAR(12) NOT NULL, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  ipprefixid INT UNSIGNED DEFAULT NULL, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  ispublic BOOLEAN DEFAULT TRUE, 
  KEY ipnum (ipnum), 
  KEY mac (mac), 
  KEY vlanid (vlanid), 
  KEY vlan (vlan), 
  KEY ipprefixid (ipprefixid), 
  KEY siteid (siteid), 
  KEY roleid (roleid), 
  KEY ispublic (ispublic), 
  CONSTRAINT vlanid_sa FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sa FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT ipprefixid_sa FOREIGN KEY (ipprefixid) REFERENCES ref_ipprefix (ipprefixid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sa FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_vlan_device (
  vlid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  active BOOLEAN NOT NULL DEFAULT TRUE, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  roleid INT UNSIGNED DEFAULT NULL, 
  UNIQUE KEY devicevlan (device, vlan), 
  KEY device (device),
  KEY vlan (vlan), 
  KEY active (active), 
  KEY siteid (siteid), 
  KEY vlanid (vlanid), 
  KEY roleid (roleid), 
  CONSTRAINT vlanid_svd FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_svd FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_svd FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_if (
  ifid BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
  device VARCHAR(39) NOT NULL, 
  ifindex INT UNSIGNED NOT NULL, 
  ifdescr VARCHAR(256) DEFAULT NULL,
  ifname VARCHAR(100) DEFAULT NULL,
  ifalias VARCHAR(256) DEFAULT NULL,
  ifadminstatus SMALLINT UNSIGNED NOT NULL DEFAULT 2, 
  ifoperstatus SMALLINT UNSIGNED NOT NULL DEFAULT 4, 
  ip VARCHAR(39) DEFAULT NULL, 
  netmask VARCHAR(39) DEFAULT NULL, 
  netnum INT UNSIGNED DEFAULT NULL, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  connectedto BIGINT DEFAULT NULL
  macs INT UNSIGNED NOT NULL DEFAULT 0,
  ifphysaddress VARCHAR(12) DEFAULT NULL, 
  ifphysaddressnum BIGINT UNSIGNED DEFAULT NULL, 
  macvendorid VARCHAR(12) DEFAULT NULL, 
  UNIQUE KEY deviceifindex (device, ifindex), 
  KEY device (device),
  KEY ifindex (ifindex),
  KEY ifdescr (ifdescr), 
  KEY ifname (ifname), 
  KEY ifalias (ifalias), 
  KEY ifadminstatus (ifadminstatus), 
  KEY ifoperstatus (ifoperstatus), 
  KEY ip (ip), 
  KEY netnum (netnum), 
  KEY siteid (siteid), 
  KEY vlanid (vlanid), 
  KEY vlan (vlan), 
  KEY roleid (roleid), 
  KEY macs (macs), 
  KEY connectedto (connectedto), 
  KEY ifphysaddress (ifphysaddress), 
  KEY ifphysaddressnum (ifphysaddressnum), 
  KEY macvendorid (macvendorid), 
  CONSTRAINT vlanid_sif FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sif FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sif FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT connectedto_sif FOREIGN KEY (connectedto) REFERENCES src_if (ifid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macvendorid_sif FOREIGN KEY (macvendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_mac_device (
  macid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT UNSIGNED NOT NULL, 
  port INT UNSIGNED NOT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  roleid INT UNSIGNED DEFAULT NULL, 
  vendorid VARCHAR(12) DEFAULT NULL,
  UNIQUE KEY devicemacvlan (device, mac, vlan), 
  KEY devicemac (device, mac),
  KEY mac (mac), 
  KEY macnum (macnum), 
  KEY device (device),
  KEY port (port),
  KEY vlan (vlan),
  KEY siteid (siteid), 
  KEY vlanid (vlanid), 
  KEY roleid (roleid), 
  KEY vendorid (vendorid), 
  CONSTRAINT vlanid_smd FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_smd FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_smd FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT macid_smd FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_vlan_site (
  vlid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  UNIQUE KEY devicevlan (siteid, vlan), 
  KEY vlan (vlan), 
  KEY siteid (siteid), 
  KEY roleid (roleid), 
  CONSTRAINT roleid_svs FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_svs FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_vlan (
  vlid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vlan INT UNSIGNED NOT NULL UNIQUE, 
  roleid INT UNSIGNED DEFAULT NULL, 
  KEY roleid (roleid), 
  CONSTRAINT roleid_sv FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_mac_site (
  macid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT UNSIGNED NOT NULL, 
  port INT UNSIGNED NOT NULL, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  vlanid INT UNSIGNED DEFAULT NULL, 
  roleid INT UNSIGNED DEFAULT NULL, 
  vendorid VARCHAR(12) DEFAULT NULL,
  UNIQUE KEY sitemacvlan (siteid, mac, vlan), 
  KEY sitemac (siteid, mac),
  KEY mac (mac), 
  KEY macnum (macnum), 
  KEY device (device),
  KEY port (port),
  KEY vlan (vlan),
  KEY siteid (siteid), 
  KEY vlanid (vlanid), 
  KEY roleid (roleid), 
  KEY vendorid (vendorid), 
  CONSTRAINT vlanid_sms FOREIGN KEY (vlanid) REFERENCES ref_vlan (vlanid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT roleid_sms FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sms FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
  CONSTRAINT macid_sms FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_mac (
  macid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  device VARCHAR(39) NOT NULL, 
  mac VARCHAR(12) NOT NULL,
  macnum BIGINT UNSIGNED NOT NULL, 
  port INT UNSIGNED NOT NULL, 
  siteid INT UNSIGNED NOT NULL DEFAULT 0, 
  vlan INT UNSIGNED NOT NULL DEFAULT 0, 
  roleid INT UNSIGNED DEFAULT NULL, 
  vendorid VARCHAR(12) DEFAULT NULL,
  UNIQUE KEY macvlan (mac, vlan), 
  KEY mac (mac), 
  KEY macnum (macnum), 
  KEY device (device),
  KEY port (port),
  KEY vlan (vlan),
  KEY siteid (siteid), 
  KEY roleid (roleid), 
  KEY vendorid (vendorid), 
  CONSTRAINT roleid_sm FOREIGN KEY (roleid) REFERENCES ref_subnet_role (subnet_roleid) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT macid_sm FOREIGN KEY (vendorid) REFERENCES info_mac (assignment) ON DELETE SET NULL ON UPDATE CASCADE, 
  CONSTRAINT siteid_sm FOREIGN KEY (siteid) REFERENCES ref_site (siteid) ON DELETE SET DEFAULT ON UPDATE CASCADE 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS src_ip_info (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  ipid BIGINT NOT NULL,
  infoid INT UNSIGNED NOT NULL,
  value VARCHAR(256) NOT NULL, 
  UNIQUE KEY ipinfo (ipid, infoid), 
  KEY `ipid` (`ipid`),
  KEY `infoid` (`infoid`), 
  CONSTRAINT ipid_sii FOREIGN KEY (ipid) REFERENCES src_ip (ipid) ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT infoid_sii FOREIGN KEY (infoid) REFERENCES ref_scan_ip_info (infoid) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB;

