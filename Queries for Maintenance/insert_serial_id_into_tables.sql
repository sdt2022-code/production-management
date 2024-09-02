
DO $$
DECLARE
    tbl_name TEXT := 'assembly_production_time_hist_db';  -- Replace 'supplier_db' with your table name
    col_name TEXT := 'id';  -- Replace 'supplier_id' with your column name
BEGIN
    EXECUTE format('
        ALTER TABLE %I 
        DROP COLUMN IF EXISTS %I, 
        ADD COLUMN %I SERIAL;', 
        tbl_name, col_name, col_name);
END $$;


-- DROPPING THE CONSTRAINTS
ALTER TABLE parts_db
DROP CONSTRAINT fk_manufacturer_id_name;

ALTER TABLE sales_orders_db
DROP CONSTRAINT sales_orders_db_quote_num_fkey;


-- DROPPING SALES_ORDERS_ID  
ALTER TABLE manufacturers_db
DROP COLUMN manufacturer_id;

ALTER TABLE manufacturers_db
ADD COLUMN manufacturer_id SERIAL PRIMARY KEY; 


-- ADDING CONSTRAINTS AGAIN
ALTER TABLE parts_db
ADD CONSTRAINT fk_manufacturer_id_name FOREIGN KEY (manufacturer_id) REFERENCES manufacturers_db(manufacturer_id);

ALTER TABLE sales_orders_db
ADD CONSTRAINT sales_orders_db_quote_num_fkey FOREIGN KEY (purchase_order_num) REFERENCES  quotes_db(quote_num);







