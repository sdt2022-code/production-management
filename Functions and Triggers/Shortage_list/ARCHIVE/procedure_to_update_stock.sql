CREATE OR REPLACE FUNCTION run_inventory_shortage_check(specific_job_id INTEGER)
RETURNS TABLE (job_id INTEGER ,part_num VARCHAR, part_description TEXT, qty_in_stock INTEGER, lead_time INTERVAL) 
LANGUAGE plpgsql

AS $$

DECLARE

 check_part_num VARCHAR(30);

BEGIN
   IF NEW.is_confirmed = TRUE THEN

   	IF NEW.part_num IS NOT NULL THEN

		RETURN QUERY
		SELECT * FROM get_single_part_shortage(specific_job_id);
	

	ELSEIF NEW.assembly_num IS NOT NULL THEN
	
		RETURN QUERY 
		SELECT * FROM get_shortage_parts(specific_job_id);

	ELSE 
		RAISE NOTICE 'Part and Assembly are both null for job_num % :',specific_job_id;

	
  	END IF;
  END IF;

END;
$$;

COMMENT ON FUNCTION run_inventory_shortage_check(specific_job_id INTEGER) IS 'This function would be triggered by the front-end once the user wants to run a shortage report on a specific job before pushing it to production. The function calls two other functions get_single_part_shortage (specific_job_id) and get_shortage_parts(specific_job_id) and return a table with the parts in shotage for a specific job.';
