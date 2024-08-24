CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    sales_order_id INTEGER REFERENCES sales_orders(sales_order_id),  -- Reference to sales order
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    customer_id INTEGER REFERENCES customers(customer_id),
    billing_address TEXT,
    payment_status VARCHAR(20),  -- e.g., 'Unpaid', 'Paid', 'Overdue'
    total_amount NUMERIC(10, 2),  -- Total invoice amount
    tax_amount NUMERIC(10, 2),  -- Total tax amount for the invoice
    amount_paid NUMERIC(10, 2) DEFAULT 0,  -- Amount already paid
    balance_due NUMERIC(10, 2),  -- Balance amount due
    notes TEXT,  -- Any additional notes
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
