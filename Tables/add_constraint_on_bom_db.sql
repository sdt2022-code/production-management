ALTER TABLE "serp database design".bom_db
ADD CONSTRAINT fk_part_no
FOREIGN KEY (part_num)
REFERENCES parts_db (part_num)
ON DELETE CASCADE
DEFERRABLE INITIALLY DEFERRED;