INSERT INTO parts_db(
	part_num, 
    part_description, 
    part_search_words, 
    part_revision, 
    manufacturer_part_no, 
    manufacturer_id, 
    lead_time, 
    unit_cost, 
    inventory_total_quantity, 
    inventory_tolerance, 
    part_is_purchased,
    avg_time_to_complete,
    unit_sales_price
    )

VALUES (
    'A002', 
	'Aluminum part for rice cooker cover',
	ARRAY['Cover', 'Aluminum'],
	'B',
    NULL,  
    NULL, 
    NULL,  
    10,  
    4,  
    0,  
    FALSE,
    INTERVAL '1 weeks',
    45.99
);



INSERT INTO revision_db (
    part_revision_level,
    part_num,
    rev_date_created,
    revision_is_approved,
    revision_approved_by,
    revision_date_approval,
    rev_docs,
    change_description
  )
VALUES (
    'B',
    'A002',
    NOW() - INTERVAL' 2 days',
    TRUE,
    'Manager',
    NOW(),
    'C:\Users\sari_\Desktop\AI Business\SaaS\Postgre Database Dev',
    'Initial upload to system'
  );
 