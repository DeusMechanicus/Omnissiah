import requests
import json
from .const import enplug_api_url, enplug_control_url, enplug_post_headers, enplug_post_payload

class EnplugAPI:
    def __init__(self, networkid, bearer, api_url=enplug_api_url):
        self.api_url = api_url
        self.post_headers = enplug_post_headers.copy()
        self.post_headers['Authorization'] = self.post_headers['Authorization'].format(bearer)
        self.post_payload = enplug_post_payload.copy()
        self.post_payload['NetworkId'] = networkid

    def getall(self, doparsing=True):
        r = requests.post(self.api_url, data=json.dumps(self.post_payload), headers=self.post_headers)
        if r.status_code == 200:
            if doparsing:
                return json.loads(r.text)
            else:
                return r.text
        return None
