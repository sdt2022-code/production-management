--DROP FUNCTION  get_shortage_parts(specific_job_id INTEGER)
CREATE OR REPLACE FUNCTION get_shortage_parts(specific_job_id INTEGER)
RETURNS TABLE(
    job_id INTEGER, 
    part_num VARCHAR, 
    part_description TEXT, 
    qty_in_stock INTEGER, 
    lead_time INTERVAL
)
LANGUAGE plpgsql
AS $$

BEGIN 

-- Temp table to store intermediate results 

CREATE TEMPORARY TABLE temp_assembly_stock AS
SELECT 
    $1, 
    ap.assembly_num,
    ap.part_num, 
    ap.part_description, 
    ap.quantity,
    i.qty_in_stock, 
    prt.lead_time
FROM 
    assembly_parts AS ap
INNER JOIN 
    inventory_parts_db AS i ON ap.part_num = i.part_num
--INNER JOIN 
    --jobs_db AS j ON j.part_num = ap.part_num 
INNER JOIN
    parts_db AS prt ON prt.part_num = ap.part_num
WHERE ap.assembly_num = (
    SELECT j.assembly_num
    FROM jobs_db AS j
    WHERE j.job_num = specific_job_id);	

-- Update Inventory

UPDATE inventory_parts_db AS i
SET qty_in_stock = i.qty_in_stock - t.quantity
FROM temp_assembly_stock t
WHERE i.part_num = t.part_num;

RETURN QUERY
SELECT 
    $1, 
    t.part_num, 
    t.part_description, 
    i.qty_in_stock, 
    t.lead_time
FROM 
    temp_assembly_stock t
INNER JOIN 
    inventory_parts_db i ON t.part_num = i.part_num
WHERE 
    i.qty_in_stock < 0;

END;
$$;


COMMENT ON FUNCTION get_shortage_parts(specific_job_id INTEGER) IS 'This function runs a shortage action when the job references an assembly (multiple parts) and it returns the missing quantities - of each part corresponding to the assembly on "specific_job_id" - from stock.';
