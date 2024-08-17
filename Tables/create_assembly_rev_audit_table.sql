CREATE TABLE assembly_rev_audit (
    operation         char(1) NOT NULL,
    assembly_num	      bigint NOT NULL,
    assembly_revision_lvl char(2) NOT NULL,
    stamp            timestamp NOT NULL,
    assembly_rev_description_change   TEXT NOT NULL
/*    user_id         timestamp NOT NULL,
    employee_name         text NOT NULL */
);
