INSERT INTO sales_orders_db (
   customer_id,
    so_order_date,
    due_date,
    purchase_order_num,
    shipping_fees,
    total_taxes
  )
VALUES (
  4,
  NOW() - INTERVAL '1 DAY',
  NOW() + INTERVAL '1 MONTH',
  3,
  4.99,
  0
  );



