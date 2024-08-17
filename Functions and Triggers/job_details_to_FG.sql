CREATE FUNCTION job_details_to_FG()
RETURNS TRIGGER AS $$

BEGIN 

 IF (NEW.is_closed = TRUE) THEN 
 INSERT INTO finished_goods_db (job_id, sales_order_id, part_num, part_description)
 VALUES (NEW.job_id, NEW.sales_order_id, NEW.part_num, NEW.part_description);

END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION job_details_to_FG() IS 'This function inserts into finished_goods_db the job_id, sales_order_id, part_num and part_description of a specific job IF jobs_db.is_closed = TRUE - the job is complete.';

CREATE TRIGGER job_details_to_FG_trigger
AFTER UPDATE on jobs_db
FOR EACH ROW
EXECUTE FUNCTION job_details_to_FG();

COMMENT ON TRIGGER job_details_to_FG_trigger ON jobs_db IS 'This trigger fires when the an update is done on jobs_db , it calls the function job_details_to_FG() to move the job to finished goods if jobs_db.is_closed = TRUE.';

