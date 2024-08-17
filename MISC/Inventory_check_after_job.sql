CREATE OR REPLACE FUNCTION run_inventory_check()
RETURNS TRIGGER AS $$

DECLARE 
 remaining_qty INT;

BEGIN

IF NEW.job_latest_start_date > NOW() OR NEW.job_is_confirmed = TRUE THEN
	IF EXISTS (SELECT 1 FROM jobs_db WHERE part_num=NEW.part_num) THEN 

	SELECT qty_in_stock - NEW.order_quantity INTO remaining_qty
        FROM inventory_parts_db
        WHERE part_num = NEW.part_num;

	IF remaining_qty < 0 THEN
	 RAISE EXCEPTION 'Insuffient stock for job %. Shortfall: % units. Part 	 Number: %', 
         NEW.job_number, remaining_qty, NEW.part_num;

	ELSE 

	UPDATE inventory_parts_db
	SET qty_in_stock = qty_in_stock - NEW.order_quantity, last_updated = NOW()
	WHERE inventory_parts_db.part_num = NEW.part_num;

	END IF;
  END IF;
END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION run_inventory_check() IS 'This function subtracts the order quantity after a job is firmed to the quantity of the part in inventory.';


CREATE TRIGGER trigger_inventory_after_job
AFTER INSERT OR UPDATE ON jobs_db
FOR EACH ROW
EXECUTE FUNCTION run_inventory_check();

COMMENT ON TRIGGER trigger_inventory_after_job ON jobs_db IS 'Trigger fires to check inventory shortage when a Job passes its latest_start_date or when it is confirmed by the user.';