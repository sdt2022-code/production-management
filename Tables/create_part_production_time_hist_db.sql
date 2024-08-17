CREATE TABLE part_production_hist_db(
 id SERIAL PRIMARY KEY, 
 part_num VARCHAR(30) REFERENCES parts_db (part_num),
 start_date TIMESTAMP,
 end_date TIMESTAMP,
 part_completion_time INTERVAL GENERATED ALWAYS AS (end_date - start_date) STORED
); 