CREATE OR REPLACE FUNCTION add_to_inventory(target_part_num VARCHAR , additional_quantity INTEGER)
RETURNS VOID AS $$

BEGIN
    UPDATE inventory_parts_db
    SET qty_in_stock = qty_in_stock + additional_quantity , last_updated = NOW()
    WHERE part_num = target_part_num;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_to_inventory(target_part_num VARCHAR, additional_quantity INTEGER) IS 'This function adds a specific
quantity to a part in inventory.'