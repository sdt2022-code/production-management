INSERT INTO customer_db (
    customer_id,
    customer_name,
    sales_contact_name,
    sales_contact_email,
    sales_contact_phone,
    customer_po_box,
    customer_abrv,
    customer_address,
    ship_to_address
  )
VALUES (
    1,  -- customer_id
    'Acme Corporation',  -- customer_name: character varying
    'John Doe',  -- sales_contact_name: character varying
    'johndoe@acme.com',  -- sales_contact_email: character varying
    '+1-555-123-4567',  -- sales_contact_phone: character varying
    987654,  -- customer_po_box: integer
    'ACME',  -- customer_abrv: character varying
    '{"street": "123 Elm Street", "city": "Metropolis", "state": "NY", "zip": "10001"}',  -- customer_address: json
    '{"street": "456 Oak Avenue", "city": "Gotham", "state": "NY", "zip": "10002"}'  -- ship_to_address: json
);
