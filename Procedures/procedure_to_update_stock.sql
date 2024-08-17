CREATE OR REPLACE FUNCTION run_inventory_check(specific_job_id INTEGER)
RETURNS TABLE (job_id INTEGER ,part_num VARCHAR, part_description TEXT, qty_in_stock INTEGER, lead_time INTERVAL) 
LANGUAGE plpgsql

AS $$

DECLARE

 check_part_num VARCHAR(30);

BEGIN
   SELECT j.part_num INTO check_part_num FROM jobs_db AS j WHERE j.job_id = specific_job_id;

	IF EXISTS (SELECT 1 FROM jobs_db WHERE part_num=check_part_num) THEN 

	RETURN QUERY
	SELECT * FROM get_single_part_shortage(specific_job_id INTEGER);
	

	ELSE
	
	RETURN QUERY 
	SELECT * FROM get_shortage_parts(specific_job_id INTEGER);

	
  	END IF;

END;
$$;
