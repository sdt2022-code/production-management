CREATE OR REPLACE PROCEDURE single_shortage_procedure(job_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE 

 remaining_qty INTEGER;
 temp_order_quantity INTEGER;
 temp_over_run_quantity INTEGER;
 temp_part_num VARCHAR(30);

BEGIN 

 SELECT j.part_num , j.order_quantity, j.over_run_quantity
 INTO temp_part_num, temp_order_quantity, temp_over_run_quantity
 FROM jobs_db j
 WHERE j.job_id = job_id;


 SELECT i.qty_in_stock - (temp_order_quantity + temp_over_run_quantity) 
 INTO remaining_qty
 FROM inventory_parts_db i
 WHERE i.part_num = temp_part_num;

	IF remaining_qty < 0 THEN

	RAISE EXCEPTION 'Insuffient stock for job %. Shortfall: % units. Part 	 Number: %', 
	NEW.job_number, remaining_qty, NEW.part_num;

	ELSE 

	UPDATE inventory_parts_db
	SET qty_in_stock = qty_in_stock - (temp_qty_table.order_quantity + temp_qty_table.over_run_quantity), last_updated = NOW()
	WHERE part_num = temp_part_num;

	END IF;

END;
$$;