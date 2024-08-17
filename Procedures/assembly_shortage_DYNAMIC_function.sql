CREATE OR REPLACE FUNCTION asesmbly_parts_shortage_function (job_id INTEGER)
RETURNS VOID 
LANGUAGE plpgsql
AS $$

DECLARE
 table_name TEXT;
BEGIN

   BEGIN;
   
   - construct the dynamic table 
   table_name :='material_shortage_' || job_id;


   --Create table dynamically
   EXECUTE 'CREATE TABLE IF NOT EXISTS ' || table_name || ' (
	job_id INTEGER,
	part_num VARCHAR (30)
	part_description TEXT,
	qty_in_stock INTEGER,
	lead_time INTERVAL
	)';

   EXECUTE 'INSERT INTO' || table_name || ' job_id , part_num, part_description, qty_in_stock,lead_time)
	SELECT ' || job_id || ', ap.part_num, ap.part_description, i.qty_in_stock, p.lead_time
	FROM assembly_parts AS ap
	INNER JOIN inventory_parts_db AS i ON ap.part_num = i.part_num
	INNER JOIN parts_db AS p ON p.part_num = ap.part_num
	WHERE ap.assembly_num = ' || job_id;

   -- commit the transaction if everything is succesful 
   COMMIT;

EXCEPTION

	WHEN OTHERS THEN 
		ROLLBACK;
		RAISE;
END;
$$;
