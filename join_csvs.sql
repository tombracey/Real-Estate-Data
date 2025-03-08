CREATE TEMP TABLE temp_addressbase (
    UKPRN TEXT PRIMARY KEY,
    address_line1 TEXT,
    city TEXT,
    postcode TEXT
);

COPY temp_addressbase (UKPRN, address_line1, city, postcode)
FROM 'data/addressbase_sample.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM temp_addressbase LIMIT 5;
