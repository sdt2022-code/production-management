CREATE TABLE quote_lines (
 line_id SERIAL PRIMARY KEY, 
 quote_num INTEGER REFERENCES quotes_db (quote_num) ON DELETE CASCADE,
 part_num VARCHAR(30) REFERENCES parts_db(part_num),
 assembly_num BIGINT REFERENCES assemblies(assembly_num),
 quantity INT NOT NULL, 
 unit_price NUMERIC(10,3) NOT NULL, 
 line_total NUMERIC (10,3) GENERATED ALWAYS AS (quantity * unit_price) STORED,
 CHECK (part_num IS NOT NULL OR assembly_num IS NOT NULL)
);
 