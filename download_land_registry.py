import requests

url = "http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-monthly-update-new-version.csv"

response = requests.get(url)

with open("./data/pp-monthly-update-new-version.csv", "wb") as file:
    file.write(response.content)
