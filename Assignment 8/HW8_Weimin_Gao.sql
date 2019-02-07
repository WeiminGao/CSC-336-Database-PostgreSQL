--
--CSC 336: Database
-- Assignment 8
--
DROP TABLE IF EXISTS companies_risk_report;

CREATE TABLE companies_risk_report (
    ID INTEGER NOT NULL,
    IR CHARACTER(1),
    MR CHARACTER(1),
    FF CHARACTER(1),
    CR CHARACTER(1),
    CO CHARACTER(1),
    OP CHARACTER(1),
	class CHARACTER(2)
);

COPY ids FROM 'C:/ids.csv' WITH (FORMAT csv);

--Generate a "risk score" for each company:
DROP TABLE IF EXISTS get_risk_score;

CREATE TEMP TABLE get_risk_score as
SELECT *, (CASE WHEN IR='N' THEN 1 ELSE 0 END)+
		(CASE WHEN MR='N' THEN 1 ELSE 0 END)+
		(CASE WHEN FF='N' THEN 1 ELSE 0 END)+
		(CASE WHEN CR='N' THEN 1 ELSE 0 END)+
		(CASE WHEN CO='N' THEN 1 ELSE 0 END)+
		(CASE WHEN OP='N' THEN 1 ELSE 0 END) AS risk_score
FROM companies_risk_report
;

--Using a Decision Tree approach, classify each company into one of the four groups.
--Note: Risk level (1 2 3 4) represent as (Low, Medium, Medium-High, High)
DROP TABLE IF EXISTS get_risk_level;

CREATE TEMP TABLE get_risk_level as
SELECT *,
		(CASE WHEN risk_score <= 2 THEN 1
			WHEN risk_score < 4 THEN 2
			WHEN risk_score < 5 THEN 3
			ELSE 4
		END) AS risk_levels
FROM get_risk_score
;

--Report the number of companies at each risk level from the bankrupt group.
SELECT COUNT(*) AS num_of_companies, risk_levels
FROM get_risk_level
WHERE class = 'B'
GROUP BY risk_levels
;

--Report the number of companies at each risk level from the non-bankrupt group.
SELECT COUNT(*) AS num_of_companies, risk_levels
FROM get_risk_level
WHERE class = 'NB'
GROUP BY risk_levels
;

--Make a report of currently operating companies that are at a risk level of 'Medium' or higher.
SELECT *
FROM get_risk_level
WHERE class = 'NB' AND risk_levels >= 2
;
--OR create VIEW to monitor these potential "high risk" currently operating companies.
DROP VIEW IF EXISTS potential_risk_companies;

CREATE VIEW  AS potential_risk_companies
	SELECT *
	FROM get_risk_level
	WHERE class = 'NB' AND risk_levels >= 2
	;