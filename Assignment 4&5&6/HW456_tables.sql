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