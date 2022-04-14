#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.mist import MistAPI
from omnissiah.util import list_of_dicts_to_single_layer

raw_mist_table = 'raw_mist'


def get_mist_waps(mistapi, log):
    selfinfo = mistapi.getself()
    mistapi.orgid = selfinfo['privileges'][0]['org_id']
    sites = mistapi.getsites()
    waps = mistapi.get_alldevices(sites)
    return waps


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        mistapi = MistAPI(omni_unpwd.mist_api_username, omni_unpwd.mist_api_password, program.log)
        mistapi.login()
        waps = get_mist_waps(mistapi, program.log)
        mistapi.logout()
        omnidb.insert_list_of_dicts(raw_mist_table, list_of_dicts_to_single_layer(waps), program.log)
        omnidb.run_program_queries(stage=2)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())