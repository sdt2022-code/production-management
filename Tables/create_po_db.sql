CREATE TABLE purchase_order_db (
 po_num SERIAL PRIMARY KEY,
 customer_id INTEGER,
 assembly_num BIGINT,
 po_date DATE,
 terms VARCHAR(10),
 CONSTRAINT fk_customer_is_exists FOREIGN KEY (customer_id) REFERENCES customer_db (customer_id),
 CONSTRAINT fk_assembly_num FOREIGN KEY (assembly_num) REFERENCES assemblies (assembly_num)
);
