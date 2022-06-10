#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
import os
from datetime import datetime

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram


insert_hist_dump_sql = 'INSERT INTO hist_dump (dump_filename) VALUES (%s);'
truncate_tmp_intid_sql = 'TRUNCATE TABLE tmp_intid;'
select_max_hist_dump_records_sql = "SELECT value FROM cfg_parameter WHERE parameter='max_hist_dump_records' AND tablename='';"
insert_modelids_sql = 'INSERT INTO tmp_intid (id) SELECT dumpid FROM hist_dump ORDER BY created DESC LIMIT {0};'
select_files_to_delete_sql = 'SELECT DISTINCT dump_filename FROM hist_dump WHERE NOT EXISTS (SELECT NULL FROM tmp_intid WHERE tmp_intid.id=hist_dump.dumpid);'
dump_programs = {'mariadb':'/usr/bin/mysqldump --single-transaction -h {0} -u {1} -p{2} {3} | gzip >{4}',
'pgsql':'/usr/bin/pg_dump --dbname=postgresql://{1}:{2}@{0}/{3} | gzip >{4}'}


def save_dump(db, log):
    filename = omni_config.hist_dump_filename.format(omni_config.hist_dumps_path, 'dump', datetime.now().strftime('%Y%m%d%H%M%S'))
    cur = db.cursor()
    cur.execute(insert_hist_dump_sql, (filename,))
    cur.close()
    os.system(dump_programs[omni_config.dbtype].format(omni_config.dbhost, omni_unpwd.db_hist_user, omni_unpwd.db_hist_password,
        omni_config.dbname, filename))

def prepare_dump_tables(db, log):
    cur = db.cursor()
    cur.execute(truncate_tmp_intid_sql)
    db.commit()
    cur.execute(select_max_hist_dump_records_sql)
    max_hist_dump_records = int(cur.fetchall()[0][0])
    cur.execute(insert_modelids_sql.format(str(max_hist_dump_records)))
    db.commit()
    cur.execute(select_files_to_delete_sql)
    files_to_delete = set([r[0] for r in cur.fetchall()])
    cur.close()
    return files_to_delete

def delete_dump_files(files_to_delete, log):
    dump_path = os.path.join(omni_config.hist_dumps_path, '')
    for fn in files_to_delete:
        path = os.path.join(os.path.dirname(fn), '')
        if path==dump_path:
            try:
                os.remove(fn)
            except:
                log.exception('Fatal error')


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_hist_user, omni_unpwd.db_hist_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        save_dump(omnidb, program.log)
        files_to_delete = prepare_dump_tables(omnidb, program.log)
        omnidb.run_program_queries(stage=2)
        delete_dump_files(files_to_delete, program.log)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())