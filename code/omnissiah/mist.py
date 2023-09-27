import requests
import json
import time
import warnings
warnings.filterwarnings('ignore', message='Unverified HTTPS request')
from .const import mist_timeout_connection, mist_timeout_getpost, mist_authorization_header, mist_self_url, mist_inventory_url, mist_sites_url, mist_clients_url, mist_host, \
mist_devices_url, mist_get_repeat, mist_get_pause


class MistAPI:
    def __init__(self, token, log, timeout_connection=mist_timeout_connection, timeout_getpost=mist_timeout_getpost, authorization_header=mist_authorization_header,
        self_url=mist_self_url, inventory_url=mist_inventory_url, sites_url=mist_sites_url, clients_url=mist_clients_url, host=mist_host, devices_url=mist_devices_url,
        get_repeat=mist_get_repeat, get_pause=mist_get_pause):
        self.token = token
        self.log = log
        self.timeout_connection = timeout_connection
        self.timeout_getpost = timeout_getpost
        self.authorization_header = authorization_header
        self.self_url = self_url
        self.inventory_url = inventory_url
        self.sites_url = sites_url
        self.clients_url = clients_url
        self.host = host
        self.devices_url = devices_url
        self.get_repeat=get_repeat
        self.get_pause=get_pause
        self.orgid = None

    def build_headers(self):
        return {'Authorization':self.authorization_header.format(self.token)}

    def get(self, url):
        for i in range(self.get_repeat):
            try:
                r = requests.get(url, verify=False, headers=self.build_headers(),
                    timeout=(self.timeout_connection, self.timeout_getpost))
                if r.status_code == 200:
                    return json.loads(r.text)
            except:
                pass
            time.sleep(self.get_pause)
        return None

    def getself(self):
        return self.get(self.self_url.format(self.host))

    def getinventory(self):
        return self.get(self.inventory_url.format(self.host, self.orgid))

    def getsites(self):
        return self.get(self.sites_url.format(self.host, self.orgid))

    def getclients(self, siteid):
        return self.get(self.clients_url.format(self.host, siteid))

    def getdevices(self, siteid):
        return self.get(self.devices_url.format(self.host, siteid))

    def get_allclients(self, sites):
        clients = []
        for site in sites:
            clients += self.getclients(site['id'])
        return clients

    def get_alldevices(self, sites):
        devices = []
        for site in sites:
            devices += self.getdevices(site['id'])
        return devices

