CREATE TABLE part_rev_audit (
    operation         char(1) NOT NULL,
    part_num	      varchar(30) NOT NULL,
    part_revision_level char(1) NOT NULL,
    stamp            timestamp NOT NULL,
    change_description     TEXT NOT NULL
/*    user_id         timestamp NOT NULL,
    employee_name         text NOT NULL */
);