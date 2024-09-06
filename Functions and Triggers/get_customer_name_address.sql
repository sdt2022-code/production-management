CREATE OR REPLACE FUNCTION get_customer_id_name_address_from_SO()
RETURNS TRIGGER AS $$

BEGIN 


SELECT so.customer_id INTO NEW.customer_id
FROM sales_orders_db AS so
WHERE sales_order_id = NEW.sales_order_id;


SELECT c.customer_name , c.address_street_1, c.address_street_2, c.address_city, c.address_state, c.address_zip
INTO NEW.customer_name , NEW.address_street_1, NEW.address_street_2, NEW.address_city, NEW.address_state, NEW.address_zip
FROM customer_db AS c
WHERE customer_id = NEW.customer_id;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_customer_id_name_address_from_SO() IS 'This function gets the customer_id from sales_orders_db, and then
the customer name and customer_billing Address from the customer_db to populate the corresponding invoice_fields.';

CREATE OR REPLACE TRIGGER get_customer_name_address_trigger
BEFORE INSERT ON invoices_db
FOR EACH ROW
EXECUTE FUNCTION get_customer_id_name_address_from_SO();

COMMENT ON TRIGGER get_customer_name_address_trigger ON invoices_db IS 'This trigger fires before an insert into the 
invoices_db, and calls the function get_customer_id_name_address_from SO.';