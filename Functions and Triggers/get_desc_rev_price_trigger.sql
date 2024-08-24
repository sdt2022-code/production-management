CREATE OR REPLACE TRIGGER get_invoice_desc_rev_price
BEFORE INSERT OR UPDATE ON invoice_lines
FOR EACH ROW 
EXECUTE FUNCTION get_desc_price_rev();