ALTER TABLE purchase_orders_db
DROP CONSTRAINT purchase_orders_db_pkey,
ADD CONSTRAINT purchase_orders_db_pkey PRIMARY KEY (customer_po_num);

ALTER TABLE sales_orders_db
DROP CONSTRAINT fk_po_num;
ALTER TABLE purchase_order_lines
DROP CONSTRAINT fk_po_num;

ALTER TABLE purchase_orders_db
ALTER COLUMN customer_po_num SET DATA TYPE VARCHAR(30);


ALTER TABLE sales_orders_db
ALTER COLUMN purchase_order_num SET DATA TYPE VARCHAR(30);

ALTER TABLE purchase_order_lines
ALTER COLUMN po_num SET DATA TYPE VARCHAR(30);

ALTER TABLE sales_orders_db
ADD CONSTRAINT fk_cust_po_num FOREIGN KEY (purchase_order_num) references purchase_orders_db(customer_po_num);
ALTER TABLE purchase_order_lines
ADD CONSTRAINT fk_cust_po_num FOREIGN KEY (po_num) references purchase_orders_db(customer_po_num);