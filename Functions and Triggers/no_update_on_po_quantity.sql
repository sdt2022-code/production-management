CREATE OR REPLACE FUNCTION no_update_on_po_quantity()
RETURNS TRIGGER AS $$

BEGIN

 RAISE EXCEPTION 'Quantity on PO can not be updated once set, please delete PO and create a NEW one';

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION no_update_on_po_quantity() IS 'This function informs the user that he can not update the quantity on the PO. 
Instead he needs to delete it and create a new one.';

CREATE OR REPLACE TRIGGER no_update_on_po_quantity_trigger
AFTER UPDATE ON purchase_orders_db
FOR EACH ROW 
WHEN (OLD.quantity IS NOT NULL AND NEW. quantity IS DISTINCT FROM OLD.quantity)
EXECUTE FUNCTION no_update_on_po_quantity();

COMMENT ON TRIGGER no_update_on_po_quantity_trigger ON purchase_orders_db IS 'This trigger fires when the user tries to change the
quantity on the PO and calls for the function no_update_on_po_quantity() . To ensure data consistency, in the sales_orders_db.';
