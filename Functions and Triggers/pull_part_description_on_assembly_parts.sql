CREATE OR REPLACE FUNCTION update_part_description() 
RETURNS TRIGGER AS $$
BEGIN

    SELECT p.part_description, p.part_revision 
    INTO NEW.part_description, NEW.part_revision
    FROM parts_db p
    WHERE p.part_num = NEW.part_num;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_part_description() IS 'This function pulls the part description and revision from parts_db when a new part is added to an assembly.';

CREATE OR REPLACE TRIGGER set_part_description
BEFORE INSERT OR UPDATE ON assembly_parts
FOR EACH ROW
EXECUTE FUNCTION update_part_description();

COMMENT ON TRIGGER set_part_description ON assembly_parts IS 'This trigger fires before a part is inserted into assembly_parts and calls the function update_part_description().';
