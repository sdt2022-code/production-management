CREATE OR REPLACE FUNCTION generate_ass_rev_approve_date()
RETURNS TRIGGER AS $$

BEGIN

 IF (NEW.assembly_rev_approved = TRUE) THEN

    NEW.assembly_approve_rev_date := CURRENT_TIMESTAMP;
--SELECT NOW() INTO COALESCE(NEW.assembly_approve_rev_date , OLD.assembly_approve_rev_date);

 END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_ass_rev_approve_date() IS 'This function updates the asssembly_approve_rev_date if the assembly_rev_approved boolean is set to TRUE.';

CREATE OR REPLACE TRIGGER assembly_rev_approved_trigger
BEFORE INSERT OR UPDATE ON assembly_revision_db
FOR EACH ROW 
--WHEN (OLD.assembly_rev_approved IS DISTINCT FROM NEW.assembly_rev_approved)
EXECUTE FUNCTION generate_ass_rev_approve_date();

COMMENT ON TRIGGER assembly_rev_approved_trigger ON assembly_revision_db IS 'This trigger fires when an update is made on the assembly_revision_db, it calls the function generate_ass_rev_approve_date() to generate the date corresponding to when the revision was approved.';



 