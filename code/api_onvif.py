#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import asyncio

from omnissiah.omnissiah import OmniProgram
from omnissiah.api import ONVIF_API_Daemon


zbx_camera_group = 'Device/Camera'


async def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        api_daemon = ONVIF_API_Daemon(omni_config.zabbix_url, omni_unpwd.zbx_userpasstoken, 'ro', zbx_camera_group, omni_config.dbtype, omni_config.dbhost,
            omni_config.dbname, omni_unpwd.db_api_onvif_user, omni_unpwd.db_api_onvif_password, program.name, omni_config.dbssl, omni_config.api_onvif_wsdl_path,
            omni_config.api_onvif_unpass_per_cycle, omni_config.api_onvif_cpus, omni_config.api_onvif_coroutines, omni_config.api_onvif_polling_interval,
            omni_config.api_redis_host, omni_config.api_redis_port, omni_config.api_redis_protocol, omni_config.api_device_redis_db, omni_config.api_onvif_ttl,
            omni_config.api_onvif_prefix, omni_config.api_redis_prefix_delimiter, program.log)
        await api_daemon.run()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(asyncio.run(main()))

