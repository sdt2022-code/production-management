CREATE OR REPLACE FUNCTION pull_part_or_assembly_price_desc()
RETURNS TRIGGER AS $$

BEGIN

 IF (NEW.part_num IS NOT NULL) THEN 
	SELECT p.unit_sales_price, p.part_description, p.part_revision INTO NEW.unit_price , NEW.description, NEW.revision
	FROM parts_db AS p
	WHERE p.part_num = NEW.part_num;
	
 ELSE 
	SELECT asm.assembly_sales_price , asm.assembly_description, asm.assembly_revision INTO NEW.unit_price, NEW.description, NEW.revision
	FROM assemblies AS asm
	WHERE asm.assembly_num = NEW.assembly_num;
	

END IF;
RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION pull_part_or_assembly_price_desc() IS 'This function pulls the part or assembly unit_sales_price and description to populate the fields unit_price, description in quote_lines table.';

CREATE OR REPLACE TRIGGER pull_part_or_assembly_price_desc_trigger
BEFORE INSERT OR UPDATE on quote_lines
FOR EACH ROW
EXECUTE FUNCTION pull_part_or_assembly_price_desc();

COMMENT ON TRIGGER pull_part_or_assembly_price_desc_trigger ON quote_lines IS 'This trigger fires after an insert or update on quote_lines to populate the unit_price and description of the corresponding part inputted.';

