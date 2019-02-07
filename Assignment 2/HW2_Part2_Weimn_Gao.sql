--
--CSC 336: Database
-- Assignment II
--

--Part I: The Schema.
--2. Is this database in Normal Form?
--	If so, which one is it in? 1NF, 2NF, 3NF?
--	If not, what is preventing it from being normalized? Can it be normalized?

--Answer: This database is in Normal Form:	
--	1)The "city" table is 1NF. As per the rule of first normal form, 
--	  an attribute (column) of a table cannot hold multiple values. 
--	  It should hold only atomic values.
--	2) The "country" table and the "countrylanguage" table are 3NF. A table design is said to be in 3NF if both the following conditions hold:
--		  Table must be in 2NF
--		  Transitive functional dependency of non-prime attribute on any super key should be removed.
--	   An attribute that is not part of any candidate key is known as non-prime attribute.
--	   A table is in 3NF if it is in 2NF and for each functional dependency X-> Y at least one of the following conditions hold:
--		  X is a super key of table (EX: {code, capital, name, continent. region,...})
--		  Y is a prime attribute of table (EX: {countrycode})

--Part II: Queries.
--1. What are the top ten countries by economic activity (Gross National Product - ‘gnp’).
SELECT name,gnp FROM country --(or SELECT * FROM country to see all information)
ORDER BY gnp DESC
LIMIT 10;

--2. What are the top ten countries by GNP per capita? (watch out for division by zero here !)
SELECT 							--(or SELECT * to see all information)
	name, gnp, capital,               
	gnp / population AS GNP_per_capita
FROM country
WHERE capital != 0
ORDER BY gnp/population DESC
LIMIT 10;

--3. What are the ten most densely populated countries, and ten least densely populated countries?
SELECT 
	name, population
FROM country
ORDER BY population DESC
LIMIT 10;
--
SELECT 
	name, population
FROM country
ORDER BY population
LIMIT 10;

--4. What different forms of government are represented in this data? (‘DISTINCT’ keyword should help here.)
--	 Which forms of government are most frequent? (distinct, count, group by order by)
SELECT DISTINCT governmentform FROM country  --(note: SELECT COUNT (DISTINCT governmentform) FROM country)
--
SELECT governmentform, COUNT (governmentform)
FROM country
GROUP BY governmentform
ORDER BY COUNT (governmentform) DESC;

--5. Which countries have the highest life expectancy? (watch for NULLs).
SELECT name,lifeexpectancy
FROM country
WHERE lifeexpectancy IS NOT NULL
ORDER BY lifeexpectancy DESC;


--6. What are the top ten countries by total population, and what is the official language 
--	 spoken there? (basic inner join)
SELECT name, population, language, isofficial
FROM country INNER JOIN countrylanguage
	 ON country.code = countrylanguage.countrycode
WHERE isofficial = true
ORDER BY population DESC
LIMIT 10;

-- 7. What are the top ten most populated cities – along with which country they are in,
--	  and what continent they are on? (basic inner join)
SELECT city.name, city.population, country.name, continent
FROM city INNER JOIN country
	 ON city.countrycode = country.code
ORDER BY population DESC
LIMIT 10;

--8. What is the official language of the top ten cities you found in Question #7? (three-way inner join).
SELECT city.name, city.population, country.name, continent, language, isofficial
FROM city 
	 INNER JOIN country
	 ON city.countrycode = country.code
	 INNER JOIN countrylanguage
	 ON country.code = countrylanguage.countrycode
WHERE isofficial = true
ORDER BY city.population DESC
LIMIT 10;

--9. Which of the cities from Question #7 are capitals of their country? (requires a join and a subquery).
SELECT *
FROM
	(SELECT city.name, city.population, 
			country.name AS countryName, continent
	 FROM city LEFT JOIN country
	 	ON city.id = country.capital
	 ORDER BY city.population DESC
	 LIMIT 10) AS iscapitals
WHERE countryName IS NOT NULL;

--10. For the cities found in Question#7, what percentage of the country’s population
--	  lives in the capital city? (watch your int’s vs floats !).
SELECT *,
	   CAST(population AS FLOAT) / CAST(countryPopulation AS FLOAT) *100 
	   AS percent_of_countPopu_in_capCity
FROM
	(SELECT city.name, city.population, 
	 		country.name AS countryName, 
	 		country.population AS countryPopulation
	 FROM city LEFT JOIN country
	 	ON city.id = country.capital
	 ORDER BY city.population DESC
	 LIMIT 10) AS iscapitals
WHERE countryName IS NOT NULL;

