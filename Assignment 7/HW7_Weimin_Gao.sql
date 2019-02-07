--
--CSC 336: Database
-- Assignment 7
--
DROP TABLE IF EXISTS census;

CREATE TABLE census (
    Zip_Code NUMERIC(5) NOT NULL,
    Total_Population INTEGER,
    Median_Age NUMERIC(3,1),
    Total_Males INTEGER, 
    Total_Females INTEGER,
    Total_Households INTEGER,
    Average_Household_Size NUMERIC(2,1)
);

COPY census FROM 'C:/census.csv' WITH (FORMAT csv);

DROP TABLE IF EXISTS target_table;

CREATE TEMP TABLE target_table as
SELECT
	*,
	CAST(Total_Males AS FLOAT) / CAST(Total_Population AS FLOAT) * 100 AS pct_male,
	CAST(Total_Females AS FLOAT) / CAST(Total_Population AS FLOAT) * 100 AS pct_female
FROM census
WHERE Total_Population != 0 AND Zip_Code = 93591
;

DROP TABLE IF EXISTS main_table;

CREATE TEMP TABLE main_table as
SELECT
	*,
	CAST(Total_Males AS FLOAT) / CAST(Total_Population AS FLOAT) * 100 AS pct_male,
	CAST(Total_Females AS FLOAT) / CAST(Total_Population AS FLOAT) * 100 AS pct_female
FROM census
WHERE Total_Population != 0 AND Zip_Code != 93591
;

--SELECT DISTINCT ON (m.zip_code)
--	m.zip_code,
--	m.median_age,
--	m.pct_male,
--	m.average_household_size,
--	t.zip_code,
--	t.median_age,
--	t.pct_male,
--	t.average_household_size
--FROM main_table m
--CROSS JOIN target_table t
--;

SELECT DISTINCT ON (three_d_demograp_distance_btw_target)
	m.zip_code,
	|/((m.median_age-t.median_age)^2 + 
	(m.pct_male-t.pct_male)^2 + 
	(m.average_household_size-t.average_household_size)^2) AS three_d_demograp_distance_btw_target
FROM main_table m
CROSS JOIN target_table t
ORDER BY three_d_demograp_distance_btw_target DESC
LIMIT 10
;