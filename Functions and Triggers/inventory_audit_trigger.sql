CREATE OR REPLACE FUNCTION audit_inventory()
RETURNS TRIGGER AS $$

BEGIN 
	IF NEW.qty_in_stock > OLD.qty_in_stock THEN
	
	INSERT INTO inventory_audit (part_num, transaction_date, qty_added, qty_removed, part_action) VALUES (NEW.part_num, NOW(), NEW.qty_in_stock - OLD.qty_in_stock, NULL, NULL);
	
	ELSE
	INSERT INTO inventory_audit(part_num, transaction_date, qty_added, qty_removed, part_action) VALUES (NEW.part_num, NOW(), OLD.qty_in_stock - NEW.qty_in_stock, NULL, NULL);

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION audit_inventory() IS 'This function audits material in and material out of inventory along with dates. It inserts any new transaction in the inventory_audit table.';

CREATE OR REPLACE TRIGGER inventory_audit_trigger
AFTER UPDATE ON inventory_parts_db
FOR EACH ROW 
EXECUTE FUNCTION audit_inventory();

COMMENT ON TRIGGER inventory_audit_trigger ON inventory_parts_db IS 'This trigger fires when the inventory_parts_db is updated. Its goal is to monitor and audit material flow and store transactions in inventory_audit.';



 