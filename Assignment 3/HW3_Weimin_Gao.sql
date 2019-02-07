--
--CSC 336: Database
-- Assignment 3
--

--1.  We want to spend some advertising money - where should we spend it?
--      I.e., What is our best referral source of buyers?
SELECT referrer, COUNT (referrer) AS purchase_amount
FROM transactions INNER JOIN buyers
	ON transactions.cust_id = buyers.cust_id
GROUP BY referrer
ORDER BY COUNT (referrer) DESC;

--2.  Who of our customers has not bought a boat?
SELECT trans_id, buyers.cust_id, fname, lname, city, state, referrer
FROM transactions 
	RIGHT JOIN buyers
	ON transactions.cust_id = buyers.cust_id
WHERE trans_id IS NULL;

--3.  Which boats have not sold?
SELECT trans_id, boats.prod_id, brand, category, cost, boats.price
FROM transactions 
	RIGHT JOIN boats
	ON transactions.prod_id = boats.prod_id
WHERE trans_id IS NULL;

--4.  What boat did Alan Weston buy?
SELECT buyers.cust_id, fname, lname, trans_id, boats.prod_id, brand, category, cost, boats.price
FROM transactions 
	INNER JOIN boats
	ON transactions.prod_id = boats.prod_id
	INNER JOIN buyers
	ON transactions.cust_id = buyers.cust_id
WHERE fname = 'Alan' AND lname = 'Weston';

--5.  Who are our VIP customers?
--    I.e., Has anyone bought more than one boat? (see Hint)
WITH temp_table AS(
	SELECT buyers.cust_id, fname, lname, COUNT (buyers.cust_id) AS purchase_amount
	FROM transactions 
		INNER JOIN buyers
		ON transactions.cust_id = buyers.cust_id
	GROUP BY buyers.cust_id
	ORDER BY COUNT (buyers.cust_id) DESC
)
SELECT *
FROM temp_table
WHERE purchase_amount > 1
;




---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


--Create tables:
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