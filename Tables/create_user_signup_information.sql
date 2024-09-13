CREATE TABLE user_signup_information(
    id serial,
    customer_name text,
    customer_email text,
    customer_company text DEFAULT 'N/A',
    customer_message text

)