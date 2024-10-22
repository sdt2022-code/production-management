CREATE OR REPLACE FUNCTION create_so_lines(purchase_order_id INTEGER, sales_order_id INTEGER)
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



