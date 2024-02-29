import logging

#programs
log_path = '/var/log/omnissiah'
#log_level = logging.ERROR
log_level = logging.INFO
#log_level = logging.DEBUG
log_format = '%(asctime)s:%(levelname)s:%(name)s:%(message)s'
log_date_format = '%Y%m%d:%H%M%S'
lib_path = '/var/lib/omnissiah'

#database
dbtype = 'mariadb'
#dbtype = 'pgsql'
dbhost = '127.0.0.1'
dbname = 'omnissiah'
dbssl = True

#netbox
netbox_url = 'http://127.0.0.1:8001/'

#scan
scan_subnet_ipprefix_filter = "AND ref_ipprefix.netnum>=22 AND (ref_subnet_role.subnet_role_alias IS NULL OR ref_subnet_role.subnet_role_alias NOT IN ('wireless_client', 'wire_client', 'user')) AND \
(ref_ipprefix.vlanid IS NULL OR ref_vlan.description IS NULL OR (LOWER(ref_vlan.description) NOT LIKE '%guest%' AND LOWER(ref_vlan.description) NOT LIKE '%member%' AND LOWER(ref_vlan.description) NOT LIKE '%client%' ))"
scan_subnet_iprange_filter = "AND ref_iprange.netnum>=22 AND (ref_subnet_role.subnet_role_alias IS NULL OR ref_subnet_role.subnet_role_alias NOT IN ('wireless_client', 'wire_client', 'user'))"
scan_processes_num = None
scan_rangeip_scope_size = 256
nmap_scan_list = [{'threadsnum':70, 'arguments':'-n -T4 --host-timeout 60s -PE --disable-arp-ping -sn', 'timeout':240, 'info':None},
{'threadsnum':70, 'arguments':'-n -T4 --host-timeout 600s -PS80,443,8080,8443,21,22,23,53,5060 --disable-arp-ping -sn', 'timeout':1800, 'info':None},
{'threadsnum':70, 'arguments':'-n -T4 --host-timeout 300s -PU53,5060,5353 --disable-arp-ping -sn', 'timeout':1320, 'info':None},
{'threadsnum':50, 'arguments':'-n -T4 --host-timeout 180s -PE -PU -sU -p161 --disable-arp-ping --script snmp-brute --script-args \
brute.firstonly=true,snmp-brute.communitiesdb=/usr/local/share/omnissiah/communities.nmap', 'timeout':600, 'info':'snmp_community'}]
snmp_timeout = 10
snmp_retries = 2
snmp_threads = 100
snmp_ping_scan = '-n -T5 --host-timeout 15s -PE --disable-arp-ping -sn'
snmp_ping_timeout = 80

#map
nmap_map_list = [{'threadsnum':70, 'arguments':'-n -T4 --host-timeout 60s -PE --disable-arp-ping -sn', 'timeout':240},
{'threadsnum':30, 'arguments':'-n -T4 --host-timeout 120s -Pn -sS -p80,22,49152,8443,5060,8008,631,10010,18000,1700,21,9163,7001,3100,88,\
3389,8081,5357,5002,541,135,3001,139,3268,49154,5555,4045,1688,3000,1080,646,1433,31865,19996,513,2107,900,2601,500,1720,4000,49157,444,\
82,3306,91,993,6646', 'timeout':240},
{'threadsnum':30, 'arguments':'-n -T4 --host-timeout 120s -Pn -sS -p554,9998,8000,8080,7000,5000,9100,3910,23,18301,41794,41795,53,9010,9000,\
445,9090,2121,3283,7262,502,7070,9761,10001,389,902,2002,1723,9001,9999,636,5001,1689,25,593,49156,2103,4001,1801,6000,113,79,943,\
587,6002,647,2003,5353', 'timeout':240},
{'threadsnum':30, 'arguments':'-n -T4 --host-timeout 120s -Pn -sS -p443,9997,8200,5443,2000,880,515,1100,179,5900,9164,322,4352,6783,843,\
1702,5061,8888,49153,61451,10000,67,2001,427,623,111,5432,49155,548,514,1023,8009,5009,464,2105,161,90,215,2049,22022,4522,81,2005,\
873,8002,830,2869', 'timeout':240},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn -sU -p5060,5061 --script sip-methods', 'timeout':180},
{'threadsnum':30, 'arguments':'-n -T4 --host-timeout 120s -Pn -sU -p53,67,68,69,111,123,137,161,389,427,443,500,623,1900,2049,3283,3702,5002,\
5353,8611,8612,445', 'timeout':240}]
map_ip_scope_size = 256
nmap_max_script_value_len = 16000
nmap_script_list = [
{'threadsnum':12, 'arguments':'-n -T5 --host-timeout 3000s -Pn --script http-title,http-headers,http-methods,http-robots.txt,http-date,\
http-comments-displayer,http-enum,http-errors,http-favicon,http-security-headers,http-server-header,https-redirect', 'timeout':3180,
'filter':"type='tcp' AND state='open' AND port IN (80, 81, 880, 8000, 8008, 8080, 8200, 443, 5443, 7000, 8443, 9997, 9998, 49152, 322)"},
{'threadsnum':20, 'arguments':'-n -T5 --host-timeout 780s -Pn --script ssl-cert,ssl-date,ssl-enum-ciphers,sslv2', 'timeout':900,
'filter':"type='tcp' AND state='open' AND port IN (443, 631, 5443, 5061, 8443, 9997, 9998, 49152, 322)"},
{'threadsnum':40, 'arguments':'-n -T4 --host-timeout 420s -Pn --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos,sshv1 \
--script-args ssh_hostkey=visual', 'timeout':540, 'filter':"type='tcp' AND state='open' AND port=22"},
{'threadsnum':20, 'arguments':'-n -T5 --host-timeout 1200s -Pn --script rtsp-url-brute', 'timeout':1500,
'filter':"type='tcp' AND state='open' AND port IN (554,322)"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script sip-methods', 'timeout':180,
'filter':"(type='tcp' AND state='open' AND port IN (5060, 5061)) OR (type='udp' AND state IN('open', 'open|filtered') AND port IN (5060, 5061))"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script upnp-info', 'timeout':480,
'filter':"(type='tcp' AND state='open' AND port=5000) OR (type='udp' AND state='open' AND port=1900)"},
# !!!
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script cups-info,cups-queue-info', 'timeout':480,
'filter':"type='tcp' AND state='open' AND port=631"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script pjl-ready-message', 'timeout':180,
'filter':"type='tcp' AND state='open' AND port=9100"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 180s -Pn --script banner --script-args banner.timeout=4s', 'timeout':240,
'filter':"type='tcp' AND state='open' AND port IN (21, 23, 25, 587, 873, 902, 993, 2121, 4045, 4352, 5900, 6783, 41795, 61451)"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script telnet-encryption', 'timeout':180,
'filter':"type='tcp' AND state='open' AND port IN (23, 25, 513, 514)"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script vnc-info,vnc-title', 'timeout':480,
'filter':"type='tcp' AND state='open' AND port=5900"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script ftp-anon,ftp-bounce,ftp-syst', 'timeout':180,
'filter':"type='tcp' AND state='open' AND port=21"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 240s -Pn --script dns-nsid,dns-recursion,dns-service-discovery,mdns-service-discovery',
'timeout':360, 'filter':"(type='tcp' AND state='open' AND port IN (53, 5353)) OR (type='udp' AND state IN ('open', 'open|filtered') AND port IN (53, 5353))"},
{'threadsnum':20, 'arguments':'-n -T5 --host-timeout 720s -Pn --script nbstat,smb-enum-shares,smb-mbenum,smb-os-discovery,smb-protocols,smb-security-mode,\
smb2-capabilities,smb2-security-mode', 'timeout':840, 'filter':"state='open' AND port IN (137, 139, 445)"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 840s -Pn --script modbus-discover', 'timeout':960, 'filter':"type='tcp' AND state='open' AND port=502"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script afp-serverinfo', 'timeout':180, 'filter':"type='tcp' AND state='open' AND port=548"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 240s -Pn --script rsync-list-modules', 'timeout':300, 'filter':"type='tcp' AND state='open' AND port=873"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 240s -Pn --script ntp-info', 'timeout':300, 'filter':"type='udp' AND state='open' AND port=123"},
#!!!
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script ike-version', 'timeout':480, 'filter':"state='open' AND port=500"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn --script rpcinfo,rpc-grind', 'timeout':180, 'filter':"state='open' AND port=111"},
{'threadsnum':20, 'arguments':'-n -T4 --host-timeout 120s -Pn  --script ldap-rootdse', 'timeout':180,'filter':"state='open' AND port IN (389, 636)"},
{'threadsnum':30, 'arguments':'-n -T5 --host-timeout 1500s -Pn --script snmp-brute,snmp-info,snmp-sysdescr,snmp-netstat,snmp-processes,snmp-interfaces \
--script-args brute.firstonly=true,snmp-brute.communitiesdb=/usr/local/share/omnissiah/communities.nmap', 'timeout':1620,
'filter':"type='udp' AND state='open' AND port=161"}
]
nmap_service_ports = {'tcp':{21:{'intensity':4, 'timeout':210}, 22:{'intensity':7, 'timeout':60}, 23:{'intensity':4, 'timeout':150},
53:{'intensity':0, 'timeout':120}, 80:{'intensity':4, 'timeout':150}, 81:{'intensity':7, 'timeout':180}, 88:{'intensity':7, 'timeout':60},
90:{'intensity':7, 'timeout':150}, 113:{'intensity':0, 'timeout':210}, 135:{'intensity':0, 'timeout':90}, 139:{'intensity':7, 'timeout':90},
389:{'intensity':0, 'timeout':150}, 443:{'intensity':5, 'timeout':210}, 445:{'intensity':7, 'timeout':150}, 548:{'intensity':7, 'timeout':90},
554:{'intensity':7, 'timeout':360}, 593:{'intensity':7, 'timeout':60}, 623:{'intensity':1, 'timeout':270}, 631:{'intensity':7, 'timeout':150},
636:{'intensity':4, 'timeout':300}, 873:{'intensity':0, 'timeout':240}, 900:{'intensity':7, 'timeout':60}, 902:{'intensity':7, 'timeout':60},
1080:{'intensity':0, 'timeout':300}, 1433:{'intensity':7, 'timeout':240}, 1688:{'intensity':1, 'timeout':360}, 1700:{'intensity':5, 'timeout':540},
1720:{'intensity':1, 'timeout':870}, 2001:{'intensity':0, 'timeout':120}, 2002:{'intensity':0, 'timeout':150}, 2003:{'intensity':0, 'timeout':90},
2005:{'intensity':0, 'timeout':300}, 2049:{'intensity':7, 'timeout':270}, 2103:{'intensity':4, 'timeout':660}, 2105:{'intensity':4, 'timeout':660},
2107:{'intensity':4, 'timeout':660}, 2121:{'intensity':7, 'timeout':150}, 2601:{'intensity':4, 'timeout':60}, 3000:{'intensity':0, 'timeout':330},
3001:{'intensity':1, 'timeout':180}, 3268:{'intensity':0, 'timeout':180}, 3306:{'intensity':7, 'timeout':330}, 3389:{'intensity':4, 'timeout':150},
4352:{'intensity':7, 'timeout':240}, 4522:{'intensity':0, 'timeout':90}, 5000:{'intensity':0, 'timeout':210}, 5001:{'intensity':1, 'timeout':480},
5009:{'intensity':7, 'timeout':150}, 5060:{'intensity':4, 'timeout':270}, 5357:{'intensity':1, 'timeout':210}, 5443:{'intensity':1, 'timeout':150},
5555:{'intensity':1, 'timeout':420}, 5900:{'intensity':0, 'timeout':60}, 6002:{'intensity':1, 'timeout':330}, 6783:{'intensity':1, 'timeout':150},
8009:{'intensity':0, 'timeout':300}, 8081:{'intensity':1, 'timeout':180}, 8443:{'intensity':7, 'timeout':720}, 9000:{'intensity':7, 'timeout':420},
9163:{'intensity':7, 'timeout':270}, 9164:{'intensity':7, 'timeout':390}, 9997:{'intensity':4, 'timeout':90}, 9998:{'intensity':4, 'timeout':210},
9999:{'intensity':7, 'timeout':360}, 22022:{'intensity':1, 'timeout':60}, 41794:{'intensity':7, 'timeout':180}, 41795:{'intensity':7, 'timeout':210},
49152:{'intensity':7, 'timeout':90}, 49153:{'intensity':4, 'timeout':330}, 49154:{'intensity':4, 'timeout':390}, 49155:{'intensity':4, 'timeout':600},
49156:{'intensity':4, 'timeout':750}, 49157:{'intensity':4, 'timeout':1200}},
'udp':{69:{'intensity':0, 'timeout':90}, 137:{'intensity':0, 'timeout':60}, 389:{'intensity':7, 'timeout':60}, 2049:{'intensity':7, 'timeout':60},
3283:{'intensity':0, 'timeout':60}, 5060:{'intensity':0, 'timeout':120}}}
nmap_service_arguments = '-n -Pn -T5 --host-timeout {0}s -sV --version-intensity {1} {2}'
nmap_service_arguments_threadsnum = 10
nmap_max_service_servicefp_len = 14000
nmap_os_arguments = '-n -Pn -T5 --host-timeout 180s -O --osscan-guess'
nmap_os_timeout = 240
nmap_os_filter = "state='open' OR (state='closed' AND type='tcp')"
nmap_os_arguments_threadsnum = 10
nmap_db_reconnect_delay = 60

#snmp
snmp_max_value_len = 1000

#ruckussz
ruckussz_threadsnum = 20

#src_addr
mgmt_roles = ['mgmt']

#nnml_prepare
input_ip_bits = 'ip_bits'
input_netnum_bits = 'netnum'
input_word = 'word'

#nnml_train
nnml_model_manufacturer = 'manufacturer'
nnml_model_devicetype = 'devicetype'
nnml_models_path = '/var/lib/omnissiah/models'
nnml_model_filename = '{0}/{1}_{2}'

#hist_dump
hist_dumps_path = '/var/lib/omnissiah/dumps'
hist_dump_filename = '{0}/{1}_{2}.sql.gz'

#zabbix
#zabbix_url = 'https://127.0.0.1/'
zabbix_url = 'http://127.0.0.1/'
zbx_item_pool_size = 10000
zbx_omnissiah_maintenance_group = 'Omnissiah maintenance'

#nnml_gpt
nnml_openai_gpt_timeout = 30
nnml_openai_gpt_model = 'gpt-4'

#api
api_redis_prefix_delimiter = ':'
api_zabbix_connections = 5
api_redis_host = '127.0.0.1'
api_redis_port = 6379
api_redis_protocol = 3
api_device_redis_db = 2
api_zabbix_redis_db = 3

def_api_polling_interval = 240
def_api_ttl = 3600

#api enplug
api_enplug_polling_interval = 30
api_enplug_ttl = def_api_ttl
api_enplug_prefix = 'enplug'

#api activaire
api_activaire_polling_interval = def_api_polling_interval
api_activaire_ttl = def_api_ttl
api_activaire_prefix = 'activaire'

#api zabbix
api_zabbix_polling_interval = 540
api_zabbix_ttl = def_api_ttl
#api_zabbix_prefix = {'host_id':'hosts'+api_redis_prefix_delimiter+'hostid', 'host_host':'hosts'+api_redis_prefix_delimiter+'host',
#'group_id':'groups'+api_redis_prefix_delimiter+'groupid', 'group_name':'groups'+api_redis_prefix_delimiter+'name'}
api_zabbix_limits = {'hosts':1000, 'groups':1000}

#api_onvif
api_onvif_wsdl_path = '/usr/local/lib/omnissiah/omnienv/lib/python3.11/site-packages/onvif/wsdl/'
api_onvif_unpass_per_cycle = 3
api_onvif_polling_interval = 500
api_onvif_ttl = def_api_ttl
api_onvif_prefix = 'onvif'
api_onvif_cpus = 4
api_onvif_coroutines = 50
