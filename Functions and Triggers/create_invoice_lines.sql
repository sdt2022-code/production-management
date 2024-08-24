CREATE OR REPLACE FUNCTION create_invoice_lines(invoice_id INTEGER, sales_order_id INTEGER)
RETURNS VOID AS $$

BEGIN 

INSERT INTO invoice_lines(invoice_num, part_num, assembly_num)
SELECT 
    (SELECT invoice_num FROM invoices_db WHERE invoice_num = invoice_id),
    sol.part_num,
    sol.assembly_num
FROM sales_orders_lines AS sol
WHERE so_id = sales_order_id;


END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_invoice_lines(invoice_id INTEGER, sales_order_id INTEGER) IS 'This function create a record in invoice_lines given the 
invoice_number and the sales_order to invoice the customer for.';
