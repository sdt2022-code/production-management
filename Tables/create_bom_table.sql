CREATE TABLE assembly_parts(
	assembly_no INTEGER,
	part_no VARCHAR(20),
	part_type VARCHAR(5),
	quantity INTEGER,
	PRIMARY KEY (assembly_no, part_n0, part_type),
	FOREIGN KEY (assembly_no) REFERENCES assemblies (part_no),
	FOREIGN KEY (part_no) REFERENCES parts_db (part_no) ON DELETE CASCADE
);

