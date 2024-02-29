#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import daemon

from omnissiah.omnissiah import OmniProgram
from omnissiah.api import Device_API_Activaire, Device_API_Daemon


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        api_daemon = Device_API_Daemon(Device_API_Activaire, (omni_unpwd.activaire_api_key,), omni_config.api_activaire_polling_interval, omni_config.api_redis_host,
            omni_config.api_redis_port, omni_config.api_redis_protocol, omni_config.api_device_redis_db, omni_config.api_activaire_ttl, omni_config.api_activaire_prefix,
            omni_config.api_redis_prefix_delimiter, program.log)
#        with daemon.DaemonContext(working_directory=omni_config.lib_path):
        with daemon.DaemonContext(working_directory=omni_config.lib_path, stdout=sys.stdout):
            api_daemon.run()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())
