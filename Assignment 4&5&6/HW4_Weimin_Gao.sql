--
--CSC 336: Database
-- Assignment 4
--

--Previous code:
WITH t1 AS(
SELECT 
	symbol,
	EXTRACT(year from date) as year,
	open,
	ROW_NUMBER() OVER (PARTITION BY symbol, EXTRACT(year from date) ORDER BY date) as row_min_to_max
	--ROW_NUMBER() OVER (PARTITION BY symbol, EXTRACT(year from date) ORDER BY date DESC) as r2_number
FROM prices
),
t2 as (
SELECT 
	symbol,
	EXTRACT(year from date) as year,
	close,
	--ROW_NUMBER() OVER (PARTITION BY symbol, EXTRACT(year from date) ORDER BY date) as r_number
	ROW_NUMBER() OVER (PARTITION BY symbol, EXTRACT(year from date) ORDER BY date DESC) as row_max_to_min
FROM prices
)
SELECT * FROM t1 INNER JOIN t2 ON t1.symbol = t2.symbol
WHERE row_min_to_max = 1 and row_max_to_min = 1 and t1.year = t2.year
;



--------------------------------------------------------------------
--prof. code:
CREATE TEMP TABLE partition_date AS 
SELECT
	date,
	ROW_NUMBER() OVER (PARTITION BY EXTRACT(year from date) ORDER BY date) AS num
FROM prices
WHERE symbol LIKE 'A%';

CREATE TEMP TABLE year_ends AS
SELECT date AS year_ends
FROM partition_date
WHERE num = 1
ORDER BY date DESC;

CREATE TEMP TABLE year_end_prices AS
SELECT symbol, date, close
FROM prices
WHERE date IN 
	(SELECT * FROM year_ends)
ORDER BY symbol, date DESC;

CREATE TEMP TABLE Annual_Return AS
SELECT 
	symbol,
	date,
	close,
	LEAD(close) OVER (PARTITION BY symbol ORDER BY date DESC),
	(close/LEAD(close) OVER (PARTITION BY symbol ORDER BY date DESC)-1.0)::NUMERIC(10,4) as pct_return
FROM year_end_prices
ORDER BY pct_return DESC
--LIMIT 100
--OVER 50
;
SELECT * FROM Annual_Return WHERE pct_return IS NOT NULL


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

SELECT symbol, EXTRACT(year from date) as year, pct_return FROM Annual_Return 
WHERE pct_return IS NOT NULL
LIMIT 100
OFFSET 50
