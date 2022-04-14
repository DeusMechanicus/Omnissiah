import requests
import json
import warnings
warnings.filterwarnings('ignore', message='Unverified HTTPS request')
from .const import mist_login_url, mist_logout_url, mist_timeout_connection, mist_timeout_getpost, mist_sessionid_cookie, \
    mist_csrftoken_cookie, mist_login_headers, mist_login_body, mist_cookie_headers, mist_self_url, mist_inventory_url, \
    mist_sites_url, mist_clients_url, mist_host, mist_devices_url


class MistAPI:
    def __init__(self, username, password, log, login_url=mist_login_url, logout_url=mist_logout_url, timeout_connection=mist_timeout_connection,
        timeout_getpost=mist_timeout_getpost, sessionid_cookie=mist_sessionid_cookie, csrftoken_cookie=mist_csrftoken_cookie,
        login_headers=mist_login_headers, login_body=mist_login_body, cookie_headers=mist_cookie_headers, self_url=mist_self_url,
        inventory_url=mist_inventory_url, sites_url=mist_sites_url, clients_url=mist_clients_url, host=mist_host, devices_url=mist_devices_url):
        self.username = username
        self.password = password
        self.log = log
        self.login_url = login_url
        self.logout_url = logout_url
        self.timeout_connection = timeout_connection
        self.timeout_getpost = timeout_getpost
        self.sessionid_cookie = sessionid_cookie
        self.csrftoken_cookie = csrftoken_cookie
        self.login_headers = login_headers
        self.login_body = login_body
        self.cookie_headers = cookie_headers
        self.self_url = self_url
        self.inventory_url = inventory_url
        self.sites_url = sites_url
        self.clients_url = clients_url
        self.host = host
        self.devices_url = devices_url
        self.orgid = None

    def login(self, host=None, username=None, password=None):
        self.sessionid = None
        self.csrftoken = None
        r = requests.post(self.login_url.format(host or self.host), verify=False, data=self.login_body.format(username or self.username,
                password or self.password), headers=self.login_headers, timeout=(self.timeout_connection, self.timeout_getpost))
        if r.status_code == 200:
            for c in r.cookies:
                if c.name == self.sessionid_cookie:
                    self.sessionid = c.value
                elif c.name == self.csrftoken_cookie:
                    self.csrftoken = c.value
        return self.sessionid, self.csrftoken

    def build_headers(self, sessionid=None, csrftoken=None):
        return {'Cookie':self.cookie_headers.format(sessionid or self.sessionid, csrftoken or self.csrftoken)}

    def logout(self, host=None, sessionid=None, csrftoken=None):
        try:
            requests.post(self.logout_url.format(host or self.api_host), verify=False, data='',
                headers=self.build_headers(sessionid or self.sessionid, csrftoken or self.csrftoken),
                timeout=(self.timeout_connection, self.timeout_getpost))
        except:
            pass
        finally:
            self.sessionid = None
            self.csrftoken = None

    def get(self, url, sessionid=None, csrftoken=None):
        r = requests.get(url, verify=False, headers=self.build_headers(sessionid or self.sessionid, csrftoken or self.csrftoken),
            timeout=(self.timeout_connection, self.timeout_getpost))
        if r.status_code == 200:
            return json.loads(r.text)
        return None

    def getself(self, host=None, sessionid=None, csrftoken=None):
        return self.get(self.self_url.format(host or self.host), sessionid, csrftoken)

    def getinventory(self, orgid=None, host=None, sessionid=None, csrftoken=None):
        return self.get(self.inventory_url.format(host or self.host, orgid or self.orgid), sessionid, csrftoken)

    def getsites(self, orgid=None, host=None, sessionid=None, csrftoken=None):
        return self.get(self.sites_url.format(host or self.host, orgid or self.orgid), sessionid, csrftoken)

    def getclients(self, siteid, host=None, sessionid=None, csrftoken=None):
        return self.get(self.clients_url.format(host or self.host, siteid), sessionid, csrftoken)

    def getdevices(self, siteid, host=None, sessionid=None, csrftoken=None):
        return self.get(self.devices_url.format(host or self.host, siteid), sessionid, csrftoken)

    def get_allclients(self, sites, host=None, sessionid=None, csrftoken=None):
        clients = []
        for site in sites:
            clients += self.getclients(site['id'], host, sessionid, csrftoken)
        return clients

    def get_alldevices(self, sites, host=None, sessionid=None, csrftoken=None):
        devices = []
        for site in sites:
            devices += self.getdevices(site['id'], host, sessionid, csrftoken)
        return devices

