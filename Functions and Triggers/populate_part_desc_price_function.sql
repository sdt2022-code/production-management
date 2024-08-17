CREATE OR REPLACE FUNCTION populate_part_desc_price()
RETURNS TRIGGER AS $$
BEGIN
	
   IF EXISTS (SELECT 1 FROM parts_db WHERE part_num = NEW.part_num) THEN
	SELECT part_description , part_unit_cost INTO NEW.part_description , 		NEW.unit_price
	FROM parts_db 
	WHERE part_num = NEW.part_num;


   ELSIF EXISTS (SELECT 1 FROM assemblies WHERE assembly_num = NEW.part_num) THEN
	SELECT assembly_description , assembly_sales_price INTO 		NEW.part_description, NEW.unit_price
	FROM assemblies
	WHERE assembly_num = NEW.part_num;

   ELSE
	RAISE EXCEPTION 'part_num % does not exist in parts or assemblies', NEW.part_num;

   END IF;

   RETURN NEW;
END;

$$LANGUAGE plpgsql;


COMMENT ON FUNCTION populate_part_description() IS 'This function pulls the unit_price and part_description from parts_description and populates the fields of unit_price and part_description in the sales order database.';


CREATE TRIGGER before_insert_or_update_sales
BEFORE INSERT OR UPDATE ON sales_orders_db
FOR EACH ROW
EXECUTE FUNCTION populate_part_desc_price();

COMMENT ON TRIGGER before_insert_or_update_sales ON sales_orders_db IS 'Triggers function to populate part_description and unit_price before the sales_orders_db is updated.';
