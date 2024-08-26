CREATE OR REPLACE FUNCTION populate_part_manufacturers()
RETURNS TRIGGER AS $$

DECLARE 

manuf_name VARCHAR(30);

BEGIN 

 IF (NEW.part_is_purchased = TRUE) THEN

 SELECT m.manufacturer_name 
 INTO manuf_name 
 FROM manufacturers_db AS m 
 WHERE m.manufacturer_id = NEW.manufacturer_id;


 INSERT INTO part_manufacturers(part_num , manuf_1, manuf_1_part_no, manuf_1_part_price)
 VALUES (NEW.part_num, manuf_name , NEW.manufacturer_part_no, NEW.unit_cost) ;

 END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION populate_part_manufacturers() IS 'This function populates the part_num, manuf_1_name and manuf_1_part_no in part_manufacturers once a new part purchased part is created in parts_db and a manufacturer name and number is associated with the part.';

CREATE OR REPLACE TRIGGER populate_part_manufacturers_trigger
AFTER INSERT ON parts_db
FOR EACH ROW 
EXECUTE FUNCTION populate_part_manufacturers();

COMMENT ON TRIGGER populate_part_manufacturers_trigger ON parts_db IS 'This triggers the function populate_part_manufacturers() when a new part_num is created in parts_db.';