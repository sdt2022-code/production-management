CREATE OR REPLACE FUNCTION purchase_order_total()
RETURNS TRIGGER AS $$

BEGIN 

	UPDATE purchase_orders_db
	SET po_total = (
	 SELECT COALESCE(SUM(line_total), 0)
	 FROM purchase_order_lines 
	 WHERE po_num = COALESCE(NEW.po_num , OLD.po_num)
	 )
	
	WHERE po_num = COALESCE(NEW.po_num, OLD.po_num);

RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION purchase_order_total() IS 'This function computes the total of a purchase order by summing up the total of
each line corresponding to the purchase order.';

CREATE OR REPLACE TRIGGER purchase_order_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON purchase_order_lines
FOR EACH ROW
EXECUTE FUNCTION purchase_order_total();


COMMENT ON TRIGGER purchase_order_total_trigger ON purchase_order_lines IS 'This trigger fires when an insert, update or delete 
is done on the purchase_orders_lines and calls the function purchase_order_total to update the total of the purhcase_orders_db.';