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
is created in the invoices_db database and creates the corresponsing invoice lines based on the sales_order_number.';