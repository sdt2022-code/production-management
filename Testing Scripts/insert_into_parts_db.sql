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
    '10-002', 
	ARRAY['High-quality plastic', 'Heat-resistant'],
	ARRAY['plastic', 'heat-resistant', 'industrial'],
	'A',
    'MFG-1002',  
    123, 
    INTERVAL '9 days',  
    6.75,  
    500,  
    5,  
    TRUE, 
    INTERVAL '5 weeks',  
    25.99

);