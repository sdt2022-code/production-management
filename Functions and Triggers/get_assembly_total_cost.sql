CREATE OR REPLACE FUNCTION get_assembly_total_cost()
RETURNS TRIGGER AS $$

BEGIN 

UPDATE assemblies
SET assembly_total_cost = (SELECT SUM(ap.total_cost_per_part) FROM assembly_parts AS ap WHERE ap.assembly_num = NEW.assembly_num)
WHERE assemblies.assembly_num = NEW.assembly_num;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_assembly_total_cost IS 'This function computes the total cost of an assembly by 
summing up the total cost of all the parts that constitutes it.';

CREATE OR REPLACE TRIGGER get_assembly_total_cost_trigger
AFTER INSERT OR UPDATE ON assembly_parts
FOR EACH ROW
EXECUTE FUNCTION get_assembly_total_cost();

COMMENT ON TRIGGER get_assembly_total_cost_trigger ON assembly_parts IS 'This trigger fires when an update is made
on assembly parts and calls the function get_asssembly_total_cost().';