CREATE OR REPLACE FUNCTION get_customer_info_for_quote()
RETURNS TRIGGER AS $$

BEGIN

SELECT co.address_street_1, co.address_street_2, co.address_city, co.address_state, co.address_zip
INTO NEW.address_street_1, NEW.address_street_2, NEW.address_city, NEW.address_state, NEW.address_zip
FROM customer_db AS co
WHERE co.customer_name = NEW.customer_name;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_customer_info_for_quote() IS 'This function gets the customer address information to include in the 
quote once a customer is selected.';

CREATE OR REPLACE TRIGGER get_customer_info_for_quote_trigger
BEFORE INSERT ON quotes_db
FOR EACH ROW
EXECUTE FUNCTION get_customer_info_for_quote();

COMMENT ON TRIGGER get_customer_info_for_quote_trigger ON quotes_db IS 'This trigger fires when a customer name is added to the new
quote and pulls all the address information of the customer.';