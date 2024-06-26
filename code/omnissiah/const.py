arp_oid = '.1.3.6.1.2.1.4.22.1.2'
snmp_community_infoid = 1

enplug_api_url = 'https://monitoring.enplug.com/v1/edumonitoring/edustatuses/filter'
enplug_control_url = 'https://core.enplug.com/v1/commandreceiver/execute?eduid='
enplug_post_headers = {'Content-Type':'application/json','Authorization':'Bearer {0}'}
enplug_post_payload = {'NetworkId':None}

activaire_api_url = 'https://api.activaire.com/devices'
activaire_api_headers = {'authorizationToken':''}

mist_login_url = 'https://{0}/api/v1/login'
mist_logout_url = 'https://{0}/api/v1/logout'
mist_timeout_connection =10
mist_timeout_getpost = 60
mist_authorization_header = 'Token {0}'
mist_self_url = 'https://{0}/api/v1/self'
mist_inventory_url = 'https://{0}/api/v1/orgs/{1}/inventory'
mist_sites_url = 'https://{0}/api/v1/orgs/{1}/sites'
mist_clients_url = 'https://{0}/api/v1/sites/{1}/stats/clients'
mist_host = 'api.mist.com'
mist_devices_url = 'https://{0}/api/v1/sites/{1}/stats/devices'
mist_get_repeat = 3
mist_get_pause = 1.0

ruckussz_login_url = 'https://{0}:8443/wsg/api/public/v6_1/session'
ruckussz_wap_url = 'https://{0}:8443/wsg/api/public/v6_1/aps?listSize={1}&index={2}'
ruckussz_client_url = 'https://{0}:8443/wsg/api/public/v6_1/aps/{1}/operational/client?listSize=1000'
ruckussz_wap_oper_url = 'https://{0}:8443/wsg/api/public/v6_1/aps/{1}/operational/summary'
ruckussz_timeout_connection = 10
ruckussz_timeout_getpost = 90
ruckussz_login_headers = {'Content-Type':'application/json','Accept':'application/json'}
ruckussz_login_body = '{{"username":"{0}","password":"{1}"}}'
ruckussz_sessionid_cookie = 'JSESSIONID'

min_nnml_word_length = 2
max_nnml_word_length = 256
nnml_preprocess_regex = ['[0-9,A-F,a-f][0-9,A-F,a-f]:[0-9,A-F,a-f][0-9,A-F,a-f]:[0-9,A-F,a-f][0-9,A-F,a-f]:[0-9,A-F,a-f][0-9,A-F,a-f]:[0-9,A-F,a-f][0-9,A-F,a-f]:[0-9,A-F,a-f][0-9,A-F,a-f]',
'[0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f]',
'[0-9,A-F,a-f]+:[0-9,A-F,a-f]+:[0-9,A-F,a-f]+:[0-9,A-F,a-f]+:[0-9,A-F,a-f]+:[0-9,A-F,a-f]+:[0-9,A-F,a-f]+:[0-9,A-F,a-f]+',
'\d+d\d+h\d+m\d+s', '\d+h\d+m\d+s', '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d', '\d\d\d\d-\d\d-\d\dT', '\d\d\d\d-\d\d-\d\d', '\d+\.\d+\.\d+\.\d+', '\d\d:\d\d:\d\d', '\d\d:\d\d',
'\d\d-\d\d-\d\d', 'node_session=[^\;]+;,', 
'([0-9,A-F,a-f]+:+){2,7}[0-9,A-F,a-f]+', '([0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f] ){2,9}[0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f][0-9,A-F,a-f]',
'\d{10,11}z']
nnml_manufacturers_dropout = 0.05
nnml_manufacturers_trains = [{'epochs':128, 'batches':128, 'lr':0.0005}, {'epochs':8, 'batches':0, 'lr':0.0005},
{'epochs':32, 'batches':128, 'lr':0.0002}, {'epochs':8, 'batches':0, 'lr':0.0002}]
nnml_devicetypes_dropout = 0.05
nnml_devicetypes_trains = [{'epochs':64, 'batches':256, 'lr':0.0005}, {'epochs':8, 'batches':0, 'lr':0.0005},
{'epochs':32, 'batches':128, 'lr':0.0002}, {'epochs':8, 'batches':0, 'lr':0.0002}]

zbx_zabbix_timeout = 600
zbx_update_zbx_omni_map_sql = 'UPDATE zbx_omni_map SET omniid={0}, zbxid={1} WHERE mapid={2};'
