CREATE OR REPLACE FUNCTION process_assembly_rev_audit() RETURNS TRIGGER AS $assembly_rev_audit$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- making use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO assembly_rev_audit SELECT 'D', OLD.assembly_num , OLD.assembly_revision_lvl, now(), OLD.assembly_rev_description_change;

        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO assembly_rev_audit SELECT 'U', OLD.assembly_num, OLD.assembly_revision_lvl, now(), NEW.assembly_rev_description_change;

        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO assembly_rev_audit SELECT 'I', NEW.assembly_num , NEW.assembly_revision_lvl, now(), NEW.assembly_rev_description_change;

        END IF;

        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$assembly_rev_audit$ LANGUAGE plpgsql;

CREATE TRIGGER assembly_rev_audit
AFTER INSERT OR UPDATE OR DELETE ON assembly_revision_db
    FOR EACH ROW EXECUTE FUNCTION process_assembly_rev_audit();