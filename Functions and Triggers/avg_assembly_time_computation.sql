CREATE OR REPLACE FUNCTION avg_assembly_time_computation()
RETURNS TRIGGER AS $$

BEGIN 

IF (NEW.start_date IS NOT NULL AND NEW.end_date IS NOT NULL) THEN
  UPDATE assemblies
  SET avg_time_to_complete = (
  SELECT AVG(NEW.assem_completion_time)
  FROM assembly_production_time_hist_db
  WHERE assembly_num = NEW.assembly_num
  AND id<NEW.id)
  WHERE assembly_num = NEW.assembly_num;

END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION avg_assembly_time_computation() IS 'This function computes the average time taken to complete one specific assembly (from assembly_production_time_hist_db) and update the corresponding field in assemblies table.';

CREATE OR REPLACE TRIGGER avg_assembly_time_computation_trigger
AFTER INSERT OR UPDATE ON assembly_production_time_hist_db
FOR EACH ROW 
WHEN (NEW.end_date IS NOT NULL)
EXECUTE FUNCTION avg_assembly_time_computation();

COMMENT ON TRIGGER avg_assembly_time_computation_trigger ON assembly_production_time_hist_db IS 'This trigger fires when the end_date in assembly_production_time_hist_db is TRUE and calls the function avg_assembly_time_computation().';