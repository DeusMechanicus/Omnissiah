#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram


select_max_nnml_train_records_sql = "SELECT value FROM cfg_parameter WHERE parameter='max_nnml_train_records' AND tablename='';"
truncate_tmp_intid_sql = 'TRUNCATE TABLE tmp_intid;'
insert_trainid_to_tmp_sql = 'INSERT INTO tmp_intid (id) SELECT trainid FROM nnml_train ORDER BY created DESC LIMIT {0};'


def prepare_train_tables (db, log):
    cur = db.cursor()
    cur.execute(select_max_nnml_train_records_sql)
    max_nnml_train_records = int(cur.fetchall()[0][0])
    cur.execute(truncate_tmp_intid_sql)
    db.commit()
    cur.execute(insert_trainid_to_tmp_sql.format(str(max_nnml_train_records-1)))
    db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_nnml_user, omni_unpwd.db_nnml_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=list(range(1,21)))
        prepare_train_tables(omnidb, program.log)
        omnidb.run_program_queries(stage=[21,22])
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())