CREATE OR REPLACE FUNCTION split_SO_into_jobs(sales_order_num INTEGER)
RETURNS VOID AS $$

DECLARE 
	due_date_from_so DATE;
	job_due_date DATE;

BEGIN

	SELECT so.due_date INTO due_date_from_so
	FROM sales_orders_db AS so
	WHERE so.sales_order_id = $1;

	job_due_date:=due_date_from_so;

	INSERT INTO jobs_db(sales_order_id, job_due_date, job_part_num, job_assembly_num,
                order_quantity, job_unit_description, job_payout, job_part_or_assembly_revision)
	SELECT so_id, job_due_date, part_num, assembly_num, quantity,unit_description, line_total,revision
	FROM sales_orders_lines
	WHERE so_id = $1;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION split_so_into_jobs(sales_order_num INTEGER) IS 'This function splits a sales order
	with multiple lines into multiple jobs for each line, just by selecting the sales order the user
	wishes to create a job for.';


