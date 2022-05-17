#!/usr/bin/env python3

import omni_const
import omni_config
import omni_unpwd

import sys
from ipaddress import ip_address

from omnissiah.db import OmniDB
from omnissiah.omnissiah import OmniProgram
from omnissiah.nnml import NNMLParser


select_input_typeid_sql = "SELECT typeid FROM ref_nnml_input_type WHERE input_type='{0}'"
insert_tmp_nnml_input_sql = 'INSERT INTO tmp_nnml_input (input_typeid, typeid) VALUES (%s, %s);'
insert_tmp_nnml_ip_input_sql = 'INSERT INTO tmp_nnml_ip_input (ipid, inputid, value) VALUES (%s, %s, %s);'
select_tmp_nnml_ip = 'SELECT ip, ipid, netnum FROM tmp_nnml_ip;'
select_tmp_nnml_input = 'SELECT typeid, inputid FROM tmp_nnml_input WHERE input_typeid={0};'
select_ref_nnml_word_sql = 'SELECT srcid, src_name, query, min_word_num, min_word_percent, max_word_percent FROM ref_nnml_word_source;'
select_info_nnml_word_sql = 'SELECT id, srcid, groupname, word FROM info_nnml_word;'
insert_info_nnml_word_sql = 'INSERT INTO info_nnml_word (srcid, groupname, word) VALUES (%s, %s, %s);'
select_info_nnml_word_sql = 'SELECT id, srcid, groupname, word FROM info_nnml_word;'


def add_ip_inputs(db, log):
    cur = db.cursor()
    cur.execute(select_input_typeid_sql.format(omni_config.input_ip_bits))
    input_typeid = cur.fetchall()[0][0]
    vallist = [tuple([input_typeid, i]) for i in range(32)]
    cur.executemany(insert_tmp_nnml_input_sql, vallist)
    db.commit()
    cur.execute(select_input_typeid_sql.format(omni_config.input_netnum_bits))
    input_typeid = cur.fetchall()[0][0]
    vallist = [tuple([input_typeid, i]) for i in range(1,33)]
    cur.executemany(insert_tmp_nnml_input_sql, vallist)
    db.commit()
    cur.close()

def add_ip_input_values(db, log):
    cur = db.cursor()
    cur.execute(select_tmp_nnml_ip)
    ipmap = {r[0]:{'ipid':r[1], 'netnum':r[2]} for r in cur.fetchall()}
    cur.execute(select_input_typeid_sql.format(omni_config.input_ip_bits))
    input_typeid = cur.fetchall()[0][0]
    cur.execute(select_tmp_nnml_input.format(str(input_typeid)))
    typemap = {r[0]:r[1] for r in cur.fetchall()}
    vallist = []
    for ip in ipmap:
        bits = '{:b}'.format(ip_address(ip))
        i = 31
        for bit in bits:
            if bit=='1':
                vallist.append((ipmap[ip]['ipid'], typemap[i], 1))
            i -= 1
    cur.execute(select_input_typeid_sql.format(omni_config.input_netnum_bits))
    input_typeid = cur.fetchall()[0][0]
    cur.execute(select_tmp_nnml_input.format(str(input_typeid)))
    typemap = {r[0]:r[1] for r in cur.fetchall()}
    vallist.extend([tuple([ipmap[ip]['ipid'], typemap[ipmap[ip]['netnum']], 1]) for ip in ipmap])
    cur.executemany(insert_tmp_nnml_ip_input_sql, vallist)
    db.commit()
    cur.close()

def load_words(db, log):
    words = []
    cur = db.cursor()
    cur.execute(select_ref_nnml_word_sql)
    select_ref_nnml_word_source_sql = 'SELECT srcid, src_name, query, min_word_num, min_word_percent, max_word_percent FROM ref_nnml_word_source;'
    words = [{'srcid':r[0],'src_name':r[1], 'query':r[2], 'min_word_num':r[3], 'min_word_percent':r[4], 'max_word_percent':r[5]} for r in cur.fetchall()]
    for src in words:
        cur.execute(src['query'])
        src['records'] = {}
        for r in cur.fetchall():
            if r[1] is not None:
                if r[2] not in src['records']:
                    src['records'][r[2]] = []
                src['records'][r[2]].append({'ipid':r[0], 'value':r[1]})
    cur.close()
    return words

def parse_words(dbwords):
    parser = NNMLParser()
    for src in dbwords:
        src['words'] = {}
        src['ipids'] = {}
        for group, values in src['records'].items():
            words_group = {}
            for vdict in values:
                words = parser.parse(src['src_name'], group, str(vdict['value']))
                for word in words:
                    if word not in words_group:
                        words_group[word] = set()
                    words_group[word].add(vdict['ipid'])
            src['words'][group] = parser.word_dbfilter(words_group, len(set(v['ipid'] for v in values)), src['min_word_num'], 
                src['min_word_percent'], src['max_word_percent'])
            src['ipids'][group] = {}
            for word, idset in src['words'][group].items():
                for id in idset:
                    if id not in src['ipids'][group]:
                        src['ipids'][group][id] = set()
                    src['ipids'][group][id].add(word)

def build_srcgroupword_key(srcid, group, word):
    return str(srcid) + '/' + group + '/' + word

def save_words(db, words, log):
    cur = db.cursor()
    cur.execute(select_info_nnml_word_sql)
    info_words = {build_srcgroupword_key(r[1],r[2],r[3]):r[0] for r in cur.fetchall()}
    vallist = []
    for src in words:
        for group, values in src['words'].items():
            for word in values:
                key = build_srcgroupword_key(src['srcid'], group, word)
                if key not in info_words:
                    vallist.append((src['srcid'], group, word))
    if vallist:
        cur.executemany(insert_info_nnml_word_sql, vallist)
        db.commit()
        cur.execute(select_info_nnml_word_sql)
        info_words = {build_srcgroupword_key(r[1],r[2],r[3]):r[0] for r in cur.fetchall()}
    cur.execute(select_input_typeid_sql.format(omni_config.input_word))
    input_typeid = cur.fetchall()[0][0]
    vallist = []
    for src in words:
        for group, values in src['words'].items():
            for word in values:
                key = build_srcgroupword_key(src['srcid'], group, word)
                vallist.append((input_typeid, info_words[key]))
    if vallist:
        cur.executemany(insert_tmp_nnml_input_sql, vallist)
        db.commit()
    cur.execute(select_tmp_nnml_input.format(str(input_typeid)))
    typemap = {r[0]:r[1] for r in cur.fetchall()}
    vallist = []
    for src in words:
        for group, values in src['words'].items():
            for word, ipset in values.items():
                key = build_srcgroupword_key(src['srcid'], group, word)
                key = typemap[info_words[key]]
                for ipid in ipset:
                    vallist.append((ipid, key, 1.0))
    if vallist:
        cur.executemany(insert_tmp_nnml_ip_input_sql, vallist)
        db.commit()
    cur.close()


def main():
    try:
        exitcode = 1
        program = OmniProgram(omni_config.log_path, omni_config.log_level, omni_config.log_format, omni_config.log_date_format)
        omnidb = OmniDB(omni_config.dbtype, omni_config.dbhost, omni_config.dbname,
            omni_unpwd.db_nnml_user, omni_unpwd.db_nnml_password, log=program.log, program=program.name, ssl=omni_config.dbssl)
        omnidb.run_program_queries(stage=1)
        add_ip_inputs(omnidb, program.log)
        omnidb.run_program_queries(stage=2)
        add_ip_input_values(omnidb, program.log)
        omnidb.run_program_queries(stage=3)
        words = load_words(omnidb, program.log)
        parse_words(words)
        save_words(omnidb, words, program.log)
        for stage in range(10,12):
            omnidb.run_program_queries(stage=stage)
        omnidb.close()
        exitcode = 0
    except:
        program.log.exception('Fatal error')
    finally:
        return exitcode

if __name__ == "__main__":
    sys.exit(main())