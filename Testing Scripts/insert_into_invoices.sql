INSERT INTO invoices_db (
    sales_order_id,
    invoice_date,
    invoice_due_date,
    tax_amount,
    amount_paid
  )
VALUES (
    15,
    NOW(),
    NOW() + INTERVAL '30 DAYS',
    18.45,
    0
  );



-- Inserting into invoice_lines

SELECT * FROM create_invoice_lines(2, 15)
