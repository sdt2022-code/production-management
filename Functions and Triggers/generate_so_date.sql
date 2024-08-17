CREATE OR REPLACE FUNCTION generate_so_date()
RETURNS TRIGGER AS $$

BEGIN 

 UPDATE sales_orders_db
 SET so_order_date = NOW()
 WHERE sales_order_id = NEW.sales_order_id;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_so_date() IS 'Function that automatically generates the date when a new sales order is created.';

CREATE OR REPLACE TRIGGER trigger_so_date
AFTER INSERT ON sales_orders_db
FOR EACH ROW
EXECUTE FUNCTION generate_so_date();

COMMENT ON TRIGGER trigger_so_date ON sales_orders_db IS 'Trigger fires to automatically generate date of a SO once it is created.';
