CREATE OR REPLACE FUNCTION get_assembly_part_cost()
RETURNS TRIGGER AS $$

BEGIN

IF 'TG_OP' = 'INSERT' OR 'TG_OP' = UPDATE

SELECT SUM(p.unit_cost * COALESCE(NEW.quantity, OLD.quantity)) INTO NEW.total_cost_per_part
FROM parts_db AS p
WHERE p.part_num = COALESCE(NEW.part_num , OLD.part_num);

RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION get_assembly_part_cost IS 'This function gets the total cost per part (unit_cost * quantity) and inserts it into 
total_cost_per_part in assemby_parts.';

CREATE OR REPLACE TRIGGER get_assembly_part_cost_trigger
BEFORE INSERT OR UPDATE on assembly_parts
FOR EACH ROW
EXECUTE FUNCTION get_assembly_part_cost();

COMMENT ON TRIGGER get_assembly_part_cost_trigger ON assembly_parts IS 'This trigger fires when a new part is inserted, deleted 
or quantity in assembly is modified.';


