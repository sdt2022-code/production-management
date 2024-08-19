CREATE OR REPLACE FUNCTION update_total_assembly_cost()
RETURNS TRIGGER
AS $$

DECLARE
	 total_cost NUMERIC(10,3) :=0;
BEGIN

SELECT SUM(ap.total_cost_per_part) INTO total_cost
FROM assembly_parts AS ap
WHERE assembly_num = COALESCE(NEW.assembly_num , OLD.assembly_num);

UPDATE assemblies
SET assembly_total_cost = total_cost
WHERE assembly_num = COALESCE(NEW.assembly_num , OLD.assembly_num);

/*
 SELECT SUM (p.unit_cost * NEW.quantity) INTO total_cost
 FROM parts_db p
 JOIN assembly_parts ap ON p.part_num = ap.part_num
 WHERE ap.assembly_num = NEW.assembly_num;

 UPDATE assemblies
 SET assembly_total_cost = total_cost 
 WHERE assembly_num = COALESCE(NEW.assembly_num, OLD.assembly_num);

 */

RETURN NEW;
END;
$$LANGUAGE plpgsql;



COMMENT ON FUNCTION update_total_assembly_cost()
    IS 'This function updates the total assembly cost in assemblies database based on the 
    parts included and the quantity of each included in the respective assembly num.';


CREATE OR REPLACE TRIGGER after_assembly_parts_update
    AFTER INSERT OR UPDATE OR DELETE
    ON assembly_parts
    FOR EACH ROW
    EXECUTE FUNCTION update_total_assembly_cost();

COMMENT ON TRIGGER after_assembly_parts_update ON assembly_parts
    IS 'This triggers when an update or insert of a new parts has be done on the assembly_parts tables.';
