#!/bin/bash

DB_NAME="exeter_epc_data"
AB_CSV_PATH="./data/addressbase_sample.csv"
EPC_CSV_PATH="./data/epc_data.csv"
PG_PASSWORD="1234"

export PGPASSWORD=$PG_PASSWORD

# Import address data
psql -U postgres -d "$DB_NAME" -c "
DROP TABLE IF EXISTS temp_addressbase;
CREATE TABLE temp_addressbase (
    UKPRN TEXT PRIMARY KEY,
    latitude NUMERIC,
    longitude NUMERIC
);
"

psql -U postgres -d "$DB_NAME" -c "\COPY temp_addressbase (UKPRN, latitude, longitude) FROM '$AB_CSV_PATH' DELIMITER ',' CSV HEADER;"

# Import EPC data
psql -U postgres -d "$DB_NAME" -c "
DROP TABLE IF EXISTS temp_epc_data;
CREATE TABLE temp_epc_data (
    LIGHTING_COST_CURRENT NUMERIC,
    LIGHTING_COST_POTENTIAL NUMERIC,
    HEATING_COST_CURRENT NUMERIC,
    HEATING_COST_POTENTIAL NUMERIC,
    HOT_WATER_COST_CURRENT NUMERIC,
    HOT_WATER_COST_POTENTIAL NUMERIC,
    ADDRESS TEXT,
    UPRN TEXT,
    CURRENT_ENERGY_RATING TEXT,
    TENURE TEXT
);
"

psql -U postgres -d "$DB_NAME" -c "\COPY temp_epc_data (LIGHTING_COST_CURRENT, LIGHTING_COST_POTENTIAL, HEATING_COST_CURRENT, HEATING_COST_POTENTIAL, HOT_WATER_COST_CURRENT, HOT_WATER_COST_POTENTIAL, ADDRESS, UPRN, CURRENT_ENERGY_RATING, TENURE) FROM '$EPC_CSV_PATH' DELIMITER ',' CSV HEADER;"

# Join tables, filter rental properties and save to joined_tables.csv
psql -U postgres -d "$DB_NAME" -c "
DROP TABLE IF EXISTS joined_table;
CREATE TABLE joined_table (
    id SERIAL PRIMARY KEY,
    UKPRN TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    ADDRESS TEXT,
    CURRENT_ENERGY_RATING TEXT,
    potential_cost_savings NUMERIC
);
INSERT INTO joined_table (UKPRN, latitude, longitude, ADDRESS, CURRENT_ENERGY_RATING, potential_cost_savings)
SELECT 
    UKPRN, 
    latitude, 
    longitude, 
    temp_epc_data.ADDRESS,
    temp_epc_data.CURRENT_ENERGY_RATING,
    (temp_epc_data.LIGHTING_COST_CURRENT - temp_epc_data.LIGHTING_COST_POTENTIAL) + 
    (temp_epc_data.HEATING_COST_CURRENT - temp_epc_data.HEATING_COST_POTENTIAL) + 
    (temp_epc_data.HOT_WATER_COST_CURRENT - temp_epc_data.HOT_WATER_COST_POTENTIAL) AS potential_cost_savings
FROM temp_addressbase
JOIN temp_epc_data ON temp_addressbase.UKPRN = temp_epc_data.UPRN
WHERE temp_epc_data.TENURE LIKE 'rent%'
AND temp_epc_data.CURRENT_ENERGY_RATING IN ('F', 'G');
"

psql -U postgres -d "$DB_NAME" -c "\COPY joined_table TO './data/joined_table.csv' DELIMITER ',' CSV HEADER;"

unset PGPASSWORD

# Remove duplicates and save to clean_data.csv
awk -F',' '!seen[$1]++' ./data/joined_table.csv | awk -F',' '!seen[$2","$3]++' > ./data/clean_data.csv
