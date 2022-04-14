#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import requests
import csv

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram

insert_raw_mac_sql = {'mariadb':'INSERT IGNORE INTO raw_mac (registry, assignment, organization, address) VALUES (%s, %s, %s, %s);',
    'pgsql':'INSERT INTO raw_mac (registry, assignment, organization, address) VALUES (%s, %s, %s, %s) ON CONFLICT DO NOTHING;'}


def download_macs(urls):
    result = []
    for url in urls:
        response = requests.get(url, allow_redirects=True)
        if response.status_code == 200:
            response.encoding = 'utf-8'
            result.append(response.text)
    return result

def parse_csv(texts):
    result = []
    for text in texts:
        reader = csv.reader(text.strip().splitlines())
        next(reader, None)
        result.extend([tuple(row) for row in reader])
    return result

def save_macs(db, macs):
    cur = db.cursor()
    if macs:
        cur.executemany(insert_raw_mac_sql[omni_config.dbtype], macs)
        db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_raw_user, omni_unpwd.db_raw_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        macs = parse_csv(download_macs(omni_const.ieee_oui_csv_url))
        omnidb.run_program_queries(stage=1)
        save_macs(omnidb, macs)
        omnidb.run_program_queries(stage=2)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())