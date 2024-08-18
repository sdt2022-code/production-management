SELECT schemaname, relname 
FROM pg_stat_user_tables 
WHERE n_live_tup > 0;
