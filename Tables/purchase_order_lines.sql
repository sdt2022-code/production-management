CREATE TABLE purchase_order_lines (LIKE sales_orders_lines);

ALTER TABLE purchase_order_lines
RENAME COLUMN so_id TO po_num

ALTER TABLE purchase_order_lines
DROP CONSTRAINT fk_po_num;

ALTER TABLE purchase_order_lines
ADD CONSTRAINT fk_po_num FOREIGN KEY (po_num) REFERENCES purchase_orders_db(po_num) ON DELETE CASCADE;

ALTER TABLE purchase_order_lines
ADD COLUMN customer_part_num VARCHAR(40);


ALTER TABLE purchase_order_lines
ADD CONSTRAINT check_part_or_assembly_not_empty CHECK(part_num IS NOT NULL OR assembly_num IS NOT NULL);

ALTER TABLE purchase_order_lines    
ADD CONSTRAINT check_pos_qty CHECK(quantity>=0);

ALTER TABLE purchase_order_lines
ADD CONSTRAINT fk_part_num_po_exists FOREIGN KEY (part_num) REFERENCES parts_db(part_num);

ALTER TABLE purchase_order_lines
ADD CONSTRAINT fk_assembly_num_po_exists FOREIGN KEY (assembly_num) REFERENCES assemblies(assembly_num);

CREATE TRIGGER get_desc_price_rev_po_info
BEFORE INSERT OR UPDATE ON purchase_order_lines
FOR EACH ROW 
EXECUTE FUNCTION get_desc_price_rev();

COMMENT ON TRIGGER get_desc_price_rev_po_info ON purchase_order_lines IS "This trigger fires before an insert or update operation on purchase_order_lines.";