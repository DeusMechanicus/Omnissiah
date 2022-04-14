import requests
import json
import warnings
warnings.filterwarnings('ignore', message='Unverified HTTPS request')
from .const import ruckussz_login_url, ruckussz_wap_url, ruckussz_client_url, ruckussz_wap_oper_url, ruckussz_timeout_connection, \
    ruckussz_timeout_getpost, ruckussz_login_headers, ruckussz_login_body, ruckussz_sessionid_cookie


class RuckusSZAPI:
    def __init__(self, ip, username, password, log, login_url=ruckussz_login_url, wap_url=ruckussz_wap_url, client_url=ruckussz_client_url,
        wap_oper_url=ruckussz_wap_oper_url, timeout_connection=ruckussz_timeout_connection, timeout_getpost=ruckussz_timeout_getpost,
        login_headers=ruckussz_login_headers, login_body=ruckussz_login_body, sessionid_cookie=ruckussz_sessionid_cookie):
        self.ip = ip
        self.username = username
        self.password = password
        self.log = log
        self.login_url = login_url
        self.wap_url = wap_url
        self.client_url = client_url
        self.wap_oper_url = wap_oper_url
        self.timeout_connection = timeout_connection
        self.timeout_getpost = timeout_getpost
        self.login_headers = login_headers
        self.login_body = login_body
        self.sessionid_cookie = sessionid_cookie
        self.sessionid = None

    def login(self, username=None, password=None):
        r = requests.post(self.login_url.format(self.ip), verify=False, data=self.login_body.format(username or self.username,
            password or self.password), headers=self.login_headers, timeout=(self.timeout_connection, self.timeout_getpost))
        if r.status_code == 200:
            for c in r.cookies:
                if c.name == self.sessionid_cookie:
                    self.sessionid = c.value
                    return c.value
        return None

    def build_headers(self, sessionid):
        return {'Cookie':self.sessionid_cookie + '=' + sessionid}

    def logout(self):
        try:
            if self.sessionid:
                requests.delete(self.login_url.format(self.ip), verify=False, headers=self.build_headers(self.sessionid),
                    timeout=(self.timeout_connection, self.timeout_getpost))
        except:
            pass
        finally:
            self.sessionid = None

    def get_waps(self):
        waps = []
        headers = self.build_headers(self.sessionid)
        r = requests.get(self.wap_url.format(self.ip, 0), verify=False, headers=headers,
            timeout=(self.timeout_connection, self.timeout_getpost))
        if r.status_code == 200:
            data = json.loads(r.text)
            nwap = data['totalCount']
            r = requests.get(self.wap_url.format(self.ip, nwap+1), verify=False, headers=headers,
                timeout=(self.timeout_connection, self.timeout_getpost))
            if r.status_code == 200:
                return json.loads(r.text)['list']
        return []

    def get_wap_operational(self, mac):
        r = requests.get(self.wap_oper_url.format(self.ip, mac), verify=False, headers=self.build_headers(self.sessionid),
            timeout=(self.timeout_connection, self.timeout_getpost))
        if r.status_code == 200:
            return json.loads(r.text)
        return None

