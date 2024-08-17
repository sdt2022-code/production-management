CREATE TABLE assembly_production_hist_db(
 id SERIAL PRIMARY KEY, 
 assembly_num BIGINT REFERENCES assemblies (assembly_num),
 start_date TIMESTAMP,
 end_date TIMESTAMP,
 assem_completion_time INTERVAL GENERATED ALWAYS AS (end_date - start_date) STORED
); 