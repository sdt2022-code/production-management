CREATE OR REPLACE FUNCTION update_quote_total()
RETURNS TRIGGER AS $$

BEGIN 

	UPDATE quotes_db
	SET quote_total = (
	 SELECT COALESCE(SUM(line_total), 0)
	 FROM quote_lines 
	 WHERE quote_num = COALESCE(NEW.quote_num , OLD.quote_num)
	 )
	
	WHERE quote_num = COALESCE(NEW.quote_num , OLD.quote_num);

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_quote_total() IS 'This computes the total of a quote by summing up the total of each line corresponding to the quote.';

CREATE OR REPLACE TRIGGER update_quote_total_trigger
AFTER INSERT OR UPDATE OR DELETE on quote_lines
FOR EACH ROW 
EXECUTE FUNCTION update_quote_total();

COMMENT ON TRIGGER update_quote_total_trigger ON quote_lines IS 'This trigger fires when a record in quote_lines has been inserted, updated or deleted and calls the function update_quote_total to update the total of a specific quote by summing the total of each line.';

