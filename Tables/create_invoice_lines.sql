CREATE TABLE invoice_lines (
    invoice_num INTEGER REFERENCES invoices_db(invoice_num) ON DELETE CASCADE,
    part_num VARCHAR(30) REFERENCES parts_db(part_num),
    assembly_num BIGINT REFERENCES assemblies(assembly_num),
    revision CHAR(2),
    quantity INTEGER,
    unit_description TEXT,
    unit_price NUMERIC(10,3),
    line_total NUMERIC(10,3)
)