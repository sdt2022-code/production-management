CREATE OR REPLACE FUNCTION create_part_rev_in_audit()
RETURNS TRIGGER AS $$

BEGIN

INSERT INTO part_rev_audit(operation, part_num, part_revision_level, stamp, change_description)
VALUES('I', NEW.part_num,NEW.part_revision, CURRENT_TIMESTAMP, 'Part Created in System');

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_part_rev_in_audit() IS 'This function creates a record in part_rev_audit when a new part is created in the
system and the part revision is provided.';

CREATE OR REPLACE TRIGGER create_part_rev_in_audit_trigger
AFTER INSERT ON parts_db
FOR EACH ROW
WHEN (NEW.part_revision IS NOT NULL)
EXECUTE FUNCTION create_part_rev_in_audit();

COMMENT ON TRIGGER  create_part_rev_in_audit_trigger ON parts_db IS 'This trigger fires when a new part is created and calls the 
function create_part_rev_in_audit.';