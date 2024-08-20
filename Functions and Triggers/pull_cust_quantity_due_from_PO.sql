CREATE OR REPLACE FUNCTION pull_cust_quantity_due_from_PO()
RETURNS TRIGGER AS $$

DECLARE 
 /* po_customer_id INTEGER;
 po_due_date DATE;
 po_quantity INTEGER;
 po_part_num VARCHAR(30);
 po_assembly_num BIGINT;
 description TEXT; */

BEGIN 

IF NEW.part_num IS NOT NULL THEN
	SELECT po.part_num, po.customer_id, po.quantity
	INTO NEW.part_num , NEW.customer_id, NEW.order_quantity
	FROM purchase_orders_db AS po 
	WHERE po.po_num = NEW.purchase_order_num;

END IF;

IF NEW.assembly_num IS NOT NULL THEN
	SELECT po.assembly_num, po.customer_id, po.quantity
	INTO NEW.assembly_num , NEW.customer_id, NEW.order_quantity
	FROM purchase_orders_db AS po 
	WHERE po.po_num = NEW.purchase_order_num;

END IF;


 /* IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.po_num IS DISTINCT FROM OLD.po_num) THEN
 	SELECT po.part_num, po.assembly_num, po.customer_id, po.due_date, po.quantity 
	INTO po_part_num, po_assembly_num, po_customer_id, po_due_date, po_quantity 
	FROM purchase_orders_db AS po
	WHERE po.po_num = NEW.purchase_order_num;

 	NEW.part_num := po_part_num;
 	NEW.assembly_num := po_assembly_num;
 	NEW.customer_id := po_customer_id;
 	NEW.due_date := po_due_date;
 	NEW.order_quantity := po_quantity;

 	IF NEW.part_num IS NOT NULL THEN
	 SELECT p.part_description 
	 INTO NEW. part_description
	 FROM parts_db AS p 
 	 WHERE p.part_num = NEW.part_num;

 	ELSE 
	 SELECT assembly_description
 	 INTO NEW.part_description 
 	 FROM assemblies
	 WHERE assemblies.assembly_num = NEW.assembly_num;
	
 	END IF; */

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION pull_cust_quantity_due_from_PO() IS 'This function pulls the corresponding customer_id , order_quantity, and due_date for a specific PO_num inserted in the a New Sales order.';

CREATE OR REPLACE TRIGGER trigger_PO_info_to_SO
BEFORE INSERT OR UPDATE ON sales_orders_db
FOR EACH ROW
EXECUTE FUNCTION pull_cust_quantity_due_from_PO();

COMMENT ON TRIGGER trigger_PO_info_to_SO ON sales_orders_db IS 'Trigger fires when the user creates a new Sales Order and inputs a customer po_num (from purchase_orders_db).';