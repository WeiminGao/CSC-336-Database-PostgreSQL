BEGIN;

DROP TABLE IF EXISTS boats;
DROP TABLE IF EXISTS buyers;
DROP TABLE IF EXISTS transactions;

CREATE TABLE boats (
	prod_id integer NOT NULL,
	brand text NOT NULL,
	category text,
	cost integer NOT NULL,
	price numeric (10,1) NOT NULL
);

CREATE TABLE buyers (
	cust_id integer NOT NULL,
	fname text NOT NULL,
	lname text NOT NULL,
	city text NOT NULL,
	state character(2) NOT NULL,
	referrer text NOT NULL
);

CREATE TABLE transactions (
	trans_id integer NOT NULL,
	cust_id integer NOT NULL,
	prod_id integer NOT NULL,
	qty smallint,
	price numeric (10,1) NOT NULL
);

ALTER TABLE ONLY boats
	ADD CONSTRAINT boats_pkey PRIMARY KEY (prod_id);
	
ALTER TABLE ONLY buyers
	ADD CONSTRAINT buyers_pkey PRIMARY KEY (cust_id);
	
ALTER TABLE ONLY transactions
	ADD CONSTRAINT transactions_pkey PRIMARY KEY (trans_id);
	
ALTER TABLE ONLY transactions
	ADD CONSTRAINT transactions_cust_id_fkey FOREIGN KEY (cust_id) REFERENCES buyers(cust_id),
	ADD CONSTRAINT transactions_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES boats(prod_id);
	
COMMIT;

ANALYZE boats;
ANALYZE buyers;
ANALYZE transactions;

