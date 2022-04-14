#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
from random import shuffle
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor, as_completed

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.ruckussz import RuckusSZAPI
from omnissiah.util import list_of_dicts_to_single_layer

select_ruckussz_sql = "SELECT ip FROM raw_scan_ip WHERE ipid IN (SELECT ipid FROM raw_scan_port WHERE state='open' AND type='tcp' AND port=8200) AND \
ipid IN (SELECT ipid FROM raw_scan_port WHERE state='open' AND type='tcp' AND port=9997) AND \
ipid IN (SELECT ipid FROM raw_scan_port WHERE state='open' AND type='tcp' AND port=9998) ORDER BY ip;"
raw_ruckussz_table = 'raw_ruckussz'


def select_ruckussz_ips(db, log):
    cur = db.cursor()
    cur.execute(select_ruckussz_sql)
    result = [r[0] for r in cur.fetchall()]
    cur = db.close()
    return result

def get_ruckuszd_wlcs(ips, log):
    wlcs = {}
    for ip in ips:
        wlcs[ip] = {'ip':ip, 'waps':[], 'api':RuckusSZAPI(ip, omni_unpwd.ruckussz_api_username, omni_unpwd.ruckussz_api_password, log)}
    for ip, wlc in wlcs.items():
        api = wlc['api']
        try:
            api.login()
            wlc['waps'] = api.get_waps()
        except:
            wlc['waps'] = None
        finally:
            api.logout()
    return wlcs

def single_wap_get(api, mac, wlcip, log):
    try:
        result = api.get_wap_operational(mac)
    except:
        log.exception('Fatal error')
        result = None
    finally:
        if result:
            result['wlcip'] = wlcip
        return result

def get_ruckuszd_waps(wlcs, threadsnum, log):
    waps = []
    jobs = []
    for ip, wlc in wlcs.items():
        try:
            wlc['api'].logout()
            wlc['api'].login()
        except:
            pass
    for ip, wlc in wlcs.items():
        if wlc['waps'] and wlc['api'].sessionid:
            for wap in wlc['waps']:
                job = wap.copy()
                job['wlcip'] = ip
                jobs.append(job)
    shuffle(jobs)
    with ThreadPoolExecutor(max_workers=threadsnum) as executor:
        futures = []
        for job in jobs:
            futures.append(executor.submit(single_wap_get, api=wlcs[job['wlcip']]['api'], mac=job['mac'], wlcip=job['wlcip'], log=log))
        for future in as_completed(futures):
            wap = future.result()
            if wap is not None:
                waps.append(wap)
        executor.shutdown(wait=False, cancel_futures=True)
    for ip, wlc in wlcs.items():
        wlc['api'].logout()
    return waps


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        ips = select_ruckussz_ips(omnidb, program.log)
        omnidb.close()
        wlcs = get_ruckuszd_wlcs(ips, program.log)
        waps = get_ruckuszd_waps(wlcs, omni_config.ruckussz_threadsnum, program.log)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.insert_list_of_dicts(raw_ruckussz_table, list_of_dicts_to_single_layer(waps), program.log)
        omnidb.run_program_queries(stage=2)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())