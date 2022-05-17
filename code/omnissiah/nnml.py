import pyparsing as pp
import re
from .const import min_nnml_word_length, max_nnml_word_length, nnml_preprocess_regex


class NNMLParser:
    def __init__(self, preprocess_regex=nnml_preprocess_regex):
        self.preprocess_regex = [re.compile(r) for r in preprocess_regex]

    def preprocess_value(self, value):
        new_value = value
        for r in self.preprocess_regex:
            new_value = r.sub('', new_value)
        return new_value

    def postprocess_set(self, words):
        new_words = set()
        for word in words:
            w = word
            if len(word)<min_nnml_word_length:
                continue
            if len(word)>max_nnml_word_length:
                w = word[:max_nnml_word_length]
            new_words.add(w)
        return new_words

    def regex_sub(self, regex, value, newvalue=''):
        result = value
        regex_list = [regex] if isinstance(regex, str) else regex
        for r in regex_list:
            result = re.sub(r, newvalue, result)
        return result

    def regex_findall(self, regex, value):
        regex_list = [regex] if isinstance(regex, str) else regex
        result = ''
        for r in regex_list:
            find_list = re.findall(r, value, re.M)
            for f in find_list:
                result = result + f + ' '
            result = result[:-1] + '\n'
        return result

    def ifparse(self, value):
        interface = ''
        slot = ''
        intnum = ''
        vlan = ''
        slotnum = ''
        find_list = re.findall(r'^.+(\.\d+)$', value)
        if find_list:
            vlan = find_list[0]
        if not vlan:
            find_list = re.findall(r'^.*vlan[^\d]*(\d+)$', value.lower())
            if find_list:
                vlan = '.' + find_list[0]
        find_list = re.findall(r'^(...[^\d]*).*$', value)
        if find_list:
            interface = find_list[0]
            find_list = re.findall(r'^(.*[A-Z,a-z][^\d]+).*$', interface)
            if find_list:
                interface = find_list[0]
        if interface:
            find_list = re.findall(r'^.{' + str(len(interface)) + '}([^\.]+).*$', value)
            if find_list:
                slotnum = find_list[0]
                if slotnum:
                    intnum = slotnum
                    find_list = re.findall(r'^(.+)(/\d+)$', slotnum)
                    if find_list:
                        slot = find_list[0][0]
                        intnum = find_list[0][1]
        slot = '0' + slot if len(slot)==1 else slot
        return interface + ' ' + slot + ' ' + intnum + ' ' + vlan

    def dbregex(self, src_name, group, value):
        result = value
        if src_name[:len('src_scan_script')]=='src_scan_script':
            if group=='http-errors':
                result = self.regex_findall([r'^.*Error Code:[^\d]*(\d+)[^\d]*$', r'^.*http.*:\/\/.*(:\d+\/.*)$'], value)
            elif group=='http-headers':
                result = self.regex_sub([r'Date: .+\n', r'Last-Modified: .+\n', r'Expires=.+;'], value)
            elif group=='http-security-headers':
                result = re.sub(r'Header: Expires:.+\n', '', value)
            elif group=='ssl-cert':
                result = self.regex_sub([r'Not valid before: .+\n', r'Not valid after: .+\n', r'MD5: .+\n', r'SHA-1: .+\n', r'Subject Alternative Name: .+\n'], value)
                result.replace('/', ' /')
            elif group=='ssl-enum-ciphers':
                result = re.sub(r'(\(.+) (.+\))', r'\1_\2', value)
            elif group=='ssh-hostkey':
                result = re.sub(r'\[(.+) (.+)\]', r'\1_\2', value)
                result = self.regex_findall('^.+-([^-]+_[^-]+)-.+$', result)
            elif group=='ssh2-enum-algos':
                result = re.sub(r'\(\d+\)', '', value)
            elif group=='ntp-info':
                result = self.regex_findall('^.*system: (.+)$', value)
            elif group=='snmp-info':
                result = self.regex_findall('^.*enterprise: (.+)$', value)
            elif group=='snmp-netstat':
                result = self.regex_findall('^(.*0\.0\.0\.0.+)$', value)
            elif group=='banner':
                result = re.sub(r'(.*)(\\x[0-9,a-f,A-F][0-9,a-f,A-F])([^\\].*)', r'\1\2 \3', value)
            elif group=='dns-service-discovery':
                result = re.sub(r'(.*Address=.+)', '', value)
            elif group=='mdns-service-discovery':
                result = re.sub(r'(.*Address=.+)', '', value)
            elif group=='sip-methods':
                result = re.sub(r',', ' ', value)
            elif group=='snmp-processes':
                result = re.sub(r'[^\d](\d+):', ' ', value)
            elif group=='ldap-rootdse':
                result = re.sub(r',', ' ', value)
        elif src_name=='src_if_ifdescr' or src_name=='src_if_ifname':
            result = self.ifparse(value)
        elif src_name[:len('src_ip_info')]=='src_ip_info':
            if group=='name' or group=='hostname':
                result = value.replace('.', ' ')
        elif src_name=='src_scan_osclass_cpe':
            find_list = re.findall(r'^(cpe:/.+:\d+)\.*.*$', value)
            if find_list:
                result = find_list[0]
        elif src_name=='src_scan_osmatch':
            result = self.regex_sub([r'(\d+\.)\d+-[A-Z,a-z]+', r'(\d+\.)\d+[A-Z,a-z]+\d+\.\d+', r'(\d+\.)\d+[A-Z,a-z]+\d+', r'(\d+\.)\d+\.\d+', r'(\d+\.)\d+'], value, newvalue=r'\1')
        elif src_name=='src_scan_service_extrainfo':
            result = re.sub(r'(\d+\.\d+)(\.\d+)+', r'\1', value)
        elif src_name=='src_scan_service_cpe':
            result = re.sub(r'(\d+\.)\d+(\.\d+)*', r'\1', result)
            result = re.sub(r'_\d\d[A-Z,a-z]{3}\d{4}', '', result)
            result = result.replace(':', ' ')
        elif src_name=='src_snmp_sysor':
            result = re.sub(r'LAST-UPDATED \d+Z', '', value)
        elif src_name=='src_snmp_system':
            result = self.regex_sub([r'[A-Z,a-z]{3} \d{1,2}-[A-Z,a-z]{3}-\d{2,4}', r'\d{1,2}-[A-Z,a-z]{3}-\d{2,4}', r'[A-Z,a-z]{3} \d\d \d\d\d\d', r'\d{4}-\d{4}'], value)
            result = self.regex_sub([r'(\d+\.)\d+(\.\d+)*[A-Z,a-z,0-9]+', r'(\d+\.)\d+(\.\d+)*'], result, newvalue=r'\1')
        return result

    def dbparse(self, src_name, group, value):
        parser = pp.Word(pp.printables)[0,...]
        words = parser.parse_string(value)
        return set(words)

    def word_dbfilter(self, words, recnum, min_word_number, min_word_number_percent, max_word_number_percent):
        new_words = {}
        for word, idset in words.items():
            idsetlen = len(idset)
            if idsetlen<min_word_number or idsetlen/recnum*100<min_word_number_percent or idsetlen/recnum*100>max_word_number_percent:
                continue
            new_words[word] = idset
        return new_words

    def parse(self, src_name, group, value):
        v = self.dbregex(src_name, group, value)
        v = self.preprocess_value(v)
        words = self.dbparse(src_name, group, v)
        words = self.postprocess_set(words)
        return words
