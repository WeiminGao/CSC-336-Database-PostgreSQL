--
--CSC 336: Database
-- Assignment 4
--

----------------------------------------------------------------------
--My table:
BEGIN;

DROP TABLE IF EXISTS securities CASCADE;
DROP TABLE IF EXISTS fundamentals CASCADE;
DROP TABLE IF EXISTS prices CASCADE;

CREATE TABLE securities (
	symbol text NOT NULL,
	company text NOT NULL,
	sector text NOT NULL,
	sub_industry text NOT NULL,
	initial_trade_date date
);

CREATE TABLE fundamentals (
	id integer NOT NULL,
	symbol text NOT NULL,
	year_ending date NOT NULL,
	cash_and_cash_equivalents bigint NOT NULL,
	earnings_before_interest_and_taxes bigint NOT NULL,
	gross_margin smallint NOT NULL,
	net_income bigint NOT NULL,
	total_assets bigint NOT NULL,
	total_liabilities bigint NOT NULL,
	total_revenue bigint NOT NULL,
	year smallint NOT NULL,
	earnings_per_share real,
	shares_outstanding double precision
);

CREATE TABLE prices (
	price_id Serial NOT NULL,
	date date NOT NULL,
	symbol text NOT NULL,
	open double precision NOT NULL,
	close double precision NOT NULL,
	low double precision NOT NULL,
	high double precision NOT NULL,
	volume integer NOT NULL
);

ALTER TABLE ONLY securities
	ADD CONSTRAINT securities_pkey PRIMARY KEY (symbol);

ALTER TABLE ONLY fundamentals
	ADD CONSTRAINT fundamentals_pkey PRIMARY KEY (id);
	
ALTER TABLE ONLY prices
	ADD CONSTRAINT prices_pkey PRIMARY KEY (price_id);
	
ALTER TABLE ONLY fundamentals
	ADD CONSTRAINT fundamentals_symbol_fkey FOREIGN KEY (symbol) REFERENCES securities(symbol);

ALTER TABLE ONLY prices
	ADD CONSTRAINT prices_symbol_fkey FOREIGN KEY (symbol) REFERENCES securities(symbol);

COMMIT;

ANALYZE securities;
ANALYZE fundamentals;
ANALYZE prices;


--COPY securities FROM 'C:\securities.csv' WITH (FORMAT csv);
--COPY fundamentals FROM 'C:\fundamentals.csv' WITH (FORMAT csv);
--COPY prices(date,symbol,open,close,low,high,volume) FROM 'C:\prices.csv' WITH (FORMAT csv);


-------------------------------------------------------------------------
--My code:
CREATE TEMP TABLE get_row_num as 
SELECT 
	symbol,
	date,
	close,
	ROW_NUMBER() OVER (PARTITION BY symbol, EXTRACT(year from date) ORDER BY date) as row_num
FROM prices
WHERE date::text LIKE '%-01-%'
;

CREATE TEMP TABLE year_end_prices AS
SELECT
	symbol,	
	date,
	close
FROM get_row_num
WHERE row_num = 1
ORDER BY symbol, date DESC
;

CREATE TEMP TABLE Annual_Return AS
SELECT 
	symbol,
	date,
	close,
	LEAD(close) OVER (PARTITION BY symbol ORDER BY date DESC),
	(close/LEAD(close) OVER (PARTITION BY symbol ORDER BY date DESC)-1.0)::NUMERIC(10,4) as pct_return
FROM year_end_prices
ORDER BY pct_return DESC
;

DROP TABLE IF EXISTS awesome_performers CASCADE;

CREATE TABLE awesome_performers AS
SELECT symbol, EXTRACT(year from date) as year, close, pct_return 
FROM Annual_Return 
WHERE pct_return IS NOT NULL
LIMIT 100
OFFSET 50
;

ALTER TABLE ONLY awesome_performers
	ADD CONSTRAINT awesome_performers_symbol_fkey FOREIGN KEY (symbol) REFERENCES securities(symbol);

ANALYZE awesome_performers;
