DO $$ 
DECLARE
    r RECORD;
    column_exists BOOLEAN;
BEGIN
    -- Loop through each table in the current schema
    FOR r IN 
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'  -- Adjust schema if needed
          AND table_type = 'BASE TABLE'
    LOOP
        -- Check if the "company_id" column exists in the table
        SELECT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = r.table_schema
              AND table_name = r.table_name
              AND column_name = 'company_id'
        ) INTO column_exists;

        -- If the column does not exist, add it
        IF NOT column_exists THEN
            EXECUTE 'ALTER TABLE ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ' ADD COLUMN company_id INT;';
            RAISE NOTICE 'Added column company_id to table %', r.table_name;
        ELSE
            RAISE NOTICE 'Table % already has a company_id column', r.table_name;
        END IF;
    END LOOP;
END $$;
