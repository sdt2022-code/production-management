CREATE OR REPLACE FUNCTION get_invoice_total()
RETURNS TRIGGER AS $$

BEGIN

UPDATE invoices_db
SET invoice_total = (
    SELECT SUM(line_total) 
    FROM invoice_lines
    WHERE invoice_num = COALESCE(NEW.invoice_num , OLD.invoice_num)
)
WHERE invoice_num = NEW.invoice_num;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_invoice_total() IS 'This function updates the invoice_total by summing up all the invoice_lines 
corresponding to a specifc invoice.';

CREATE OR REPLACE TRIGGER get_invoice_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON invoice_lines
FOR EACH ROW 
EXECUTE FUNCTION get_invoice_total();

COMMENT ON TRIGGER get_invoice_total_trigger ON invoice_lines IS 'This trigger fires and calls get_invoice_total when an invoice 
line is inserted, updated, or deleted from invoice_lines.';