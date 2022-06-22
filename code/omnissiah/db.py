import mariadb
import psycopg2
import logging
from .msg import msg_db_conn_opened, msg_db_conn_closed, msg_db_query_try, msg_db_added_records
from .util import split_list_bysize

select_program_query_sql = 'SELECT code_program_query.query, code_program_query.id, code_program_query.parameter, code_program_query.tablename, \
code_program_query.nrepeat FROM code_program_query INNER JOIN code_program ON code_program_query.programid=code_program.programid \
WHERE code_program_query.enabled<>0 AND {0} \
ORDER BY code_program_query.stage, code_program_query.priority;'
select_cfg_parameter_table = "SELECT value FROM cfg_parameter WHERE parameter='{0}' AND tablename='{1}'"
select_cfg_parameter_null = "SELECT value FROM cfg_parameter WHERE parameter='{0}' AND tablename=''"
insert_log_program_sql = "INSERT INTO log_program (programid, actionid) SELECT code_program.programid, {1} FROM code_program WHERE program='{0}';"
insert_log_query_sql = "INSERT INTO log_program (programid, actionid, queryid) SELECT code_program.programid, {1}, {2} FROM code_program WHERE program='{0}';"
action_cycle_started = 1
action_cycle_finished = 2
action_program_started = 3
action_program_finished = 4
action_query_started = 5
action_query_finished = 6


class OmniDB:
    def __init__(self, dbtype, host, database, user, password, ssl=True, log=None, program=None):
        self.log = log
        self.dbtype = dbtype
        self.host = host
        self.database = database
        self.user = user
        self.password = password
        self.ssl = ssl
        self.program = program
        self.open()
        self.log_program(action_program_started)

    def connect(self):
        if self.dbtype=='mariadb':
            conn = mariadb.connect(host=self.host, user=self.user, passwd=self.password, database=self.database, ssl=self.ssl)
        elif self.dbtype=='pgsql':
            if self.ssl:
                conn = psycopg2.connect(host=self.host, user=self.user, password=self.password, dbname=self.database, sslmode='require')
            else:
                conn = psycopg2.connect(host=self.host, user=self.user, password=self.password, dbname=self.database)
        else:
            conn = None
        self.log.info(msg_db_conn_opened)
        return conn

    def open(self):
        self.conn = self.connect()

    def log_program(self, actionid, queryid=None):
        if self.program:
            cur = self.cursor()
            if queryid is None:
                sql = insert_log_program_sql.format(self.program, str(actionid))
            else:
                sql = insert_log_query_sql.format(self.program, str(actionid), str(queryid))
            cur.execute(sql)
            self.commit()
            cur.close()

    def cursor(self):
        return self.conn.cursor()

    def commit(self):
        return self.conn.commit()

    def close(self):
        try:
            if self.conn:
                self.log_program(action_program_finished)
                self.log.info(msg_db_conn_closed)
                return self.conn.close()
        except:
            return None
        return None

    def find_parameter(self, parameter, table, def_value=''):
        result = def_value
        if parameter is not None:
            parameter = parameter.strip()
            cur = self.cursor()
            if table is not None:
                cur.execute(select_cfg_parameter_table.format(parameter, table.strip()))
                result = cur.fetchall()
                if not result:
                    cur.execute(select_cfg_parameter_null.format(parameter))
                    result = cur.fetchall()
            else:
                cur.execute(select_cfg_parameter_null.format(parameter))
                result = cur.fetchall()
            cur.close()
            if result:
                result = result[0][0]
            else:
                result = def_value
        return result

    def run_program_queries(self, stage = None, priority = None):
        cur = self.cursor()
        wheresql = "code_program.program='{0}'".format(self.program)
        if stage is not None:
            if type(stage) is list:
                wheresql = wheresql + ' AND code_program_query.stage IN ({0})'.format(','.join([str(s) for s in stage]))
            else:
                wheresql = wheresql + ' AND code_program_query.stage={0}'.format(stage)
        if stage is not None and priority is not None:
            if type(priority) is list:
                wheresql = wheresql + ' AND code_program_query.priority IN ({0})'.format(','.join([str(p) for p in priority]))
            else:
                wheresql = wheresql + ' AND code_program_query.priority={0}'.format(priority)
        cur.execute(select_program_query_sql.format(wheresql))
        queries = cur.fetchall()
        for query in queries:
            sql = query[0].strip()
            if sql:
                sql = sql if sql[-1]==';' else sql + ';'
                parameter = query[2]
                param_value = None if parameter is None else self.find_parameter(parameter, query[3])
                sql = sql if parameter is None else sql.format(param_value)
                self.log.debug(msg_db_query_try.format(sql))
                if self.log.level==logging.DEBUG:
                    self.log_program(action_query_started, query[1])
                for i in range(query[4]):
#                    print(sql)
                    cur.execute(sql)
                    self.commit()
                if self.log.level==logging.DEBUG:
                    self.log_program(action_query_finished, query[1])
        cur.close()

    def executemany(self, sql, vals, part_size=None, ignore_errors=False):
        cur = self.cursor()
        recnum = 0
        if part_size is None:
            parts = [vals]
        else:
            parts = split_list_bysize(vals, part_size)
        for part in parts:
            if ignore_errors:
                try:
                    cur.executemany(sql, part)
                    self.commit()
                    recnum += len(part)
                except:
                    pass
            else:
                cur.executemany(sql, part)
                self.commit()
                recnum += len(part)
        cur.close()
        return recnum

    def table_columns_list(self, table):
        cur = self.cursor()
        sql = 'SELECT * FROM ' + table + ' LIMIT 1;'
        cur.execute(sql)
        l = [d[0] for d in cur.description]
        cur.close()
        return l

    def table_columns_dict(self, table, value=None):
        return dict.fromkeys(self.table_columns_list(table), value)

    def insert_list_of_dicts(self, table, source, log, msg=msg_db_added_records, byrecords=False):
        src_fields = set()
        for item in source:
            for field in item:
                src_fields.add(field)
        cur = self.cursor()
        dst_fields = set(self.table_columns_list(table))
        fields = src_fields & dst_fields
        sql = 'INSERT INTO ' + table + '(' + ','.join(fields) + ') VALUES (' + ('%s,'*len(fields))[:-1] + ');'
        vallist = []
        numrec = 0
        for item in source:
            i = item.copy()
            for f in fields:
                if f not in i:
                    i[f] = None
            v = tuple([i[f] for f in fields])
            if byrecords:
                cur.execute(sql, v)
                self.commit()
                numrec += 1
            else:
                vallist.append(v)
        if vallist:
            cur.executemany(sql, vallist)
            self.commit()
            numrec = len(vallist)
        log.info(msg.format(table, numrec))
        cur.close()
