CREATE TABLE sales_orders_lines(
    line_id SERIAL PRIMARY KEY,
    so_id INTEGER REFERENCES sales_orders_db(sales_order_id) ON DELETE CASCADE,
    part_num VARCHAR(30) REFERENCES parts_db(part_num),
    assembly_num BIGINT REFERENCES assemblies(assembly_num),
    quantity INTEGER,
    revision CHAR(2),
    unit_description TEXT,
    unit_price numeric(10,3),
    line_total NUMERIC(10,3) GENERATED ALWAYS AS (unit_price * quantity) STORED,
    CHECK (part_num IS NOT NULL OR assembly_num IS NOT NULL),
    CHECK (quantity >= 0)
);