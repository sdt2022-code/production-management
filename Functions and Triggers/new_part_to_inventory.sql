CREATE OR REPLACE FUNCTION add_part_to_inventory()
RETURNS TRIGGER AS $$

BEGIN

 INSERT INTO inventory_parts_db(part_num, part_description, qty_in_stock, inventory_tolerance, unit_cost)
 VALUES (NEW.part_num, NEW.part_description, NEW.inventory_total_quantity, NEW.inventory_tolerance, NEW.unit_cost);

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_part_to_inventory IS 'This function inserts into inventory_db the part_num, part_description, qty_in_stock, inventory_tol and unit_cost of a part from parts_db.'; 

CREATE TRIGGER part_created_to_inventory
AFTER INSERT ON parts_db
FOR EACH ROW
EXECUTE FUNCTION add_part_to_inventory();

COMMENT ON TRIGGER part_created_to_inventory ON parts_db IS 'This trigger fires when a new part is created in the system and adds it to inventory, it assumes a stock quantity of 0 if it is not written by the user.';


