CREATE OR REPLACE FUNCTION compute_SO_total ()
RETURNS TRIGGER AS $$

BEGIN 
	NEW.sale_total := unit_price * order_quantity;

RETURN NEW;

END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION compute_SO_total() IS 'This function compute the total sale order price based on the unit_price * total_sale_quantity.';

CREATE TRIGGER before_SO_total_price
BEFORE INSERT OR UPDATE ON sales_orders_db
FOR EACH ROW 
EXECUTE FUNCTION compute_SO_total();

COMMENT ON TRIGGER before_SO_total_price ON sales_orders_db IS 'Triggers when the unit_price and order_quantity is inputted by user in sales_orders_db to populate sale_total field in sales_orders_db.'; 