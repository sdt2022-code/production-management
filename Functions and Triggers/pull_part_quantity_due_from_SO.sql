CREATE OR REPLACE FUNCTION pull_part_quantity_due_from_SO()
RETURNS TRIGGER AS $$

/*
DECLARE 
 so_part_num VARCHAR(30);
 so_assembly_num BIGINT;
 so_part_description TEXT;
 so_due_date DATE;
 so_quantity INTEGER;

*/

BEGIN 

	SELECT so.due_date INTO NEW.job_due_date 
	FROM sales_orders_db as so
	WHERE so.sales_order_id = NEW.sales_order_id;

 IF EXISTS (SELECT 1 FROM sales_orders_lines
	WHERE so_id = NEW.sales_order_id AND part_num IS NOT NULL) THEN
	
	SELECT sl.part_num, sl.quantity, sl.part_description
 	INTO NEW.part_num, NEW.order_quantity, NEW.part_description
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id;

/*
	SELECT so_part_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

 	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	part_num = so_part_num; */

 ELSE

	SELECT sl.assembly_num, sl.quantity, sl.part_description
 	INTO NEW.assembly_num, NEW.order_quantity, NEW.part_description
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id; 

/*
	SELECT so_assembly_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	assembly_num = so_assembly_num; */

END IF;
RETURN NEW;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION pull_part_quantity_due_from_SO() IS 'This function pulls the corresponding part_num , order_quantity, and due_date for a specific SO_num inserted in the new job creation.';

CREATE OR REPLACE TRIGGER trigger_SO_info_to_Job
BEFORE INSERT OR UPDATE ON jobs_db
FOR EACH ROW
EXECUTE FUNCTION pull_part_quantity_due_from_SO();

COMMENT ON TRIGGER trigger_SO_info_to_Job ON jobs_db IS 'Trigger fires when the user created a new job for a specific sales order.';