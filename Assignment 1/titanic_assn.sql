/*  DBase Assn 1:

    Passengers on the Titanic:
        1,503 people died on the Titanic.
        - around 900 were passengers, 
        - the rest were crew members.

    This is a list of what we know about the passengers.
    Some lists show 1,317 passengers, 
        some show 1,313 - so these numbers are not exact, 
        but they will be close enough that we can spot trends and correlations.

    Lets' answer some questions about the passengers' survival data: 
 */

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- DELETE OR COMMENT-OUT the statements in section below after running them ONCE !!
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*  Create the table and get data into it: */

DROP TABLE IF EXISTS passengers;

CREATE TABLE passengers (
    id INTEGER NOT NULL,
    lname TEXT,
    title TEXT,
    class TEXT, 
    age FLOAT,
    sex TEXT,
    survived INTEGER,
    code INTEGER
);

-- Now get the data into the database:
\COPY passengers FROM './titanic.csv' WITH (FORMAT csv);

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- DELETE OR COMMENT-OUT the statements in the above section after running them ONCE !!
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/* Some queries to get you started:  */


-- How many total passengers?:
--1312

SELECT COUNT(*) AS total_passengers FROM passengers;


-- How many survived?
--449

SELECT COUNT(*) AS survived FROM passengers WHERE survived=1;


-- How many died?
--863

SELECT COUNT(*) AS did_not_survive FROM passengers WHERE survived=0;


-- How many were female? Male?
--Female: 461
--Male: 851

SELECT COUNT(*) AS total_females FROM passengers WHERE sex='FEMALE';
SELECT COUNT(*) AS total_males FROM passengers WHERE sex='MALE';


-- How many total females died?  Males?
--Female: 154
--Male: 709

SELECT COUNT(*) AS no_survived_females FROM passengers WHERE sex='FEMALE' AND survived=0;
SELECT COUNT(*) AS no_survived_males FROM passengers WHERE sex='MALE' AND survived=0;


-- Percentage of females of the total?
--35.1371951219512%

SELECT 
    SUM(CASE WHEN sex='FEMALE' THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_female 
FROM passengers;


-- Percentage of males of the total?
--64.8628048780488%

SELECT 
    SUM(CASE WHEN sex='MALE' THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_male 
FROM passengers;


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%% Write queries that will answer the following questions:  %%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-- 1.  What percent of passengers survived? (total)
--Percent of passengers survived is 34.2225609756098%

SELECT 
    SUM(CASE WHEN survived = 1 THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_survived 
FROM passengers;

-- 2.  What percentage of females survived?     (female_survivors / tot_females)
--Percentage of females survived is 66.59436008676789587900%

SELECT 
    SUM(CASE WHEN (survived = 1 AND sex='female') THEN 1.0 ELSE 0.0 END) / 
        SUM(CASE WHEN sex='female' THEN 1.0 ELSE 0.0 END)*100 
            AS tot_pct_survived 
FROM passengers;

-- 3.  What percentage of males that survived?      (male_survivors / tot_males)
--Percentage of females survived is 16.68625146886016451200%

SELECT 
    SUM(CASE WHEN (survived = 1 AND sex='male') THEN 1.0 ELSE 0.0 END) / 
        SUM(CASE WHEN sex='male' THEN 1.0 ELSE 0.0 END)*100 
            AS tot_pct_survived 
FROM passengers;

-- 4.  How many people total were in First class, Second class, Third class, or of class unknown ?
--People total were in First class: 321
--People total were in Second class: 279
--People total were in Third class: 710
--People total of class unknown: 2

SELECT COUNT(*) AS tot_1st_class FROM passengers WHERE class='1st';
SELECT COUNT(*) AS tot_2nd_class FROM passengers WHERE class='2nd';
SELECT COUNT(*) AS tot_3rd_class FROM passengers WHERE class='3rd';
SELECT COUNT(*) AS tot_unknow_class FROM passengers WHERE class is NULL;

-- 5.  What is the total number of people in First and Second class ?
--The total number of people in First and Second class: 600

SELECT 
	SUM(CASE WHEN class='1st' OR class='2nd' THEN 1.0 ELSE 0.0 END)
	AS tot_in_1st_and_2nd
FROM passengers;

-- 6.  What are the survival percentages of the different classes? (3).
--The survival percentages of the first class: 14.6341463414634%
--The survival percentages of the second class: 9.07012195121951%
--The survival percentages of the third class: 10.5182926829268%

SELECT 
    SUM(CASE WHEN (survived = 1 AND class='1st') THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_1st_class,
	SUM(CASE WHEN (survived = 1 AND class='2nd') THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_2nd_class,
	SUM(CASE WHEN (survived = 1 AND class='3rd') THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_3rd_class
FROM passengers;



-- 7.  Can you think of other interesting questions about this dataset?
--      I.e., is there anything interesting we can learn from it?  
--      Try to come up with at least two new questions we could ask.

--      Example:
--      Can we calcualte the odds of survival if you are a female in Second Class?

--      Could we compare this to the odds of survival if you are a female in First Class?
--      If we can answer this question, is it meaningful?  Or just a coincidence ... ?

-- 		How many people under the 18 years old? And how many survived? 
--		Calcualte the odds of survival.
-- 		How many people above or equal the 65 years old? And how many survived? 
--		Calcualte the odds of survival.
		

-- 8.  Can you answer the questions you thought of above?
--      Are you able to write the query to find the answer now?  

--      If so, try to answer the question you proposed.
--      If you aren't able to answer it, try to answer the following:
--      Can we calcualte the odds of survival if you are a female in Second Class?

--      96 people under the 18 years old, and 58 survived.
--		The survival percentages of kids: 60.41666666666666666700%
--		8 people above or equal the 65 years old, only 1 of them survived
--		The survival percentages of elders: 12.5%
SELECT COUNT(*) AS tot_age_least_18 FROM passengers WHERE age<18;
SELECT COUNT(*) AS survived_kids FROM passengers WHERE age<18 AND survived = 1;
SELECT COUNT(*) AS tot_age_least_18 FROM passengers WHERE age>64;
SELECT COUNT(*) AS survived_elders FROM passengers WHERE age>64 AND survived = 1;

SELECT 
    SUM(CASE WHEN (survived = 1 AND age<18) THEN 1.0 ELSE 0.0 END) / 
        SUM(CASE WHEN age<18 THEN 1.0 ELSE 0.0 END)*100 
            AS tot_pct_survived_kids,
	SUM(CASE WHEN (survived = 1 AND age>64) THEN 1.0 ELSE 0.0 END) / 
        SUM(CASE WHEN age>64 THEN 1.0 ELSE 0.0 END)*100
            AS tot_pct_survived_elders
FROM passengers;


-- 9.  If someone asserted that your results for Question #8 were incorrect,
--     how could you defend your results, and verify that they are indeed correct?

--	1) How do we konw that number is accurate?
--	We can use below two code to show the table which ordered by the age:
--  To see youngest 
	SELECT * 
	FROM passengers
	WHERE age IS NOT NULL
	ORDER BY age;
--  To see oldest
	SELECT * 
	FROM passengers
	WHERE age IS NOT NULL
	ORDER BY age DESC;
--  Then we can easily count or check the accurate number by ourself.
	
	
--	2) Why do we need those information?
--	Some organizations, companies or government want to know hom many kids and elders died in the accident.
--	Those information also will affect Lawyers and Judges judgment.
--  In additional, it is a real data that let people know the survival percentages of kids and elders in the accident.


/*
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Email me ONLY this document - as an attachment.  You may just fill in your answers above.

    Do NOT send any other format except for one single .sql file.

    ZIP folders, word documents, and any other format (other than .sql) will receive zero credit.

    Do NOT copy and paste your queries into the body of the email.

    Your sql should run without errors - please test it beforehand.

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/


