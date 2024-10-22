/* INSERT INTO purchase_order_lines(
	part_num, quantity, po_num)
	VALUES ('A002', 5 ,'ABC-12'),('P002', 10, 'ABC-12');

SELECT * FROM purchase_order_lines; */


SELECT 
po.address_street_1,
po.address_street_2,
po.address_state,
po.address_zip,
po.address_city,
po.customer_name,
  (
    SELECT json_agg(
      json_build_object(
        'line_id', pol.line_id,
        'part_num', pol.part_num,
        'assembly_num', pol.assembly_num,
        'quantity', pol.quantity,
        'revision', pol.revision,
        'unit_description', pol.unit_description,
        'unit_price', pol.unit_price,
        'line_total', pol.line_total
      )
    )
    FROM purchase_order_lines pol
    WHERE pol.po_num = po.customer_po_num
  ) AS purchase_order_line,
  (
    SELECT SUM(pol.line_total)
    FROM purchase_order_lines pol
    WHERE pol.po_num= po.customer_po_num
  ) AS total
FROM purchase_orders_db po
WHERE po.customer_po_num= 'ABC-12';


