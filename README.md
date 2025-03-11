**Datasets:**
1. Transaction information from the Land Registry
2. Energy performance and characteristics data
3. 50,000 rows of Exeter addresses

**download_land_registry_data.py**

Uses the requests module to download the latest updates to Land Registry data.

How to run locally:
- `pip install requests`
- `python download_land_registry_data.py`
This will download a CSV file to the 'data' directory.

**query_csvs.sh**

After downloading the AddressBase and EPC data, I deleted the columns that weren't needed and added the files to the 'data' directory as 'addressbase_sample.csv' and 'epc_data.csv'.

The 'query_csvs.sh' script uses PostgreSQL to join and query the tables. It aggregates cost savings on utilities if energy performance were improved as a new 'potential_cost_savings' column, and saves to 'data/joined_table.csv'.

A bash command then removes duplicates and saves to 'data/clean_data.csv', which is used for the Power BI visual.

How to run locally:
- [Download PostgreSQL](https://www.postgresql.org/download/) if needed
- Replace the PG_PASSWORD variable on line 6 to your default 'postgres' user's password
- Run `./query_csvs.sh`
This will create or replace 'data/joined_table.csv' and 'data/clean_data.csv'.