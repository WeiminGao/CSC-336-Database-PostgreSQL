--
--CSC 336: Database
-- Assignment 5
--
----Question 2 and Question 3----------------------------

--I create an analyse_table to combine all queries (I did not include pe ratio because I probably did wrong)
--Then sum of these result to get the good_total
--Select a group of 10-20 which eliminate a few from the very top.
DROP TABLE IF EXISTS analyse_table;
DROP TABLE IF EXISTS final_analyse;

CREATE TEMP TABLE analyse_table as
SELECT
	a.symbol,
	a.year,
	(CAST(net_worth AS FLOAT)/ 
	(CAST(LEAD(net_worth) OVER (PARTITION BY a.symbol ORDER BY a.year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS net_worth_growth,
	(CAST(net_income AS FLOAT)/ 
	(CAST(LEAD(net_income) OVER (PARTITION BY a.symbol ORDER BY a.year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS net_income_growth,
	(CAST(total_revenue AS FLOAT)/ 
	(CAST(LEAD(total_revenue) OVER (PARTITION BY a.symbol ORDER BY a.year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS revenue_growth,
	(CAST(earnings_per_share AS FLOAT)/ 
	(CAST(LEAD(earnings_per_share) OVER (PARTITION BY a.symbol ORDER BY a.year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS earnings_per_share_growth,
	(CAST (cash_and_cash_equivalents AS FLOAT) / CAST (total_liabilities AS FLOAT)
	-1.0)::NUMERIC(10,4) AS liquid_cash_vs_total_liabilities
FROM awesome_fundamentals a
	 INNER JOIN get_net_worth b
	 ON a.symbol = b.symbol
	 AND a.year = b.year
;
CREATE TEMP TABLE final_analyse as 
SELECT
	 symbol,
	 year,
	 net_worth_growth + earnings_per_share_growth + revenue_growth 
	 + net_income_growth + liquid_cash_vs_total_liabilities AS good_total
FROM analyse_table
;
	 
SELECT * 
FROM final_analyse
WHERE good_total IS NOT NULL
ORDER BY good_total DESC
LIMIT 15
OFFSET 10
;

--Based on final_analyse my list of ten potential candidates:
--CCI, Real Estate
--AAL, Airlines
--ALXN, Health Care
--ILMN, Health Care
--EMN, Materials
--INTU, Information Technology
--EW, Health Care --x--
--REGN, Health Care --x--
--CXO, Energy
--ULTA, Specialty Stores

--Because Health Care area has 4 candidates
--I choose another two:
--LUV, Airlines
--AKAM,Information Technology