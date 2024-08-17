CREATE OR REPLACE FUNCTION avg_part_time_computation()
RETURNS TRIGGER AS $$

BEGIN 

IF (NEW.start_date IS NOT NULL AND NEW.end_date IS NOT NULL) THEN
  UPDATE parts_db
  SET avg_time_to_complete = (
  SELECT AVG(NEW.part_completion_time)
  FROM part_production_time_hist_db
  WHERE part_num = NEW.part_num
  AND id<NEW.id)
  WHERE part_num = NEW.part_num;

END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION avg_part_time_computation() IS 'This function computes the average time taken to complete one specific part (from part_production_time_hist_db) and update the corresponding field in parts_db.';

CREATE OR REPLACE TRIGGER avg_part_time_computation_trigger
AFTER INSERT OR UPDATE ON part_production_time_hist_db
FOR EACH ROW 
WHEN (NEW.end_date IS NOT NULL)
EXECUTE FUNCTION avg_part_time_computation();

COMMENT ON TRIGGER avg_part_time_computation_trigger ON part_production_time_hist_db IS 'This trigger fires when the end_date in part_production_time_hist_db is TRUE and calls the function avg_part_time_computation().';