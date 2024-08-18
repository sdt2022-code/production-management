CREATE OR REPLACE FUNCTION process_part_rev_audit() RETURNS TRIGGER AS $part_rev_audit$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- making use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO part_rev_audit SELECT 'D', OLD.part_num , OLD.part_revision_level, now(), NULL;

        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO part_rev_audit SELECT 'U', OLD.part_num, OLD.part_revision_level, now(), NEW.change_desciption;

        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO part_rev_audit SELECT 'I', NEW.part_num , NEW.part_revision_level, now(), NEW.change_description;

        END IF;

        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$part_rev_audit$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER part_rev_audit
AFTER INSERT OR UPDATE OR DELETE ON revision_db
    FOR EACH ROW EXECUTE FUNCTION process_part_rev_audit();