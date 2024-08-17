CREATE TABLE todos_db(
 todo_id SERIAL PRIMARY KEY,
 task VARCHAR(300),
 task_due_date DATE,
 task_priority priority_lvl,
 customer_id INTEGER,
 first_reminder DATE,
 second_reminder DATE,
 additional_notes TEXT,
 CONSTRAINT fk_customer_todos FOREIGN KEY (customer_id) REFERENCES customer_db (customer_id)
);