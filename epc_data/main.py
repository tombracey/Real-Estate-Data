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

base_url = 'https://epc.opendatacommunities.org/api/v1/domestic/search'
query_params = {
    'size': 5000,
    'constituency': 'E14000698',
    'property-type': 'flat',
    'from-year': 2021,
    'from-month': 1
    }
encoded_params = urlencode(query_params)

full_url = f'{base_url}?{encoded_params}'

with urllib.request.urlopen(urllib.request.Request(
    full_url, headers=headers)) as response:
    response_body = response.read()
    # print(response_body.decode())
    with open('./epc_data/output.csv', 'wb') as file:
        file.write(response_body)