CREATE TABLE jobs_db(
 job_id SERIAL PRIMARY KEY,
 sales_order_id INTEGER,
 job_latest_start_date DATE,
 job_due_date DATE,
 job_shipment_date DATE,
 job_responsability_of VARCHAR(40),
 CONSTRAINT fk_sales_order_id FOREIGN KEY (sales_order_id) REFERENCES sales_orders_db (sales_order_id)
);