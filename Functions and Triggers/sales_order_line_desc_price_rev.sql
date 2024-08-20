CREATE OR REPLACE FUNCTION get_desc_price_rev()
RETURNS TRIGGER AS $$

BEGIN

IF NEW.part_num IS NOT NULL THEN
    SELECT p.part_description , p.unit_price, p.revision
    INTO NEW.unit_description, NEW.unit_price , NEW.revision
    FROM parts_db AS p
    WHERE p.part_num = NEW.part_num;

ELSEIF NEW.assembly_num IS NOT NULL THEN
    SELECT a.assembly_description, a.assembly_sales_price, a.assembly_revision
    INTO NEW.unit_description, NEW.unit_price, NEW.revision
    FROM assemblies AS a 
    WHERE a.assembly_num = NEW.assembly_num;

ELSE
    RAISE EXCEPTION 'Part # or Assembly # are empty.';

END IF;
RETURN NEW;
END;
$$LANGUAGE plpgsql;

COMMENT ON FUNCTION get_desc_price_rev() IS 'This function pulls the part description, unit_price and revision into sales_oders_lines.';

CREATE OR REPLACE TRIGGER get_desc_price_rev_trigger
BEFORE INSERT OR UPDATE ON sales_orders_lines
FOR EACH ROW
EXECUTE FUNCTION get_desc_price_rev();

COMMENT ON TRIGGER get_desc_price_rev_trigger ON sales_orders_lines IS 'This trigger fires when an update or insert is done on sales_orders_lines
and pulls the corresponding description, revision and price for the part / assembly.';
