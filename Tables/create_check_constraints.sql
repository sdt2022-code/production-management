ALTER TABLE assemblies
ADD CONSTRAINT check_ass_cost_pos CHECK (assembly_total_cost >0),
ADD CONSTRAINT check_ass_sales_price_pos CHECK (assembly_sales_price >0);


ALTER TABLE parts_db
ADD CONSTRAINT check_part_price_pos CHECK (unit_price > 0);


ALTER TABLE invoices_db
ADD CONSTRAINT check_shipping_fee_pos CHECK (shipping_fee > 0),
ADD CONSTRAINT check_additional_fees_pos CHECK (additional_fees > 0);


ALTER TABLE todos_db
ADD CONSTRAINT check_due_date_vs_now CHECK (task_due_date > NOW());

ALTER TABLE sales_orders_db
ADD CONSTRAINT check_shipping_fees CHECK (shipping_fees > 0),
ADD CONSTRAINT check_tax_po CHECK (total_taxes > 0),
ADD CONSTRAINT check_quantity_pos CHECK (order_quantity > 0);

ALTER TABLE revision_db
ADD CONSTRAINT check_created_vs_aprv_date CHECK (rev_date_created < revision_date_approval);

ALTER TABLE assembly_parts
ADD CONSTRAINT check_qty_pos CHECK (quantity > 0),
ALTER COLUMN total_cost_per_part SET DATA TYPE NUMERIC (10,4);

ALTER TABLE jobs_db
ADD CONSTRAINT check_latest_due_date CHECK (job_due_date > job_latest_start_date AND job_due_date > job_shipment_date),
ADD CONSTRAINT check_over_run_qty_pos CHECK (over_run_qty > 0);







