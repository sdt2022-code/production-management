CREATE OR REPLACE FUNCTION add_to_inventory(target_part_num VARCHAR , additional_quantity INTEGER, new_unit_cost NUMERIC(10,3))
RETURNS VOID AS $$

BEGIN
    UPDATE inventory_parts_db
    SET qty_in_stock = qty_in_stock + additional_quantity , last_updated = NOW(), unit_cost = (unit_cost + new_unit_cost)/2
    WHERE part_num = target_part_num;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_to_inventory(target_part_num VARCHAR, additional_quantity INTEGER) IS 'This function adds a specific
quantity to a part in inventory and udptes the unit_cost of the part to be the average.'