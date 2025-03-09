Datasets:
1. Transaction information from the Land Registry
2. Energy performance and characteristics data
3. 50,000 rows of Exeter addresses

Ideas:
1. Map visual of rental properties that need to improve their energy efficiency by 2028, and the potential annual cost savings on utilities
2. Big data ingestion considerations with Land Registry data


To run bash script:
- Replace the PG_PASSWORD variable on line 6 to your default 'postgres' user's password
- Run `./join_csvs.sh`


To run download_land_registry.py:
- `pip install requests`
- `python download_land_registry.py`