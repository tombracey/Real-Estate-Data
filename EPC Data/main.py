import urllib.request
from urllib.parse import urlencode
import os
from dotenv import load_dotenv

load_dotenv()
token = os.getenv("EPC_TOKEN")

headers = {
    'Accept': 'text/csv',
    'Authorization': f'Basic {token}'
}

with urllib.request.urlopen(urllib.request.Request(
    'https://epc.opendatacommunities.org/api/v1/domestic/search', headers=headers)) as response:
    response_body = response.read()
    print(response_body.decode())
    