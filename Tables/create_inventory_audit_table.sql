CREATE TABLE inventory_audit(

part_num VARCHAR(30) NOT NULL,
transaction_date DATE NOT NULL DEFAULT NOW(),
qty_added INTEGER NOT NULL,
qty_removed INTEGER NOT NULL, 
part_action VARCHAR(30),
CONSTRAINT part_num_stock_exists FOREIGN KEY (part_num) REFERENCES parts_db(part_num)
);
 


