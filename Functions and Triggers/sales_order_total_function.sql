CREATE OR REPLACE FUNCTION sales_order_total()
RETURNS TRIGGER AS $$

BEGIN 

	UPDATE sales_orders_db
	SET sale_total = (
	 SELECT COALESCE(SUM(line_total), 0)
	 FROM sales_orders_lines 
	 WHERE so_id = COALESCE(NEW.so_id , OLD.so_id)
	 )
	
	WHERE sales_order_id = COALESCE(NEW.so_id, OLD.so_id);

RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION sales_order_total() IS 'This function computes the total of a sales order by summing up the total of
each line corresponding to the sales order.';

CREATE OR REPLACE TRIGGER sales_order_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON sales_orders_lines
FOR EACH ROW
EXECUTE FUNCTION sales_order_total();


COMMENT ON TRIGGER sales_order_total_trigger ON sales_orders_lines IS 'This trigger fires when an insert, update or delete 
is done on the sales_orders_lines and calls the function sales_order_total to update the total of the sales_order.';