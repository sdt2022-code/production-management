/*

INSERT INTO quotes_db (customer_id , quote_date, quote_notes, quote_num, quote_status)
VALUES (1 , NOW(), 'This is the first quote in the database', 1, 'draft');

*/

INSERT INTO quote_lines (
    line_id,
    quote_num,
    part_num,
    quantity
  )
VALUES (
    2,
    1,
    '10-002',
    6
);

