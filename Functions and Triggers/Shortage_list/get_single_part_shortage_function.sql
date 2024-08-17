CREATE OR REPLACE FUNCTION get_single_part_shortage (specific_job_id INTEGER)
RETURNS TABLE (job_id INTEGER ,part_num VARCHAR, part_description TEXT, qty_in_stock INTEGER, lead_time INTERVAL) 

LANGUAGE plpgsql

AS $$
DECLARE 

 specific_job_quantity INTEGER;

BEGIN

SELECT j.order_quantity + j.over_run_quantity 
INTO specific_job_quantity 
FROM jobs_db AS j 
WHERE j.job_id = specific_job_id;

CREATE TEMPORARY TABLE temp_assembly_stock AS
SELECT 
 j.job_id,
 p.part_num,
 p.part_description,
 i.qty_in_stock,
 p.lead_time
 FROM 
	parts_db AS p
 INNER JOIN 
	inventory_parts_db AS i on p.part_num = i.part_num
 WHERE
	j.job_id = specific_job_id;

-- Update Inventory 

UPDATE inventory_parts_db AS i
SET qty_in_stock = i.qty_in_stock - specific_job_quantity
WHERE i.part_num = (
    SELECT j.part_num
    FROM jobs_db AS j
    WHERE j.job_id = specific_job_id);

RETURN QUERY
SELECT 
 t.job_id,
 t.part_num,
 t.part_description,
 t.qty_in_stock,
 t.lead_time
 FROM 
	temp_assembly_stock t

 INNER JOIN 
	inventory_parts_db AS i on t.part_num = i.part_num
 WHERE
	i.qty_in_stock < 0;

END;
$$;


COMMENT ON FUNCTION get_single_part_shortage (specific_job_id INTEGER) IS 'This function runs a shortage action when the job references a single part and not an assembly (metals, covers, housings...) and it returns the missing quantity of the corresponding part on the job specified by "specific_job_id" in stock if applicable.';



 