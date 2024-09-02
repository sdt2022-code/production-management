SELECT 
    kcu.table_name AS referencing_table,
    kcu.column_name AS referencing_column,
    COUNT(*) AS reference_count
FROM 
    information_schema.key_column_usage kcu
JOIN 
    information_schema.referential_constraints rc 
    ON kcu.constraint_name = rc.constraint_name
JOIN 
    information_schema.constraint_column_usage ccu 
    ON rc.unique_constraint_name = ccu.constraint_name
WHERE 
    ccu.table_name = 'parts_db'
    AND ccu.column_name = 'part_num'
GROUP BY 
    kcu.table_name, kcu.column_name;