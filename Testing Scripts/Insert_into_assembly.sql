INSERT INTO assemblies (
    assembly_num,
    assembly_description,
    assembly_search_words,
    assembly_sales_price,
    avg_time_to_complete,
    assembly_revision
  )
VALUES (
    100576,
    'Rice Cooker',
    'rice, cooker, medium size, low-end',
    220.50,
    INTERVAL '3 weeks',
    'A'
  );


INSERT INTO public.assembly_parts(
	assembly_num, 
    part_num, 
    quantity)
VALUES (	
    100576, 
    'A001',
    1);


INSERT INTO assembly_revision_db (
    assembly_revision_lvl,
    assembly_revision_created,
    assembly_rev_description_change,
    assembly_rev_approved,
    assembly_num
      )
VALUES (
    'A',
    NOW(),
    'Initial assembly for the rice cooker',
    FALSE,
    100576
      );