INSERT INTO sales_orders_db (
    so_order_date,
    due_date,
    purchase_order_num,
    shipping_fees,
    part_num,
    total_taxes
  )
VALUES (
    NOW() - INTERVAL '1 DAY',
    NOW() + INTERVAL '1 MONTH',
    1,
    2.99,
    'A001',
    1.99
  );