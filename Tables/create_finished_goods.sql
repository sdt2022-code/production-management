CREATE TABLE finished_goods_db (
 finished_goods_id SERIAL PRIMARY KEY,
 job_id INTEGER REFERENCES jobs_db(job_id),
 sales_order_id INTEGER, 
 part_num VARCHAR(30),
 part_description TEXT,
 date_completed DATE DEFAULT NOW(), 
 supporting_documents PATH
); 
 
