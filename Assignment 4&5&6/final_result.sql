--High net worth growth year-over-year.
DROP TABLE IF EXISTS awesome_fundamentals;

CREATE TEMP TABLE awesome_fundamentals as 
SELECT 
	awesome_performers.symbol,
	fundamentals.year,
	net_income,
	total_assets,
	total_liabilities,
	total_revenue,
	earnings_per_share,
	cash_and_cash_equivalents
FROM awesome_performers
	INNER JOIN fundamentals
	ON awesome_performers.symbol = fundamentals.symbol
;

CREATE TEMP TABLE get_net_worth as
SELECT
	symbol,
	year,
	(total_assets - total_liabilities) AS net_worth
FROM awesome_fundamentals
;

CREATE TEMP TABLE get_net_worth_growth as
SELECT
	symbol,
	year,
	net_worth,
	(CAST(net_worth AS FLOAT)/ 
	(CAST(LEAD(net_worth) OVER (PARTITION BY symbol ORDER BY year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS net_worth_growth
FROM get_net_worth
ORDER BY net_worth_growth DESC
;

SELECT * 
FROM get_net_worth_growth
WHERE net_worth_growth IS NOT null AND net_worth_growth != 0;

--High net income growth year-over-year?
CREATE TEMP TABLE get_net_income_growth as
SELECT
	symbol,
	year,
	net_income,
	(CAST(net_income AS FLOAT)/ 
	(CAST(LEAD(net_income) OVER (PARTITION BY symbol ORDER BY year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS net_income_growth
FROM awesome_fundamentals
ORDER BY net_income_growth DESC
;

SELECT * 
FROM get_net_income_growth
WHERE net_income_growth IS NOT null AND net_income_growth != 0;

--High revenue growth year-over-year?
CREATE TEMP TABLE get_revenue_growth as
SELECT
	symbol,
	year,
	total_revenue,
	(CAST(total_revenue AS FLOAT)/ 
	(CAST(LEAD(total_revenue) OVER (PARTITION BY symbol ORDER BY year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS revenue_growth
FROM awesome_fundamentals
ORDER BY revenue_growth DESC
;

SELECT * 
FROM get_revenue_growth
WHERE revenue_growth IS NOT null AND revenue_growth != 0;

--High earnings-per-share (eps) growth?
CREATE TEMP TABLE get_earnings_per_share_growth as
SELECT
	symbol,
	year,
	earnings_per_share,
	(CAST(earnings_per_share AS FLOAT)/ 
	(CAST(LEAD(earnings_per_share) OVER (PARTITION BY symbol ORDER BY year DESC) AS FLOAT)) 
	-1.0)::NUMERIC(10,4) AS earnings_per_share_growth
FROM awesome_fundamentals
ORDER BY earnings_per_share_growth DESC
;

SELECT * 
FROM get_earnings_per_share_growth
WHERE earnings_per_share_growth IS NOT null AND earnings_per_share_growth != 0;

--Low price-to-earnings ratio ?

---I forgot to ask that close is share price or not---
---And I modified my awesome_fundamentals table, I just add close to table.
DROP TABLE IF EXISTS new_awesome_fundamentals;

CREATE TEMP TABLE new_awesome_fundamentals as 
SELECT 
	awesome_performers.symbol,
	fundamentals.year,
	close,
	earnings_per_share
FROM awesome_performers
	INNER JOIN fundamentals
	ON awesome_performers.symbol = fundamentals.symbol
	AND awesome_performers.year = fundamentals.year
;

SELECT
	symbol,
	year,
	close,
	earnings_per_share,
	(CAST (close AS FLOAT) / CAST (earnings_per_share AS FLOAT)
	-1.0)::NUMERIC(10,4) AS pe_ratio
FROM new_awesome_fundamentals
WHERE earnings_per_share IS NOT NULL
ORDER BY pe_ratio
;

--Amount of liquid cash in the bank vs. total liabilities?

SELECT
	symbol,
	year,
	(CAST (cash_and_cash_equivalents AS FLOAT) / CAST (total_liabilities AS FLOAT)
	-1.0)::NUMERIC(10,4) AS liquid_cash_vs_total_liabilities
FROM awesome_fundamentals
ORDER BY liquid_cash_vs_total_liabilities DESC
;

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

CREATE TABLE final_result AS
	SELECT * 
	FROM final_analyse
	WHERE good_total IS NOT NULL AND symbol NOT LIKE 'EW' AND symbol NOT ILIKE 'REGN' AND symbol NOT LIKE 'ISRG'
	ORDER BY good_total DESC
	LIMIT 10
	OFFSET 10
;