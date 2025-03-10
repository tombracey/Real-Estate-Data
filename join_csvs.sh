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

echo "Importing addressbase data"
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
    UPRN TEXT
);
"

echo "Importing epc data"
psql -U postgres -d "$DB_NAME" -c "\COPY temp_epc_data (LIGHTING_COST_CURRENT,LIGHTING_COST_POTENTIAL,HEATING_COST_CURRENT,HEATING_COST_POTENTIAL,HOT_WATER_COST_CURRENT,HOT_WATER_COST_POTENTIAL,ADDRESS,UPRN) FROM '$EPC_CSV_PATH' DELIMITER ',' CSV HEADER;"

# Joining and exporting
psql -U postgres -d "$DB_NAME" -c "
DROP TABLE IF EXISTS final_table;
CREATE TABLE final_table (
    id SERIAL PRIMARY KEY,  -- 🆕 Auto-incrementing ID
    UKPRN TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    LIGHTING_COST_CURRENT NUMERIC,
    LIGHTING_COST_POTENTIAL NUMERIC,
    HEATING_COST_CURRENT NUMERIC,
    HEATING_COST_POTENTIAL NUMERIC,
    HOT_WATER_COST_CURRENT NUMERIC,
    HOT_WATER_COST_POTENTIAL NUMERIC,
    ADDRESS TEXT
);
INSERT INTO final_table (UKPRN, latitude, longitude, LIGHTING_COST_CURRENT, LIGHTING_COST_POTENTIAL, HEATING_COST_CURRENT, HEATING_COST_POTENTIAL, HOT_WATER_COST_CURRENT, HOT_WATER_COST_POTENTIAL, ADDRESS)
SELECT 
    UKPRN, 
    latitude, 
    longitude, 
    temp_epc_data.LIGHTING_COST_CURRENT, 
    temp_epc_data.LIGHTING_COST_POTENTIAL, 
    temp_epc_data.HEATING_COST_CURRENT, 
    temp_epc_data.HEATING_COST_POTENTIAL, 
    temp_epc_data.HOT_WATER_COST_CURRENT, 
    temp_epc_data.HOT_WATER_COST_POTENTIAL, 
    temp_epc_data.ADDRESS
FROM temp_addressbase
JOIN temp_epc_data ON temp_addressbase.UKPRN = temp_epc_data.UPRN;
"

psql -U postgres -d "$DB_NAME" -c "\COPY final_table TO './data/joined_table.csv' DELIMITER ',' CSV HEADER;"

unset PGPASSWORD

# Remove duplicates
awk -F',' '!seen[$1]++' ./data/joined_table.csv | awk -F',' '!seen[$2","$3]++' > ./data/clean_data.csv
