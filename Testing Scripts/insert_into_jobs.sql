INSERT INTO jobs_db (
    sales_order_id,
    job_shipment_date,
    job_responsability_of,
    over_run_qty,
    part_description
  )
VALUES (
    15,
    NOW() + INTERVAL '1 MONTH',
    'John',
    0,
    'part_description:text'
  );