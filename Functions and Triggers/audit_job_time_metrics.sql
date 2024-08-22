CREATE OR REPLACE FUNCTION audit_job_time_metrics()
RETURNS TRIGGER AS $$

BEGIN 

IF (NEW.job_is_confirmed = TRUE) THEN
 IF (NEW.part_num IS NOT NULL) THEN 
	INSERT INTO part_production_time_hist_db (part_num, start_date, job_num)
	VALUES (NEW.part_num, CURRENT_TIMESTAMP, NEW.job_num);

 ELSEIF (NEW.assembly_num IS NOT NULL) THEN
	INSERT INTO assembly_production_time_hist_db (assembly_num, start_date, job_num)
	VALUES (NEW.assembly_num,CURRENT_TIMESTAMP, NEW.job_num);

 ELSE 
	RAISE NOTICE 'Part number or assembly_num do not exist';

 END IF;
END IF;

IF (NEW.is_closed = TRUE) THEN
 IF (NEW.part_num IS NOT NULL) THEN 
	INSERT INTO part_production_time_hist_db (end_date)
	VALUES (CURRENT_TIMESTAMP);

 ELSEIF (NEW.assembly_num IS NOT NULL) THEN
	INSERT INTO assembly_production_time_hist_db (end_date)
	VALUES (CURRENT_TIMESTAMP);
 ELSE
	RAISE NOTICE 'Part number or assembly_num do not exist';
 END IF;
END IF;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION audit_job_time_metrics() IS 'This function audits the time metrics of parts and assemblies when their corresponding job_is_confirmed = TRUE OR is_closed = TRUE and logs the time these actions were taken into part_production_time_hist_db and assembly_production_time_hist_db.';

CREATE OR REPLACE TRIGGER audit_job_time_metrics_trigger
AFTER INSERT OR UPDATE ON jobs_db
FOR EACH ROW 
WHEN (NEW.job_is_confirmed = TRUE or NEW.is_closed = TRUE)
EXECUTE FUNCTION audit_job_time_metrics();

COMMENT ON TRIGGER audit_job_time_metrics_trigger ON jobs_db IS 'This trigger fires when the job_is_confirmed or is_closed fields in jobs_db are updated or inserted into jobs_db.';
