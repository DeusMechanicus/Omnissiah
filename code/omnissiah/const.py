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
mist_timeout_connection = 5
mist_timeout_getpost = 30
mist_sessionid_cookie = 'sessionid'
mist_csrftoken_cookie = 'csrftoken'
mist_login_headers = {'Content-Type':'application/json;charset=UTF-8','Accept':'application/json'}
mist_login_body = '{{"email":"{0}","password":"{1}"}}'
mist_cookie_headers = 'sessionid={0}; csrftoken={1}'
mist_self_url = 'https://{0}/api/v1/self'
mist_inventory_url = 'https://{0}/api/v1/orgs/{1}/inventory'
mist_sites_url = 'https://{0}/api/v1/orgs/{1}/sites'
mist_clients_url = 'https://{0}/api/v1/sites/{1}/stats/clients'
mist_host = 'api.mist.com'
mist_devices_url = 'https://{0}/api/v1/sites/{1}/stats/devices'

ruckussz_login_url = 'https://{0}:8443/wsg/api/public/v6_1/session'
#ruckussz_logout_url = 'https://{0}:8443/wsg/api/public/v6_1/session'
ruckussz_wap_url = 'https://{0}:8443/wsg/api/public/v6_1/aps?listSize={1}'
ruckussz_client_url = 'https://{0}:8443/wsg/api/public/v6_1/aps/{1}/operational/client?listSize=1000'
ruckussz_wap_oper_url = 'https://{0}:8443/wsg/api/public/v6_1/aps/{1}/operational/summary'
ruckussz_timeout_connection = 10
ruckussz_timeout_getpost = 90
#ruckussz_threadnum = 50
ruckussz_login_headers = {'Content-Type':'application/json','Accept':'application/json'}
ruckussz_login_body = '{{"username":"{0}","password":"{1}"}}'
ruckussz_sessionid_cookie = 'JSESSIONID'
#ruckussz_cookie_headers = {'Cookie':'{0}={1}'}
