CREATE OR REPLACE FUNCTION create_assembly_rev_in_audit()
RETURNS TRIGGER AS $$

BEGIN

INSERT INTO assembly_rev_audit(operation, assembly_num, assembly_revision_level, stamp, assembly_rev_description_change)
VALUES('I', NEW.assembly_num, NEW.assembly_revision, CURRENT_TIMESTAMP, 'Assembly Created in System');

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_assembly_rev_in_audit() IS 'This function creates a record in assembly_rev_audit when a new assembly is created in the
system and the assembly revision is provided.';

CREATE OR REPLACE TRIGGER create_assembly_rev_in_audit_trigger
AFTER INSERT ON assemblies
FOR EACH ROW
WHEN (NEW.assembly_revision IS NOT NULL)
EXECUTE FUNCTION create_assembly_rev_in_audit();

COMMENT ON TRIGGER  create_assembly_rev_in_audit_trigger ON assemblies IS 'This trigger fires when a new assembly is created and calls the 
function create_assembly_rev_in_audit if the assembly revision is provided upon part creation.';