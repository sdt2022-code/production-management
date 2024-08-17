SELECT t.tgname AS trigger_name,
       c.relname AS table_name,
       d.description AS trigger_comment
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_description d ON t.oid = d.objoid
WHERE c.relname = 'sales_orders_db'; 