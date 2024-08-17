\set table_name 'invoices_db'
\set column_name 'invoice_num'
\set constraint_name 'invoices_db_pkey'
\set sequence_name 'invoices_id_seq'

-- Remove the primary key constraint (if it exists)
ALTER TABLE :table_name
DROP CONSTRAINT IF EXISTS :constraint_name;

-- Create a sequence
CREATE SEQUENCE :sequence_name;

-- Set the default value of the column to use the sequence
ALTER TABLE :table_name
ALTER COLUMN :column_name SET DEFAULT nextval(invoices_id_seq);

-- Re-add the primary key constraint
ALTER TABLE :table_name
ADD CONSTRAINT :constraint_name PRIMARY KEY (:column_name);

/*
-- Optionally, set the sequence value to start from the current maximum value of the column
SELECT setval('employees_employee_id_seq', COALESCE((SELECT MAX(employee_id) FROM employees), 1), FALSE)