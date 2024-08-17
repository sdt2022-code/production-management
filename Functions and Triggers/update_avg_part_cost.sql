CREATE OR REPLACE FUNCTION update_avg_part_cost()
RETURNS TRIGGER AS $$

DECLARE 
 avg_part_cost NUMERIC (10,3);

BEGIN
 IF NEW.qty_in_stock > OLD.qty_in_stock THEN
 avg_part_cost = (OLD.qty_in_stock * OLD.unit_cost + (NEW.qty_in_stock - OLD.qty_in_stock) * NEW.unit_cost) / NEW.qty_in_stock;

 UPDATE inventory_parts_db
 SET unit_cost = avg_part_cost 
 WHERE NEW.part_num = OLD.part_num;

 END IF;
RETURN NEW;
END;

$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_avg_part_cost() IS 'This function is a running average for part_costs when a new part is added to inventory. It take the quantity, unit_cost and updates the average cost of the corresponding part.';

CREATE TRIGGER update_avg_part_cost_trigger
AFTER UPDATE ON inventory_parts_db
FOR EACH ROW
EXECUTE FUNCTION update_avg_part_cost();

COMMENT ON TRIGGER update_avg_part_cost_trigger ON inventory_parts_db IS 'This trigger fires when the quantity of a part in inventory_parts_db increases (reorder / refill).';
