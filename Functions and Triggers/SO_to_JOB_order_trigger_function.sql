CREATE OR REPLACE FUNCTION SO_to_Job_order_insert()
RETURNS TRIGGER AS $$
BEGIN

INSERT INTO jobs_db (sales_oder_id , part_num, order_quantity)
VALUES (NEW.sales_order_id , NEW.part_num, NEW.order_quantity);
RETURN NEW;

END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER after_SO_insert
AFTER INSERT ON sales_orders_db
FOR EACH ROW
EXECUTE FUNCTION SO_to_Job_order_insert()