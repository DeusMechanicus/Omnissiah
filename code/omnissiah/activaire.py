import requests
import json
from .const import activaire_api_url, activaire_api_headers

class ActivaireAPI:
    def __init__(self, api_key, api_url=activaire_api_url):
        self.api_url = api_url
        self.headers = activaire_api_headers.copy()
        self.headers['authorizationToken'] = api_key

    def getall(self, doparsing=True):
        r = requests.get(self.api_url, headers=self.headers)
        if r.status_code == 200:
            if doparsing:
                return json.loads(r.text)
            else:
                return r.text
        return None
