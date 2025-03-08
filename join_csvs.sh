#!/bin/bash

DB_NAME="exeter_epc_data"
CSV_PATH="./data/addressbase_sample.csv"
PG_PASSWORD="1234"

export PGPASSWORD=$PG_PASSWORD

psql -U postgres -d "$DB_NAME" -c "
DROP TABLE IF EXISTS temp_addressbase;
CREATE TABLE temp_addressbase (
    UKPRN TEXT PRIMARY KEY,
    latitude NUMERIC,
    longitude NUMERIC
);
"

echo "Importing CSV..."
psql -U postgres -d "$DB_NAME" -c "\COPY temp_addressbase (UKPRN, latitude, longitude) FROM '$CSV_PATH' DELIMITER ',' CSV HEADER;"

psql -U postgres -d "$DB_NAME" -c "SELECT * FROM temp_addressbase LIMIT 5;"

unset PGPASSWORD
