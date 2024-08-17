CREATE  TABLE parts_db ( 
	part_num             numeric  NOT NULL  ,
	part_description     text[]    ,
	part_search_words    text[]    ,
	part_revision        char(1)    ,
	part_type            char(1)    ,
	manufacturer_part_no varchar(15)    ,
	manufacturer_id      integer    ,
	lead_time            time    ,
	supplier_id          integer    ,
	/* CONSTRAINT pk_manufatured_part PRIMARY KEY ( part_num ),
	CONSTRAINT unq_parts_db_manufacturer_id UNIQUE ( manufacturer_id ) ,
	CONSTRAINT unq_parts_db_supplier_id UNIQUE ( supplier_id )*/
 );