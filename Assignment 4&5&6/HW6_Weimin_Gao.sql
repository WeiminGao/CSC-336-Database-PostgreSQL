--
--CSC 336: Database
-- Assignment 6
--

--1.
--pg_dump -U postgres -d homework > C:\backup.sql
--pg_dump -U postgres -d homework -t awesome_performers > C:\backup2.sql
--psql -U postgres -f backup.sql

--2.
DROP VIEW IF EXISTS my_portfolio_view;

CREATE VIEW my_portfolio_view AS
	SELECT p.symbol, date, open, close, low, high volume
	FROM prices p
	INNER JOIN final_result f
	ON p.symbol = f.symbol
	ORDER BY date DESC
;

--3.
--pg_dump -U postgres -d homework -t my_portfolio_view > C:\my_portfolio_backup.sql
--psql -U postgres -d homework -tAF, -f C:\my_portfolio_backup.sql > C:\my_portfolio_view.csv

--I use copy to create my csv file
--COPY (SELECT * FROM my_portfolio_view) TO 'C:\my_portfolio_view.csv' (format csv);

--4.
DROP VIEW IF EXISTS my_portfolio_annual_return_view;

CREATE VIEW my_portfolio_annual_return_view AS
	SELECT a.symbol, a.year, pct_return
	FROM awesome_performers a
	LEFT JOIN final_result f
	ON a.symbol = f.symbol
;

SELECT * FROM my_portfolio_annual_return_view ORDER BY pct_return DESC;
SELECT * FROM my_portfolio_annual_return_view WHERE year = 2016;
SELECT SUM (pct_return) AS total_return FROM my_portfolio_annual_return_view;