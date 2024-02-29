import omni_const
import omni_config
import omni_unpwd

from fastapi import FastAPI, HTTPException, Path
import json
import random
import redis
from redis.commands.json.path import Path

from omnissiah.omnissiah import OmniProgram
from omnissiah.zbx import ZbxAPI

status_messages = {'device':{200:'Ok', 404:'Device not found', 501:'Device API error', 503:'Device API not implemented'},
'gateway_zabbix':{200:'Ok', 404:'Zabbix object not found', 501:'Zabbix API gateway error', 503:'Zabbix API gateway not implemented'},
'zabbix':{200:'Ok', 404:'Zabbix object not found', 501:'Zabbix API error', 503:'Zabbix API not implemented'}}

program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
redis_device = redis.asyncio.Redis(host=omni_config.api_redis_host, port=omni_config.api_redis_port,
    protocol=omni_config.api_redis_protocol, db=omni_config.api_device_redis_db)
redis_zabbix = redis.asyncio.Redis(host=omni_config.api_redis_host, port=omni_config.api_redis_port,
    protocol=omni_config.api_redis_protocol, db=omni_config.api_zabbix_redis_db)
api = FastAPI()


def get_zapi():
    zapi = ZbxAPI(omni_config.zabbix_url, omni_unpwd.zbx_userpasstoken, program.log, mode='ro')
    return zapi

async def zabbix_hosts_get(hostid: int | None = None, host: str | None = None,  search: str | None = None):
    status = None
    result = None
    try:
        zapi = get_zapi()
        if hostid is not None:
            hosts = zapi.host.get(hostids=hostid, selectInventory='extend', selectTags='extend', selectGroups='extend',
                selectInterfaces='extend', selectMacros='extend', selectParentTemplates='extend')
            result = hosts[0]
        elif host is not None:
            hosts = zapi.host.get(filter={'host':host}, selectInventory='extend', selectTags='extend', selectGroups='extend',
                selectInterfaces='extend', selectMacros='extend', selectParentTemplates='extend')
            result = hosts[0]
        elif search is not None:
            zbxsearch = json.loads(search)
            result = zapi.host.get(search=zbxsearch, selectInventory='extend', selectTags='extend', selectGroups='extend',
                selectInterfaces='extend', selectMacros='extend', selectParentTemplates='extend')
        else:
            status = 503
    except:
        status = 501
    status = 200 if status is None and result else 404
    return status, result

@api.get('/gateway/v1/zabbix/hosts/hostid/{hostid}')
@api.get('/gateway/v1/zabbix/hosts/hostid/{hostid}/')
@api.get('/gateway/v1/zabbix/hosts/host/{host:path}')
async def gateway_v1_zabbix_host_id(hostid: int | None = None, host: str | None = None):
    status, result = await zabbix_hosts_get(hostid=hostid, host=host)
    if status == 200:
        return result
    elif status in status_messages['gateway_zabbix']:
        raise HTTPException(status_code=status, detail=status_messages['gateway_zabbix'][status])
    else:
        raise HTTPException(status_code=503, detail=status_messages['gateway_zabbix'][503])

@api.get('/gateway/v1/zabbix/hosts/search')
@api.get('/gateway/v1/zabbix/hosts/search/')
async def gateway_v1_zabbix_host_search(search: str | None = None):
    status, result = await zabbix_hosts_get(search=search)
    if status == 200:
        return result
    elif status in status_messages['gateway_zabbix']:
        raise HTTPException(status_code=status, detail=status_messages['gateway_zabbix'][status])
    else:
        raise HTTPException(status_code=503, detail=status_messages['gateway_zabbix'][503])

async def redis_json_get(r: redis.asyncio.Redis, prefix: str, id: str, field: str | None = None):
    try:
        if field:
            result = await r.json().get(prefix + omni_config.api_redis_prefix_delimiter + id, field)
        else:
            result = await r.json().get(prefix + omni_config.api_redis_prefix_delimiter + id, Path.root_path())
        return 200 if result is not None or field else 404, result
    except:
        return 501, None

@api.get('/omnissiah/v1/device/{device}/{id}')
@api.get('/omnissiah/v1/device/{device}/{id}/')
@api.get('/omnissiah/v1/device/{device}/{id}/{field}')
@api.get('/omnissiah/v1/device/{device}/{id}/{field}/')
async def omnissiah_v1_device_enplug_id(device: str, id: str, field: str | None = None):
    status, result = await redis_json_get(redis_device, device, id, field)
    if status == 200:
        return result
    elif status in status_messages['device']:
        raise HTTPException(status_code=status, detail=status_messages['device'][status])
    else:
        raise HTTPException(status_code=503, detail=status_messages['device'][503])

@api.get('/omnissiah/v1/zabbix/{table}/{key}/{id}')
@api.get('/omnissiah/v1/zabbix/{table}/{key}/{id:path}')
async def omnissiah_v1_zabbix_table_key_id(table: str, key: str, id: str, field: str | None = None):
    status, result = await redis_json_get(redis_zabbix, table + omni_config.api_redis_prefix_delimiter + key, id, field)
    if status == 200:
        return result
    elif status in status_messages['zabbix']:
        raise HTTPException(status_code=status, detail=status_messages['zabbix'][status])
    else:
        raise HTTPException(status_code=503, detail=status_messages['zabbix'][503])

@api.get('/')
async def root():
    HTTPException(status_code=503, detail='Not implemented')

