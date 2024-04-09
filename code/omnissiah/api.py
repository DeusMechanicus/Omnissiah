import time
import redis
import asyncio
import json
import ipaddress
import logging
from redis.commands.json.path import Path
from aiomultiprocess import Pool
from onvif import ONVIFCamera
from zeep.helpers import serialize_object

from .activaire import ActivaireAPI
from .enplug import EnplugAPI
from .const import activaire_api_url
from .zbx import ZbxAPI
from .db import OmniDB
from .util import safe_json_serialize, remove_duplicate


select_sec_camera_sql = 'SELECT ip, username, password FROM sec_camera_unpwd;'
select_onvif_usernames_passwords_sql = 'SELECT sec_onvif_unpwd.username, sec_onvif_unpwd.password, sec_onvif_unpwd.priority, \
ref_ipprefix.ipprefixid, ref_ipprefix.netnum, ref_ipprefix.startipnum, ref_ipprefix.endipnum FROM sec_onvif_unpwd \
LEFT JOIN ref_ipprefix ON sec_onvif_unpwd.ipprefixid=ref_ipprefix.ipprefixid;'
inup_sec_camera_unpwd_sql = {'mariadb':'INSERT INTO sec_camera_unpwd(ip, username, password) VALUES (%s, %s, %s) ON DUPLICATE KEY UPDATE username=%s, password=%s;',
'pgsql':'INSERT INTO sec_camera_unpwd(ip, username, password) VALUES (%s, %s, %s) ON CONFLICT(ip) DO UPDATE SET username=%s, password=%s;'}

class API_Daemon:
    def __init__(self, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log):
        self.polling_interval = polling_interval
        self.redis_host = redis_host
        self.redis_port = redis_port
        self.redis_protocol = redis_protocol
        self.redis_db = redis_db
        self.ttl = ttl
        self.prefix = prefix
        self.delimiter = delimiter
        self.log = log

    def save_values(self, values):
        pass

    def single_run(self):
        pass

    def run(self):
        while True:
            start_time = time.time()
            try:
                self.single_run()
            except:
                self.log.exception('Fatal error')
            duration = int(time.time() - start_time)
            if duration<self.polling_interval:
                time.sleep(self.polling_interval-duration)

class API_Daemon_async(API_Daemon):
    def __init__(self, cpus, coroutines, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log):
        API_Daemon.__init__(self, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log)
        self.cpus = cpus
        self.coroutines = coroutines

    def save_values(self, values):
        pass

    async def single_run(self):
        pass

    async def run(self):
        while True:
            start_time = time.time()
            try:
                self.save_values(await self.single_run())
            except:
                self.log.exception('Fatal error')
            duration = int(time.time() - start_time)
#            print(duration)
#            break
            if duration<self.polling_interval:
                await asyncio.sleep(self.polling_interval-duration)

class Zabbix_API_Daemon(API_Daemon):
    def __init__(self, zabbix_url, zbx_userpasstoken, mode, limits, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log):
        API_Daemon.__init__(self, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log)
        self.zabbix_url = zabbix_url
        self.zbx_userpasstoken = zbx_userpasstoken
        self.mode = mode
        self.limits = limits

    def save_values(self, values):
        r = redis.Redis(host=self.redis_host, port=self.redis_port, protocol=self.redis_protocol, db=self.redis_db)
        r.flushdb()
        with r.pipeline() as pipe:
            for table, records in values.items():
                for record in records:
                    ids = []
                    if table=='hosts':
                        ids = [table+self.delimiter+'hostid'+self.delimiter+str(record['hostid']), table+self.delimiter+'host'+self.delimiter+record['host']]
                    elif table=='groups':
                        ids = [table+self.delimiter+'groupid'+self.delimiter+str(record['groupid']), table+self.delimiter+'name'+self.delimiter+record['name']]
                    for id in ids:
                        pipe.json().set(id, Path.root_path(), record)
                        pipe.expire(id, self.ttl)
            pipe.execute()

    def single_run(self):
        values = {'hosts':[], 'groups':[]}
        zapi = ZbxAPI(self.zabbix_url, self.zbx_userpasstoken, self.log, mode='ro')
        ids = zapi.host.get(output=['hostid'])
        ids = [ id['hostid'] for id in ids ]
        ids = [ ids[i*self.limits['hosts']:(i+1)*self.limits['hosts']] for i in range(len(ids)//self.limits['hosts']+1) ]
        for chunk in ids:
            if chunk:
                hosts = zapi.host.get(hostids=chunk, selectInventory='extend', selectTags='extend', selectGroups='extend',
                    selectInterfaces='extend', selectMacros='extend', selectParentTemplates='extend')
                if hosts:
                    values['hosts'].extend(hosts)
        ids = zapi.hostgroup.get(output=['groupid'])
        ids = [ id['groupid'] for id in ids ]
        ids = [ ids[i*self.limits['groups']:(i+1)*self.limits['groups']] for i in range(len(ids)//self.limits['groups']+1) ]
        for chunk in ids:
            if chunk:
                groups = zapi.hostgroup.get(groupids=chunk)
                if groups:
                    values['groups'].extend(groups)
        return values


class Device_API_Daemon(API_Daemon):
    def __init__(self, class_type, init_parameters, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log):
        API_Daemon.__init__(self, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log)
        self.class_type = class_type
        self.init_parameters = init_parameters

    def save_values(self, values):
        r = redis.Redis(host=self.redis_host, port=self.redis_port, protocol=self.redis_protocol, db=self.redis_db)
        with r.pipeline() as pipe:
            for value in values:
                id = str(self.devices_api.get_id(value))
                pipe.json().set(self.prefix + self.delimiter + id, Path.root_path(), value)
                pipe.expire(self.prefix + self.delimiter + id, self.ttl)
            pipe.execute()

    def single_run(self):
        self.devices_api = self.class_type(*self.init_parameters)
        values = self.devices_api.getall()
        values = self.devices_api.get_data(values)
        self.save_values(values)
        del self.devices_api


class Device_API:
    def __init__(self):
        self.device_api = None

    def get_data(self, v):
        return v

    def get_id(self, v):
        return v['id']

    def getall(self):
        return self.device_api.getall()


class Device_API_Activaire(Device_API):
    def __init__(self, api_key, api_url=activaire_api_url):
        Device_API.__init__(self)
        self.device_api = ActivaireAPI(api_key, api_url)

    def get_data(self, v):
        return v['body']

    def get_id(self, v):
        return v['_id']


class Device_API_Enplug(Device_API):
    def __init__(self, networkid, bearer):
        Device_API.__init__(self)
        self.device_api = EnplugAPI(networkid, bearer)

    def get_data(self, v):
        return v['Result']['EduStatuses']

    def get_id(self, v):
        return v['Edu']['Id']


class ONVIF_API_Daemon(API_Daemon_async):
    def __init__(self, zabbix_url, zbx_userpasstoken, zbx_mode, zbx_camera_group, dbtype, dbhost, dbname, dbuser, dbpassword, program_name, dbssl,
        wsdl_path, unpass_per_cycle, cpus, coroutines, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log):
        API_Daemon_async.__init__(self, cpus, coroutines, polling_interval, redis_host, redis_port, redis_protocol, redis_db, ttl, prefix, delimiter, log)
        self.zabbix_url = zabbix_url
        self.zbx_userpasstoken = zbx_userpasstoken
        self.zbx_mode = zbx_mode
        self.zbx_camera_group = zbx_camera_group
        self.dbtype = dbtype
        self.dbhost = dbhost
        self.dbname = dbname
        self.dbuser = dbuser
        self.dbpassword = dbpassword
        self.program_name = program_name
        self.dbssl = dbssl
        self.wsdl_path = wsdl_path
        self.unpass_per_cycle = unpass_per_cycle
        self.cameras = {}
        self.onvif_log = logging.getLogger("onvif")
        self.onvif_log.level = logging.ERROR
        db = OmniDB(self.dbtype, self.dbhost, self.dbname, self.dbuser, self.dbpassword, log=self.log, program=self.program_name, ssl=self.dbssl)
        cur = db.cursor()
        cur.execute(select_sec_camera_sql)
        self.db_cameras = { r[0]:{'ip':r[0], 'username':r[1], 'password':r[2]} for r in cur.fetchall() }
        cur.execute(select_onvif_usernames_passwords_sql)
        usernames_passwords = [{'username':r[0], 'password':r[1], 'priority':r[2], 'ipprefixid':r[3], 'netnum':r[4], 'startipnum':r[5], 'endipnum':r[6]} for r in cur.fetchall()]
        for r in usernames_passwords:
            if r['startipnum'] is not None and r['endipnum'] is not None:
                if r['endipnum']<r['startipnum']:
                    v = r['endipnum']
                    r['endipnum'] = r['startipnum']
                    r['startipnum'] = v
        cur.close()
        db.close()
        self.all_unpass, self.subnet_unpass = build_usernames_passwords(usernames_passwords)

    def save_values_db(self, values):
        vals = [ (ip, r['username'], r['password'], r['username'], r['password']) for ip, r in values.items() ]
        if vals:
            db = OmniDB(self.dbtype, self.dbhost, self.dbname, self.dbuser, self.dbpassword, log=self.log, program=self.program_name, ssl=self.dbssl)
            cur = db.cursor()
            cur.executemany(inup_sec_camera_unpwd_sql[db.dbtype], vals)
            db.commit()
            cur.close()
            db.close()

    def save_values_redis(self, values):
        r = redis.Redis(host=self.redis_host, port=self.redis_port, protocol=self.redis_protocol, db=self.redis_db)
        with r.pipeline() as pipe:
            for value in values:
                id = value['ip']
                pipe.json().set(self.prefix + self.delimiter + id, Path.root_path(), value)
                pipe.expire(self.prefix + self.delimiter + id, self.ttl)
            pipe.execute()

    def save_values(self, values):
        try:
            self.save_values_db(values['db'])
        except Exception as e:
            self.log.exception('Fatal error')
        self.save_values_redis(values['redis'])

    async def single_run(self):
        try:
            zapi = ZbxAPI(self.zabbix_url, self.zbx_userpasstoken, self.log, mode=self.zbx_mode)
            groupid = zapi.hostgroup.get(output=['groupid'], filter={'name':[self.zbx_camera_group]})[0]['groupid']
            hosts = zapi.host.get(output=['hostid', 'status', 'maintenance_status'], selectInterfaces=['ip'], groupids=groupid)
        except:
            hosts = []
        zbx_cameras = { h['interfaces'][0]['ip']:None for h in hosts if h['status']=='0' }
        ips = { ip for ip in self.cameras if ip not in zbx_cameras }
        for ip in ips:
            del self.cameras[ip]
        for ip in zbx_cameras:
            if ip not in self.cameras:
                self.cameras[ip] = {'ip':ip, 'port':80, 'wsdl_path':self.wsdl_path, 'unpass_next_index':0, 
                    'unpass_per_cycle':self.unpass_per_cycle, 'usernames_passwords':[]}
            if ip in self.db_cameras:
                self.cameras[ip]['usernames_passwords'].append({'username':self.db_cameras[ip]['username'], 'password':self.db_cameras[ip]['password']})
            ipnum = int(ipaddress.IPv4Address(ip))
            for subnet in self.subnet_unpass:
                if ipnum>=subnet['startipnum'] and ipnum<=subnet['endipnum']:
                    self.cameras[ip]['usernames_passwords'].extend(subnet['usernames_passwords'])
                    break
            self.cameras[ip]['usernames_passwords'].extend(self.all_unpass)
        results = []
        async with Pool(processes=self.cpus, childconcurrency=self.coroutines) as pool:
            async for result in pool.map(process_camera, self.cameras.values()):
                if result is not None:
                    results.append(result)
        values = {'redis':[], 'db':{}}
        for r in results:
            cam = r['camera']
            self.cameras[cam['ip']]['unpass_next_index'] = cam['unpass_next_index']
            if r['statuses']['GetDeviceInformation']:
                values['db'][cam['ip']] = cam['usernames_passwords'][cam['unpass_next_index']]
                values['redis'].append({'ip':cam['ip'], 'deviceinfo':r['deviceinfo'], 'videosources':r['videosources'],
                    'videosourceconfigurations':r['videosourceconfigurations']})
        return values


def build_prefix_usernames_passwords(usernames_passwords):
    usernames = [ r for r in usernames_passwords if r['username'] is not None and r['password'] is None ]
    passwords = [ r for r in usernames_passwords if r['username'] is None and r['password'] is not None ]
    unpass = [ {'username':r['username'], 'password':r['password'], 'priority':r['priority']} for r in usernames_passwords \
        if r['username'] is not None and r['password'] is not None ]
    for u in usernames:
        for p in passwords:
            unpass.append({'username':u['username'], 'password':p['password'], 'priority':u['priority']+p['priority']})
    unpass = sorted(unpass, key=lambda d: d['priority'], reverse=True)
    for r in unpass:
        del r['priority']
    unpass = remove_duplicate(unpass, ['username', 'password'])
    return unpass

def build_usernames_passwords(usernames_passwords):
    all_unpass = build_prefix_usernames_passwords([ r for r in usernames_passwords if r['ipprefixid'] is None ])
    subnet_unpass = {}
    for r in usernames_passwords:
        ipprefixid = r['ipprefixid']
        if ipprefixid is not None:
            if ipprefixid not in subnet_unpass:
                subnet_unpass[ipprefixid] = {'netnum':r['netnum'], 'startipnum':r['startipnum'], 'endipnum':r['endipnum'],
                    'size':r['endipnum']-r['startipnum']+1, 'usernames_passwords':[]}
            subnet_unpass[ipprefixid]['usernames_passwords'].append(r)
    for ipprefixid, prefix in subnet_unpass.items():
        subnet_unpass[ipprefixid]['usernames_passwords'] = build_prefix_usernames_passwords(prefix['usernames_passwords'])
    subnet_unpass = subnet_unpass.values()
    subnet_unpass = sorted(subnet_unpass, key=lambda d: d['size'])
    return all_unpass, subnet_unpass

def serialize_zeep(zobj):
    return json.loads(safe_json_serialize(serialize_object(zobj)))

async def process_camera(camera):
    try:
        result = {'camera':camera, 'deviceinfo':None, 'videosources':None, 'videosourceconfigurations':None,
            'statuses':{'ONVIFCamera':False,'update_xaddrs':False, 'create_devicemgmt_service':False, 'GetDeviceInformation':False,
            'create_media_service':False, 'GetVideoSources':False, 'GetVideoSourceConfigurations':False}}
        is_login_success = False
        for i in range(camera['unpass_per_cycle']):
            try:
                username = camera['usernames_passwords'][camera['unpass_next_index']]['username']
                password = camera['usernames_passwords'][camera['unpass_next_index']]['password']
                onvifcam = ONVIFCamera(camera['ip'], camera['port'], username, password, camera['wsdl_path'])
                result['statuses']['ONVIFCamera'] = True
                await onvifcam.update_xaddrs()
                result['statuses']['update_xaddrs'] = True
                devicemgmt = await onvifcam.create_devicemgmt_service()
                result['statuses']['create_devicemgmt_service'] = True
                result['deviceinfo'] = serialize_zeep(await devicemgmt.GetDeviceInformation())
                result['statuses']['GetDeviceInformation'] = True
                is_login_success = True
                break
            except Exception as e:
                camera['unpass_next_index'] += 1
                camera['unpass_next_index'] = 0 if camera['unpass_next_index']>=len(camera['usernames_passwords']) else camera['unpass_next_index']
        if is_login_success:
            try:
                mediamgmt = await onvifcam.create_media_service()
                result['statuses']['create_media_service'] = True
                result['videosources'] = serialize_zeep(await mediamgmt.GetVideoSources())
                result['statuses']['GetVideoSources'] = True
                result['videosourceconfigurations'] = serialize_zeep(await mediamgmt.GetVideoSourceConfigurations())
                result['statuses']['GetVideoSourceConfigurations'] = True
            except:
                pass
        return result
    except:
        return None
