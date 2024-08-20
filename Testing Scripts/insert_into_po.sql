INSERT INTO purchase_orders_db (
    customer_id,
    assembly_num,
    po_date_recieved,
    terms,
    part_num,
    customer_part_num,
    quantity
  )
VALUES (
    1,
    100576,
    NOW() - INTERVAL '2 DAYS',
    '30 DAYS',
    'A001',
    'ABC-001',
    1
  );