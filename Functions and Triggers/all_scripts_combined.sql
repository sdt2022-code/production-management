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
EXECUTE FUNCTION SO_to_Job_order_insert()CREATE OR REPLACE FUNCTION add_to_inventory(target_part_num VARCHAR , additional_quantity INTEGER, new_unit_cost NUMERIC(10,3))
RETURNS VOID AS $$

BEGIN
    UPDATE inventory_parts_db
    SET qty_in_stock = qty_in_stock + additional_quantity , last_updated = NOW(), unit_cost = (unit_cost + new_unit_cost)/2
    WHERE part_num = target_part_num;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_to_inventory(target_part_num VARCHAR, additional_quantity INTEGER) IS 'This function adds a specific
quantity to a part in inventory and udptes the unit_cost of the part to be the average.'CREATE OR REPLACE FUNCTION audit_job_time_metrics()
RETURNS TRIGGER AS $$

BEGIN 

IF (NEW.job_is_confirmed = TRUE) THEN
 IF (NEW.part_num IS NOT NULL) THEN 
	INSERT INTO part_production_time_hist_db (part_num, start_date, job_num)
	VALUES (NEW.part_num, CURRENT_TIMESTAMP, NEW.job_num);

 ELSEIF (NEW.assembly_num IS NOT NULL) THEN
	INSERT INTO assembly_production_time_hist_db (assembly_num, start_date, job_num)
	VALUES (NEW.assembly_num,CURRENT_TIMESTAMP, NEW.job_num);

 ELSE 
	RAISE NOTICE 'Part number or assembly_num do not exist';

 END IF;


ELSEIF (NEW.is_closed = TRUE) THEN

 IF (NEW.part_num IS NOT NULL) THEN 

	UPDATE part_prodcution_time_hist_db
	SET end_date = CURRENT_TIMESTAMP
	WHERE part_num = NEW.part_num;


	--INSERT INTO part_production_time_hist_db (end_date)
	--VALUES (CURRENT_TIMESTAMP);

 ELSEIF (NEW.assembly_num IS NOT NULL) THEN

 	UPDATE assembly_production_time_hist_db
	SET end_date = CURRENT_TIMESTAMP
	WHERE assembly_num = NEW.assembly_num;

	--INSERT INTO assembly_production_time_hist_db (end_date)
	--VALUES (CURRENT_TIMESTAMP);
 ELSE
	RAISE NOTICE 'Part number or assembly_num do not exist';
 END IF;
END IF;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION audit_job_time_metrics() IS 'This function audits the time metrics of parts and assemblies when their corresponding job_is_confirmed = TRUE OR is_closed = TRUE and logs the time these actions were taken into part_production_time_hist_db and assembly_production_time_hist_db.';

CREATE OR REPLACE TRIGGER audit_job_time_metrics_trigger
BEFORE INSERT OR UPDATE ON jobs_db
FOR EACH ROW 
WHEN (NEW.job_is_confirmed = TRUE or NEW.is_closed = TRUE)
EXECUTE FUNCTION audit_job_time_metrics();

COMMENT ON TRIGGER audit_job_time_metrics_trigger ON jobs_db IS 'This trigger fires when the job_is_confirmed or is_closed fields in jobs_db are updated or inserted into jobs_db.';
CREATE OR REPLACE FUNCTION avg_assembly_time_computation()
RETURNS TRIGGER AS $$

BEGIN 

IF (NEW.start_date IS NOT NULL AND NEW.end_date IS NOT NULL) THEN
  UPDATE assemblies
  SET avg_time_to_complete = (
  SELECT AVG(NEW.assem_completion_time)
  FROM assembly_production_time_hist_db
  WHERE assembly_num = NEW.assembly_num
  AND id<NEW.id)
  WHERE assembly_num = NEW.assembly_num;

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION avg_assembly_time_computation() IS 'This function computes the average time taken to complete one specific assembly (from assembly_production_time_hist_db) and update the corresponding field in assemblies table.';

CREATE OR REPLACE TRIGGER avg_assembly_time_computation_trigger
AFTER INSERT OR UPDATE ON assembly_production_time_hist_db
FOR EACH ROW 
WHEN (NEW.end_date IS NOT NULL)
EXECUTE FUNCTION avg_assembly_time_computation();

COMMENT ON TRIGGER avg_assembly_time_computation_trigger ON assembly_production_time_hist_db IS 'This trigger fires when the end_date in assembly_production_time_hist_db is TRUE and calls the function avg_assembly_time_computation().';CREATE OR REPLACE FUNCTION avg_part_time_computation()
RETURNS TRIGGER AS $$

BEGIN 

IF (NEW.start_date IS NOT NULL AND NEW.end_date IS NOT NULL) THEN
  UPDATE parts_db
  SET avg_time_to_complete = (
  SELECT AVG(NEW.part_completion_time)
  FROM part_production_time_hist_db
  WHERE part_num = NEW.part_num
  AND id<NEW.id)
  WHERE part_num = NEW.part_num;

END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION avg_part_time_computation() IS 'This function computes the average time taken to complete one specific part (from part_production_time_hist_db) and update the corresponding field in parts_db.';

CREATE OR REPLACE TRIGGER avg_part_time_computation_trigger
AFTER INSERT OR UPDATE ON part_production_time_hist_db
FOR EACH ROW 
WHEN (NEW.end_date IS NOT NULL)
EXECUTE FUNCTION avg_part_time_computation();

COMMENT ON TRIGGER avg_part_time_computation_trigger ON part_production_time_hist_db IS 'This trigger fires when the end_date in part_production_time_hist_db is TRUE and calls the function avg_part_time_computation().';CREATE OR REPLACE FUNCTION compute_SO_total ()
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

COMMENT ON TRIGGER before_SO_total_price ON sales_orders_db IS 'Triggers when the unit_price and order_quantity is inputted by user in sales_orders_db to populate sale_total field in sales_orders_db.'; CREATE OR REPLACE FUNCTION create_assembly_rev_in_audit()
RETURNS TRIGGER AS $$

BEGIN

INSERT INTO assembly_rev_audit(operation, assembly_num, assembly_revision_level, stamp, assembly_rev_description_change)
VALUES('I', NEW.assembly_num, NEW.assembly_revision, CURRENT_TIMESTAMP, 'Assembly Created in System');

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_assembly_rev_in_audit() IS 'This function creates a record in assembly_rev_audit when a new assembly is created in the
system and the assembly revision is provided.';

CREATE OR REPLACE TRIGGER create_assembly_rev_in_audit_trigger
AFTER INSERT ON assemblies
FOR EACH ROW
WHEN (NEW.assembly_revision IS NOT NULL)
EXECUTE FUNCTION create_assembly_rev_in_audit();

COMMENT ON TRIGGER  create_assembly_rev_in_audit_trigger ON assemblies IS 'This trigger fires when a new assembly is created and calls the 
function create_assembly_rev_in_audit if the assembly revision is provided upon part creation.';CREATE OR REPLACE FUNCTION create_invoice_lines(invoice_id INTEGER, sales_order_id INTEGER)
RETURNS VOID AS $$

BEGIN 

INSERT INTO invoice_lines(invoice_num, part_num, assembly_num, quantity)
SELECT 
    $1,
    sol.part_num,
    sol.assembly_num,
    sol.quantity
FROM sales_orders_lines AS sol
WHERE so_id = sales_order_id;


END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_invoice_lines(invoice_id INTEGER, sales_order_id INTEGER) IS 'This function create a record in invoice_lines given the 
invoice_number and the sales_order to invoice the customer for.';
CREATE OR REPLACE TRIGGER create_invoice_lines_from_so()
RETURNS TRIGGER AS $$

BEGIN

INSERT INTO invoice_lines(invoice_num, part_num, assembly_num, quantity)
SELECT 
    NEW.invoice_num,
    sol.part_num,
    sol.assembly_num,
    sol.quantity
FROM sales_orders_lines AS sol
WHERE sol.so_id = NEW.sales_order_id;



RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_invoice_lines_from_so() IS 'This trigger function populates the invoice lines for a corresponsing 
sales order number once a new invoice is created.';

CREATE OR REPLACE TRIGGER create_invoice_lines_from_so_trigger
AFTER INSERT OR UPDATE ON invoices_db 
FOR EACH ROW 
WHEN NEW.sales_order_id IS DISTINCT FROM  OLD.sales_order_id
EXECUTE FUNTION create_invoice_lines_from_so();

COMMENT ON TRIGGER create_invoice_lines_from_so_trigger ON invoices_db IS 'This trigger fires when a new sales_order_number
is created in the invoices_db database and creates the corresponsing invoice lines based on the sales_order_number.';CREATE OR REPLACE FUNCTION create_part_rev_in_audit()
RETURNS TRIGGER AS $$

BEGIN

INSERT INTO part_rev_audit(operation, part_num, part_revision_level, stamp, change_description)
VALUES('I', NEW.part_num,NEW.part_revision, CURRENT_TIMESTAMP, 'Part Created in System');

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_part_rev_in_audit() IS 'This function creates a record in part_rev_audit when a new part is created in the
system and the part revision is provided.';

CREATE OR REPLACE TRIGGER create_part_rev_in_audit_trigger
AFTER INSERT ON parts_db
FOR EACH ROW
WHEN (NEW.part_revision IS NOT NULL)
EXECUTE FUNCTION create_part_rev_in_audit();

COMMENT ON TRIGGER  create_part_rev_in_audit_trigger ON parts_db IS 'This trigger fires when a new part is created and calls the 
function create_part_rev_in_audit.';CREATE OR REPLACE FUNCTION create_so_lines(purchase_order_id INTEGER, sales_order_id INTEGER)
RETURNS VOID AS $$

BEGIN 

INSERT INTO sales_orders_lines(so_id, part_num, assembly_num, quantity)
SELECT 
    $2,
    pol.part_num,
    pol.assembly_num,
    pol.quantity
FROM purchase_orders_lines AS pol
WHERE pol.po_num = $1;


END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_so_lines(purchase_order_id INTEGER, sales_order_id INTEGER) IS 'This function creates a record in sales_orders_lines given the purchase_order_number.';



CREATE OR REPLACE FUNCTION generate_ass_rev_approve_date()
RETURNS TRIGGER AS $$

BEGIN

 IF (NEW.assembly_rev_approved = TRUE) THEN

    NEW.assembly_approve_rev_date := CURRENT_TIMESTAMP;
--SELECT NOW() INTO COALESCE(NEW.assembly_approve_rev_date , OLD.assembly_approve_rev_date);

 END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_ass_rev_approve_date() IS 'This function updates the asssembly_approve_rev_date if the assembly_rev_approved boolean is set to TRUE.';

CREATE OR REPLACE TRIGGER assembly_rev_approved_trigger
BEFORE INSERT OR UPDATE ON assembly_revision_db
FOR EACH ROW 
--WHEN (OLD.assembly_rev_approved IS DISTINCT FROM NEW.assembly_rev_approved)
EXECUTE FUNCTION generate_ass_rev_approve_date();

COMMENT ON TRIGGER assembly_rev_approved_trigger ON assembly_revision_db IS 'This trigger fires when an update is made on the assembly_revision_db, it calls the function generate_ass_rev_approve_date() to generate the date corresponding to when the revision was approved.';



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
CREATE OR REPLACE FUNCTION get_assembly_part_cost()
RETURNS TRIGGER AS $$

BEGIN

IF 'TG_OP' = 'INSERT' OR 'TG_OP' = UPDATE

SELECT SUM(p.unit_cost * COALESCE(NEW.quantity, OLD.quantity)) INTO NEW.total_cost_per_part
FROM parts_db AS p
WHERE p.part_num = COALESCE(NEW.part_num , OLD.part_num);

RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION get_assembly_part_cost IS 'This function gets the total cost per part (unit_cost * quantity) and inserts it into 
total_cost_per_part in assemby_parts.';

CREATE OR REPLACE TRIGGER get_assembly_part_cost_trigger
BEFORE INSERT OR UPDATE on assembly_parts
FOR EACH ROW
EXECUTE FUNCTION get_assembly_part_cost();

COMMENT ON TRIGGER get_assembly_part_cost_trigger ON assembly_parts IS 'This trigger fires when a new part is inserted, deleted 
or quantity in assembly is modified.';


CREATE OR REPLACE FUNCTION get_assembly_total_cost()
RETURNS TRIGGER AS $$

BEGIN 

UPDATE assemblies
SET assembly_total_cost = (SELECT SUM(ap.total_cost_per_part) FROM assembly_parts AS ap WHERE ap.assembly_num = NEW.assembly_num)
WHERE assemblies.assembly_num = NEW.assembly_num;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_assembly_total_cost IS 'This function computes the total cost of an assembly by 
summing up the total cost of all the parts that constitutes it.';

CREATE OR REPLACE TRIGGER get_assembly_total_cost_trigger
AFTER INSERT OR UPDATE ON assembly_parts
FOR EACH ROW
EXECUTE FUNCTION get_assembly_total_cost();

COMMENT ON TRIGGER get_assembly_total_cost_trigger ON assembly_parts IS 'This trigger fires when an update is made
on assembly parts and calls the function get_asssembly_total_cost().';CREATE OR REPLACE FUNCTION get_customer_info_for_quote()
RETURNS TRIGGER AS $$

BEGIN

SELECT co.customer_id, co.address_street_1, co.address_street_2, co.address_city, co.address_state, co.address_zip
INTO NEW.customer_id, NEW.address_street_1, NEW.address_street_2, NEW.address_city, NEW.address_state, NEW.address_zip
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
quote and pulls all the address information of the customer.';CREATE OR REPLACE FUNCTION get_customer_id_name_address_from_SO()
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
invoices_db, and calls the function get_customer_id_name_address_from SO.';CREATE OR REPLACE TRIGGER get_invoice_desc_rev_price
BEFORE INSERT OR UPDATE ON invoice_lines
FOR EACH ROW 
EXECUTE FUNCTION get_desc_price_rev();CREATE OR REPLACE FUNCTION get_invoice_total()
RETURNS TRIGGER AS $$

BEGIN

UPDATE invoices_db
SET total_amount = (
    SELECT SUM(line_total) 
    FROM invoice_lines
    WHERE invoice_num = COALESCE(NEW.invoice_num , OLD.invoice_num)
)
WHERE invoice_num = NEW.invoice_num;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_invoice_total() IS 'This function updates the invoice_total by summing up all the invoice_lines 
corresponding to a specifc invoice.';

CREATE OR REPLACE TRIGGER get_invoice_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON invoice_lines
FOR EACH ROW 
EXECUTE FUNCTION get_invoice_total();

COMMENT ON TRIGGER get_invoice_total_trigger ON invoice_lines IS 'This trigger fires and calls get_invoice_total when an invoice 
line is inserted, updated, or deleted from invoice_lines.';CREATE OR REPLACE FUNCTION audit_inventory()
RETURNS TRIGGER AS $$

BEGIN 
	IF NEW.qty_in_stock > OLD.qty_in_stock THEN
	
	INSERT INTO inventory_audit (part_num, transaction_date, qty_added, qty_removed, part_action) 
	VALUES (NEW.part_num, CURRENT_TIMESTAMP, NEW.qty_in_stock - OLD.qty_in_stock, NULL, NULL);
	
	ELSE
	INSERT INTO inventory_audit(part_num, transaction_date, qty_added, qty_removed, part_action) 
	VALUES (NEW.part_num, CURRENT_TIMESTAMP, NULL,OLD.qty_in_stock - NEW.qty_in_stock, NULL);

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION audit_inventory() IS 'This function audits material in and material out of inventory along with dates. It inserts any new transaction in the inventory_audit table.';

CREATE OR REPLACE TRIGGER inventory_audit_trigger
AFTER UPDATE ON inventory_parts_db
FOR EACH ROW 
WHEN (OLD.qty_in_stock IS DISTINCT FROM NEW.qty_in_stock)
EXECUTE FUNCTION audit_inventory();

COMMENT ON TRIGGER inventory_audit_trigger ON inventory_parts_db IS 'This trigger fires when the inventory_parts_db is updated. Its goal is to monitor and audit material flow and store transactions in inventory_audit.';



 CREATE OR REPLACE FUNCTION job_details_to_FG()
RETURNS TRIGGER AS $$

BEGIN 

 IF (NEW.is_closed = TRUE) THEN 
 INSERT INTO finished_goods_db (job_num, sales_order_id, part_num, part_description)
 VALUES (NEW.job_num, NEW.sales_order_id, NEW.part_num, NEW.part_description);

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION job_details_to_FG() IS 'This function inserts into finished_goods_db the job_id, sales_order_id, part_num and part_description of a specific job IF jobs_db.is_closed = TRUE - the job is complete.';

CREATE OR REPLACE TRIGGER job_details_to_FG_trigger
BEFORE UPDATE ON jobs_db
FOR EACH ROW
WHEN (OLD.is_closed IS DISTINCT FROM NEW.is_closed)
EXECUTE FUNCTION job_details_to_FG();

COMMENT ON TRIGGER job_details_to_FG_trigger ON jobs_db IS 'This trigger fires when the an update is done on jobs_db , it calls the function job_details_to_FG() to move the job to finished goods if jobs_db.is_closed = TRUE.';

CREATE OR REPLACE FUNCTION add_part_to_inventory()
RETURNS TRIGGER AS $$

BEGIN

 INSERT INTO inventory_parts_db(part_num, part_description, qty_in_stock, inventory_tolerance, unit_cost)
 VALUES (NEW.part_num, NEW.part_description, NEW.inventory_total_quantity, NEW.inventory_tolerance, NEW.unit_cost);

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_part_to_inventory IS 'This function inserts into inventory_db the part_num, part_description, qty_in_stock, inventory_tol and unit_cost of a part from parts_db.'; 

CREATE TRIGGER part_created_to_inventory
AFTER INSERT ON parts_db
FOR EACH ROW
EXECUTE FUNCTION add_part_to_inventory();

COMMENT ON TRIGGER part_created_to_inventory ON parts_db IS 'This trigger fires when a new part is created in the system and adds it to inventory, it assumes a stock quantity of 0 if it is not written by the user.';


CREATE OR REPLACE FUNCTION no_update_on_po_quantity()
RETURNS TRIGGER AS $$

BEGIN

 RAISE EXCEPTION 'Quantity on PO can not be updated once set, please delete PO and create a NEW one';

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION no_update_on_po_quantity() IS 'This function informs the user that he can not update the quantity on the PO. 
Instead he needs to delete it and create a new one.';

CREATE OR REPLACE TRIGGER no_update_on_po_quantity_trigger
AFTER UPDATE ON purchase_orders_db
FOR EACH ROW 
WHEN (OLD.quantity IS NOT NULL AND NEW. quantity IS DISTINCT FROM OLD.quantity)
EXECUTE FUNCTION no_update_on_po_quantity();

COMMENT ON TRIGGER no_update_on_po_quantity_trigger ON purchase_orders_db IS 'This trigger fires when the user tries to change the
quantity on the PO and calls for the function no_update_on_po_quantity() . To ensure data consistency, in the sales_orders_db.';
CREATE OR REPLACE FUNCTION populate_part_desc_price()
RETURNS TRIGGER AS $$
BEGIN
	
   IF (NEW.part_num IS NOT NULL) THEN
	SELECT part_description , unit_cost INTO NEW.part_description , NEW.unit_price
	FROM parts_db 
	WHERE part_num = NEW.part_num;


   ELSIF (NEW.assembly_num IS NOT NULL) THEN
	SELECT assembly_description , assembly_sales_price INTO NEW.part_description, NEW.unit_price
	FROM assemblies
	WHERE assembly_num = NEW.assembly_num;

   ELSE
	RAISE EXCEPTION 'part_num % does not exist in parts or assemblies', NEW.part_num;

   END IF;

   RETURN NEW;
END;

$$LANGUAGE plpgsql;


COMMENT ON FUNCTION populate_part_desc_price() IS 'This function pulls the unit_price and part_description from parts_description and populates the fields of unit_price and part_description in the sales order database.';


CREATE OR REPLACE TRIGGER before_insert_or_update_sales
BEFORE INSERT OR UPDATE ON sales_orders_db
FOR EACH ROW
EXECUTE FUNCTION populate_part_desc_price();

COMMENT ON TRIGGER before_insert_or_update_sales ON sales_orders_db IS 'Triggers function to populate part_description and unit_price before the sales_orders_db is updated.';
CREATE OR REPLACE FUNCTION populate_part_manufacturers()
RETURNS TRIGGER AS $$

DECLARE 

manuf_name VARCHAR(30);

BEGIN 

 IF (NEW.part_is_purchased = TRUE) THEN

 SELECT m.manufacturer_name 
 INTO manuf_name 
 FROM manufacturers_db AS m 
 WHERE m.manufacturer_id = NEW.manufacturer_id;


 INSERT INTO part_manufacturers(part_num , manuf_1, manuf_1_part_no, manuf_1_part_price)
 VALUES (NEW.part_num, manuf_name , NEW.manufacturer_part_no, NEW.unit_cost) ;

 END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION populate_part_manufacturers() IS 'This function populates the part_num, manuf_1_name and manuf_1_part_no in part_manufacturers once a new part purchased part is created in parts_db and a manufacturer name and number is associated with the part.';

CREATE OR REPLACE TRIGGER populate_part_manufacturers_trigger
AFTER INSERT ON parts_db
FOR EACH ROW 
EXECUTE FUNCTION populate_part_manufacturers();

COMMENT ON TRIGGER populate_part_manufacturers_trigger ON parts_db IS 'This triggers the function populate_part_manufacturers() when a new part_num is created in parts_db.';CREATE OR REPLACE FUNCTION process_assembly_rev_audit() RETURNS TRIGGER AS $assembly_rev_audit$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- making use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO assembly_rev_audit SELECT 'D', OLD.assembly_num , OLD.assembly_revision_lvl, now(), OLD.assembly_rev_description_change;

        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO assembly_rev_audit SELECT 'U', OLD.assembly_num, OLD.assembly_revision_lvl, now(), NEW.assembly_rev_description_change;

        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO assembly_rev_audit SELECT 'I', NEW.assembly_num , NEW.assembly_revision_lvl, now(), NEW.assembly_rev_description_change;

        END IF;

        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$assembly_rev_audit$ LANGUAGE plpgsql;

CREATE TRIGGER assembly_rev_audit
AFTER INSERT OR UPDATE OR DELETE ON assembly_revision_db
    FOR EACH ROW EXECUTE FUNCTION process_assembly_rev_audit();CREATE OR REPLACE FUNCTION process_part_rev_audit() RETURNS TRIGGER AS $part_rev_audit$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- making use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO part_rev_audit SELECT 'D', OLD.part_num , OLD.part_revision_level, now(), NULL;

        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO part_rev_audit SELECT 'U', OLD.part_num, OLD.part_revision_level, now(), NEW.change_desciption;

        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO part_rev_audit SELECT 'I', NEW.part_num , NEW.part_revision_level, now(), NEW.change_description;

        END IF;

        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$part_rev_audit$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER part_rev_audit
AFTER INSERT OR UPDATE OR DELETE ON revision_db
    FOR EACH ROW EXECUTE FUNCTION process_part_rev_audit();CREATE OR REPLACE FUNCTION pull_cust_quantity_due_from_PO()
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

COMMENT ON TRIGGER trigger_PO_info_to_SO ON sales_orders_db IS 'Trigger fires when the user creates a new Sales Order and inputs a customer po_num (from purchase_orders_db).';CREATE OR REPLACE FUNCTION update_part_description() 
RETURNS TRIGGER AS $$
BEGIN

    SELECT p.part_description, p.part_revision 
    INTO NEW.part_description, NEW.part_revision
    FROM parts_db p
    WHERE p.part_num = NEW.part_num;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_part_description() IS 'This function pulls the part description and revision from parts_db when a new part is added to an assembly.';

CREATE OR REPLACE TRIGGER set_part_description
BEFORE INSERT OR UPDATE ON assembly_parts
FOR EACH ROW
EXECUTE FUNCTION update_part_description();

COMMENT ON TRIGGER set_part_description ON assembly_parts IS 'This trigger fires before a part is inserted into assembly_parts and calls the function update_part_description().';
CREATE OR REPLACE FUNCTION pull_part_quantity_due_from_SO()
RETURNS TRIGGER AS $$

/*
DECLARE 
 so_part_num VARCHAR(30);
 so_assembly_num BIGINT;
 so_part_description TEXT;
 so_due_date DATE;
 so_quantity INTEGER;

*/

BEGIN 

	SELECT so.due_date INTO NEW.job_due_date 
	FROM sales_orders_db as so
	WHERE so.sales_order_id = NEW.sales_order_id;

 IF EXISTS (SELECT 1 FROM sales_orders_lines
	WHERE so_id = NEW.sales_order_id AND part_num IS NOT NULL) THEN
	
	SELECT sl.part_num, sl.quantity, sl.unit_description, sl.line_total
 	INTO NEW.job_part_num, NEW.order_quantity, NEW.job_unit_description, NEW.job_payout
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id;

/*
	SELECT so_part_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

 	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	part_num = so_part_num; */

 ELSE

	SELECT sl.assembly_num, sl.quantity, sl.unit_description, sl.line_total
 	INTO NEW.job_assembly_num, NEW.order_quantity, NEW.job_unit_description, NEW.job_payout
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id; 

/*
	SELECT so_assembly_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	assembly_num = so_assembly_num; */

END IF;
RETURN NEW;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION pull_part_quantity_due_from_SO() IS 'This function pulls the corresponding part_num , order_quantity, and due_date for a specific SO_num inserted in the new job creation.';

CREATE OR REPLACE TRIGGER trigger_SO_info_to_Job
BEFORE INSERT ON jobs_db
FOR EACH ROW
EXECUTE FUNCTION pull_part_quantity_due_from_SO();

COMMENT ON TRIGGER trigger_SO_info_to_Job ON jobs_db IS 'Trigger fires when the user created a new job for a specific sales order.';CREATE OR REPLACE FUNCTION pull_part_or_assembly_price_desc()
RETURNS TRIGGER AS $$

BEGIN

 IF (NEW.part_num IS NOT NULL) THEN 
	SELECT p.unit_sales_price, p.part_description, p.part_revision INTO NEW.unit_price , NEW.description, NEW.revision
	FROM parts_db AS p
	WHERE p.part_num = NEW.part_num;
	
 ELSE 
	SELECT asm.assembly_sales_price , asm.assembly_description, asm.assembly_revision INTO NEW.unit_price, NEW.description, NEW.revision
	FROM assemblies AS asm
	WHERE asm.assembly_num = NEW.assembly_num;
	

END IF;
RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION pull_part_or_assembly_price_desc() IS 'This function pulls the part or assembly unit_sales_price and description to populate the fields unit_price, description in quote_lines table.';

CREATE OR REPLACE TRIGGER pull_part_or_assembly_price_desc_trigger
BEFORE INSERT OR UPDATE on quote_lines
FOR EACH ROW
EXECUTE FUNCTION pull_part_or_assembly_price_desc();

COMMENT ON TRIGGER pull_part_or_assembly_price_desc_trigger ON quote_lines IS 'This trigger fires after an insert or update on quote_lines to populate the unit_price and description of the corresponding part inputted.';

CREATE OR REPLACE FUNCTION purchase_order_total()
RETURNS TRIGGER AS $$

BEGIN 

	UPDATE purchase_orders_db
	SET po_total = (
	 SELECT COALESCE(SUM(line_total), 0)
	 FROM purchase_order_lines 
	 WHERE customer_po_num = COALESCE(NEW.po_num , OLD.po_num)
	 )
	
	WHERE customer_po_num = COALESCE(NEW.po_num, OLD.po_num);

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
is done on the purchase_orders_lines and calls the function purchase_order_total to update the total of the purhcase_orders_db.';CREATE OR REPLACE FUNCTION get_desc_price_rev()
RETURNS TRIGGER AS $$

BEGIN

IF NEW.part_num IS NOT NULL THEN
    SELECT p.part_description , p.unit_sales_price, p.part_revision
    INTO NEW.unit_description, NEW.unit_price , NEW.revision
    FROM parts_db AS p
    WHERE p.part_num = NEW.part_num;

ELSEIF NEW.assembly_num IS NOT NULL THEN
    SELECT a.assembly_description, a.assembly_sales_price, a.assembly_revision
    INTO NEW.unit_description, NEW.unit_price, NEW.revision
    FROM assemblies AS a 
    WHERE a.assembly_num = NEW.assembly_num;

ELSE
    RAISE EXCEPTION 'Part # or Assembly # are empty.';

END IF;
RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION get_desc_price_rev() IS 'This function pulls the part description, unit_price and revision into sales_oders_lines.';

CREATE OR REPLACE TRIGGER get_desc_price_rev_trigger
BEFORE INSERT OR UPDATE ON sales_orders_lines
FOR EACH ROW
EXECUTE FUNCTION get_desc_price_rev();

COMMENT ON TRIGGER get_desc_price_rev_trigger ON sales_orders_lines IS 'This trigger fires when an update or insert is done on sales_orders_lines
and pulls the corresponding description, revision and price for the part / assembly.';
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
is done on the sales_orders_lines and calls the function sales_order_total to update the total of the sales_order.';CREATE OR REPLACE FUNCTION split_SO_into_jobs(sales_order_num INTEGER)
RETURNS VOID AS $$

DECLARE 
	due_date_from_so DATE;
	job_due_date DATE;

BEGIN

	SELECT so.due_date INTO due_date_from_so
	FROM sales_orders_db AS so
	WHERE so.sales_order_id = $1;

	job_due_date:=due_date_from_so;

	INSERT INTO jobs_db(sales_order_id, job_due_date, job_part_num, job_assembly_num,
                order_quantity, job_unit_description, job_payout, job_part_or_assembly_revision)
	SELECT so_id, job_due_date, part_num, assembly_num, quantity,unit_description, line_total,revision
	FROM sales_orders_lines
	WHERE so_id = $1;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION split_so_into_jobs(sales_order_num INTEGER) IS 'This function splits a sales order
	with multiple lines into multiple jobs for each line, just by selecting the sales order the user
	wishes to create a job for.';


CREATE OR REPLACE FUNCTION split_job_into_X_lines(sales_order_num INTEGER)
RETURNS VOID AS $$

/*
DECLARE 
 so_part_num VARCHAR(30);
 so_assembly_num BIGINT;
 so_part_description TEXT;
 so_due_date DATE;
 so_quantity INTEGER;

*/
DECLARE


due_date_from_so DATE;
part_number VARCHAR(30);
assembly_number BIGINT;
job_quantity INTEGER;
job_unit_description TEXT;
job_line_total NUMERIC(10,3);
job_revision CHAR(2);

BEGIN 

	SELECT so.due_date INTO due_date_from_so
	FROM sales_orders_db AS so
	WHERE so.sales_order_id = sales_order_num;

    FOR part_number, assembly_number, job_quantity, job_unit_description, job_line_total, job_revision IN 
        SELECT part_num, assembly_num, quantity, unit_description, line_total,revision
        FROM sales_orders_lines
        WHERE so_id = $1

        LOOP
            -- IF part_num IS NOT NULL THEN

                RAISE NOTICE 'Inserting into jobs_db: part_num = %, assembly_num=%, quantity = %', part_number, assembly_number, job_quantity;

                INSERT INTO jobs_db(sales_order_id, job_due_date, part_num, assembly_num, 
                order_quantity, part_description, job_payout, job_part_or_assembly_revision)

                VALUES($1, due_date_from_so, part_number, assembly_number, job_quantity, job_unit_description, job_line_total, job_revision);

            /*ELSEIF line.assembly_num IS NOT NULL THEN

                RAISE NOTICE 'Inserting into jobs_db: assembly_num = %, quantity = %, description=%', line.assembly_num, line.quantity, line.unit_description;

            
                INSERT INTO jobs_db(sales_order_id, job_due_date, 
                order_quantity, part_description, assembly_num, job_payout, job_part_or_assembly_revision)

                VALUES($1, due_date_from_so, line.quantity, line.unit_description, line.assembly_num, line.line_total, line.revision);

            END IF;*/

        END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION split_job_into_X_lines(sales_order_num INTEGER) IS 'This function splits the lines in a sales order into
multiple jobs corresponding to each line.';



SELECT split_job_into_X_lines(17)

SELECT * FROM jobs_db

 

/*
 IF EXISTS (SELECT 1 FROM sales_orders_lines
	WHERE so_id = NEW.sales_order_id AND part_num IS NOT NULL) THEN
	
	SELECT sl.part_num, sl.quantity, sl.unit_description
 	INTO NEW.part_num, NEW.order_quantity, NEW.part_description
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id;


	SELECT so_part_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

 	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	part_num = so_part_num; */
/*
 ELSE

	SELECT sl.assembly_num, sl.quantity, sl.unit_description
 	INTO NEW.assembly_num, NEW.order_quantity, NEW.part_description
	FROM sales_orders_lines AS sl
	WHERE sl.so_id = NEW.sales_order_id; 


	SELECT so_assembly_num FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_due_date FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;
 	SELECT so_quantity FROM sales_orders_db WHERE sales_order_id = NEW.sales_order_id;

	UPDATE jobs_db
 	SET job_due_date = so_due_date,
 	order_quantity = so_quantity,
 	assembly_num = so_assembly_num; 

END IF;
RETURN NEW;

END;
$$ LANGUAGE plpgsql;

*/
CREATE OR REPLACE FUNCTION update_avg_part_cost()
RETURNS TRIGGER AS $$

DECLARE 
 avg_part_cost NUMERIC (10,3);

BEGIN
 IF NEW.qty_in_stock > OLD.qty_in_stock THEN
 avg_part_cost = (OLD.qty_in_stock * OLD.unit_cost + (NEW.qty_in_stock - OLD.qty_in_stock) * NEW.unit_cost) / NEW.qty_in_stock;

 UPDATE inventory_parts_db
 SET unit_cost = avg_part_cost 
 WHERE part_num = NEW.part_num;

 END IF;
RETURN NEW;
END;

$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_avg_part_cost() IS 'This function is a running average for part_costs when a new part is added to inventory. It take the quantity, unit_cost and updates the average cost of the corresponding part.';

CREATE OR REPLACE TRIGGER update_avg_part_cost_trigger
AFTER UPDATE ON inventory_parts_db
FOR EACH ROW
EXECUTE FUNCTION update_avg_part_cost();

COMMENT ON TRIGGER update_avg_part_cost_trigger ON inventory_parts_db IS 'This trigger fires when the quantity of a part in inventory_parts_db increases (reorder / refill).';
CREATE OR REPLACE FUNCTION update_quote_total()
RETURNS TRIGGER AS $$

BEGIN 

	UPDATE quotes_db
	SET quote_total = (
	 SELECT COALESCE(SUM(line_total), 0)
	 FROM quote_lines 
	 WHERE quote_num = COALESCE(NEW.quote_num , OLD.quote_num)
	 )
	
	WHERE quote_num = COALESCE(NEW.quote_num , OLD.quote_num);

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_quote_total() IS 'This computes the total of a quote by summing up the total of each line corresponding to the quote.';

CREATE OR REPLACE TRIGGER update_quote_total_trigger
AFTER INSERT OR UPDATE OR DELETE on quote_lines
FOR EACH ROW 
EXECUTE FUNCTION update_quote_total();

COMMENT ON TRIGGER update_quote_total_trigger ON quote_lines IS 'This trigger fires when a record in quote_lines has been inserted, updated or deleted and calls the function update_quote_total to update the total of a specific quote by summing the total of each line.';

CREATE OR REPLACE FUNCTION update_total_assembly_cost()
RETURNS TRIGGER
AS $$

DECLARE
	 total_cost NUMERIC(10,3) :=0;
BEGIN

SELECT SUM(ap.total_cost_per_part) INTO total_cost
FROM assembly_parts AS ap
WHERE assembly_num = COALESCE(NEW.assembly_num , OLD.assembly_num);

UPDATE assemblies
SET assembly_total_cost = total_cost
WHERE assembly_num = COALESCE(NEW.assembly_num , OLD.assembly_num);

/*
 SELECT SUM (p.unit_cost * NEW.quantity) INTO total_cost
 FROM parts_db p
 JOIN assembly_parts ap ON p.part_num = ap.part_num
 WHERE ap.assembly_num = NEW.assembly_num;

 UPDATE assemblies
 SET assembly_total_cost = total_cost 
 WHERE assembly_num = COALESCE(NEW.assembly_num, OLD.assembly_num);

 */

RETURN NEW;
END;
$$LANGUAGE plpgsql;



COMMENT ON FUNCTION update_total_assembly_cost()
    IS 'This function updates the total assembly cost in assemblies database based on the 
    parts included and the quantity of each included in the respective assembly num.';


CREATE OR REPLACE TRIGGER after_assembly_parts_update
    AFTER INSERT OR UPDATE OR DELETE
    ON assembly_parts
    FOR EACH ROW
    EXECUTE FUNCTION update_total_assembly_cost();

COMMENT ON TRIGGER after_assembly_parts_update ON assembly_parts
    IS 'This triggers when an update or insert of a new parts has be done on the assembly_parts tables.';
