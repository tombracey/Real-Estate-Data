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

echo "Importing CSV..."
psql -U postgres -d "$DB_NAME" -c "\COPY temp_addressbase (UKPRN, latitude, longitude) FROM '$AB_CSV_PATH' DELIMITER ',' CSV HEADER;"

# psql -U postgres -d "$DB_NAME" -c "SELECT * FROM temp_addressbase LIMIT 5;"

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

echo "Importing epc_data.csv..."
psql -U postgres -d "$DB_NAME" -c "\COPY temp_epc_data (LIGHTING_COST_CURRENT,LIGHTING_COST_POTENTIAL,HEATING_COST_CURRENT,HEATING_COST_POTENTIAL,HOT_WATER_COST_CURRENT,HOT_WATER_COST_POTENTIAL,ADDRESS,UPRN) FROM '$EPC_CSV_PATH' DELIMITER ',' CSV HEADER;"

# psql -U postgres -d "$DB_NAME" -c "SELECT * FROM temp_epc_data LIMIT 5;"


# Joining them

psql -U postgres -d "$DB_NAME" -c "
DROP TABLE IF EXISTS final_table;
CREATE TABLE final_table AS
SELECT a.UKPRN, a.latitude, a.longitude, e.LIGHTING_COST_CURRENT, e.LIGHTING_COST_POTENTIAL, e.HEATING_COST_CURRENT, e.HEATING_COST_POTENTIAL, e.HOT_WATER_COST_CURRENT, e.HOT_WATER_COST_POTENTIAL, e.ADDRESS
FROM temp_addressbase a
JOIN temp_epc_data e ON a.UKPRN = e.UPRN;
"

# psql -U postgres -d "$DB_NAME" -c "SELECT * FROM final_table LIMIT 5;"


unset PGPASSWORD