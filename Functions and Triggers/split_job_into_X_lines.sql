CREATE OR REPLACE FUNCTION split_job_into_X_lines(sales_order_num INTEGER)
RETURNS VOID AS $$

/*
DECLARE 
 so_part_num VARCHAR(30);
 so_assembly_num BIGINT;
 so_part_description TEXT;
 so_due_date DATE;
 so_quantity INTEGER;

*/
DECLARE


due_date_from_so DATE;
part_number VARCHAR(30);
assembly_number BIGINT;
job_quantity INTEGER;
job_unit_description TEXT;
job_line_total NUMERIC(10,3);
job_revision CHAR(2);

BEGIN 

	SELECT so.due_date INTO due_date_from_so
	FROM sales_orders_db AS so
	WHERE so.sales_order_id = sales_order_num;

    FOR part_number, assembly_number, job_quantity, job_unit_description, job_line_total, job_revision IN 
        SELECT part_num, assembly_num, quantity, unit_description, line_total,revision
        FROM sales_orders_lines
        WHERE so_id = $1

        LOOP
            -- IF part_num IS NOT NULL THEN

                RAISE NOTICE 'Inserting into jobs_db: part_num = %, assembly_num=%, quantity = %', part_number, assembly_number, job_quantity;

                INSERT INTO jobs_db(sales_order_id, job_due_date, part_num, assembly_num, 
                order_quantity, part_description, job_payout, job_part_or_assembly_revision)

                VALUES($1, due_date_from_so, part_number, assembly_number, job_quantity, job_unit_description, job_line_total, job_revision);

            /*ELSEIF line.assembly_num IS NOT NULL THEN

                RAISE NOTICE 'Inserting into jobs_db: assembly_num = %, quantity = %, description=%', line.assembly_num, line.quantity, line.unit_description;

            
                INSERT INTO jobs_db(sales_order_id, job_due_date, 
                order_quantity, part_description, assembly_num, job_payout, job_part_or_assembly_revision)

                VALUES($1, due_date_from_so, line.quantity, line.unit_description, line.assembly_num, line.line_total, line.revision);

            END IF;*/

        END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION split_job_into_X_lines(sales_order_num INTEGER) IS 'This function splits the lines in a sales order into
multiple jobs corresponding to each line.';



SELECT split_job_into_X_lines(17)

SELECT * FROM jobs_db

 

/*
 IF EXISTS (SELECT 1 FROM sales_orders_lines
	WHERE so_id = NEW.sales_order_id AND part_num IS NOT NULL) THEN
	
	SELECT sl.part_num, sl.quantity, sl.unit_description
 	INTO NEW.part_num, NEW.order_quantity, NEW.part_description
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id;


	SELECT so_part_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

 	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	part_num = so_part_num; */
/*
 ELSE

	SELECT sl.assembly_num, sl.quantity, sl.unit_description
 	INTO NEW.assembly_num, NEW.order_quantity, NEW.part_description
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id; 


	SELECT so_assembly_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	assembly_num = so_assembly_num; 

END IF;
RETURN NEW;

END;
$$ LANGUAGE plpgsql;

*/
