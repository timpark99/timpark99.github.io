-- demonstrate subqueries to show all data for employees who are in department_id 1

SELECT *
FROM PortfolioProject.dbo.employee_demographics
WHERE employee_id IN
                (SELECT employee_id
                    FROM PortfolioProject.dbo.employee_salary
                    WHERE dept_id = 1)

-- demonstrate subqueries to show a side by side comparison of each person's salary with the average salary in the office

SELECT first_name, salary,
(SELECT AVG(salary)
FROM employee_salary)
FROM employee_salary

-- demonstrate subqueries to find the average of a table that has already performed aggregated functions

SELECT AVG(max_age)
FROM 
(SELECT gender, AVG(age) AS avg_age, MAX(age) AS max_age, MIN(age) AS min_age, COUNT(age) AS count_age
FROM employee_demographics
GROUP BY gender) AS agg_table -- table has to be named when using subqueries

-- demonstrate case statement to create an age bracket

SELECT first_name, last_name, age,
CASE
    WHEN age<= 30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >= 50 THEN 'On Deaths Door'
END AS age_bracket
FROM employee_demographics

-- Pay increase and bonus
-- if they made < 50,000 then a 5% raise
-- if they made > 50,000 then a 7% raise
-- if they worked in the finance department then it's a 10% bonus
-- demonstrate case statements to satisfy these raises and bonuses

SELECT first_name, last_name, salary,
CASE
    WHEN salary < 50000 THEN salary + (salary*0.05)
    WHEN salary > 50000 THEN salary + (salary*0.07)
END AS new_salary,
CASE
    WHEN dept_id = 6 THEN salary * 0.1
END AS Bonus
FROM employee_salary

-- demonstrate the use of LEN to see the length of characters in first_name

SELECT first_name, LEN(first_name)
FROM employee_demographics
ORDER BY 2

-- demonstrate the use of UPPER and LOWER to change capitalization

SELECT first_name, UPPER(first_name), LOWER(first_name)
FROM employee_demographics
ORDER BY 1

-- demonstrate the use of TRIM, LTRIM, and RTRIM to get rid of white spaces

SELECT TRIM('         sky        ')
SELECT LTRIM('         sky        ')
SELECT RTRIM('         sky        ') 

-- LEFT and RIGHT will only show the number of characters you specify from the left most or right most
-- SUBSTRING will show middle characters that you specify - a good use case would be pulling months from a date

SELECT first_name, 
LEFT(first_name, 4),
RIGHT(first_name, 4),
SUBSTRING(first_name,3,2),
birth_date,
SUBSTRING(CONVERT(char(15),birth_date,121),6,2) AS birth_month -- third argument in CONVERT is the optional style for correct date format.  CONVERT must be done because SUBSTRING only works on characters.
FROM employee_demographics

-- REPLACE replaces a character with a character that you specify

SELECT first_name, REPLACE(first_name, 'a', 'z')
FROM employee_demographics

-- use CHARINDEX to locate the position of the string
-- you can put this into a CTE or a temp table and then filter down based on these results where it only equals 1

SELECT first_name, CHARINDEX('An', first_name)
FROM employee_demographics

-- CONCAT would be useful to combine first and last name into one column

SELECT first_name, last_name,
CONCAT(first_name, ' ', last_name) AS full_name
FROM employee_demographics

-- UNION will stack rows on top of each other distinctly

SELECT first_name, last_name
FROM employee_demographics
UNION
SELECT first_name, last_name
FROM employee_salary

-- UNION ALL will include duplicates

SELECT first_name, last_name
FROM employee_demographics
UNION ALL
SELECT first_name, last_name
FROM employee_salary

-- the office must identify older employees and highly paid employees to cut from the company
-- using UNIONs we can accomplish that

SELECT first_name, last_name, 'Old Man' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid Employee' AS Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name

-- inner join will only bring in the rows where both tables share the same information after the ON statement
-- ron swanson is not included in an inner join

SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
    ON dem.employee_id = sal.employee_id

-- outer join can be left or right

SELECT *
FROM employee_demographics AS dem -- this is the left table
RIGHT JOIN employee_salary AS sal -- this is the right table
    ON dem.employee_id = sal.employee_id

-- self join will give us a secret santa by moving 1 position in the employee_id

SELECT emp1.employee_id AS emp_santa,
emp1.first_name AS first_name_santa,
emp1.last_name AS last_name_santa,
emp2.employee_id AS emp_name,
emp2.first_name AS first_name_emp,
emp2.last_name AS last_name_emp
FROM employee_salary emp1
JOIN employee_salary emp2
    ON emp1.employee_id + 1 = emp2.employee_id

-- joining multiple columns together even though employee_demographics cannot tie with parks_departments

SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
    ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments pd
    ON sal.dept_id = pd.department_id

-- this will only keep the top 3 oldest from the table

SELECT TOP 3 *
FROM employee_demographics
ORDER BY age DESC

-- HAVING comes after GROUP BY to filter

SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40

-- HAVING only works on aggregated functions after GROUP BY
-- the LIKE function will filter to all occupations with the word 'manager'

SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager'
GROUP BY occupation
HAVING AVG(salary) > 75000

-- window function similar to GROUP BY but with every person
-- advantage of a window function: allows you to see other pieces of data
-- you can use ORDER BY in the window function to create a rolling total

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_Total
FROM employee_demographics dem
JOIN employee_salary sal
    ON dem.employee_id = sal.employee_id

-- ROW_NUMBER, RANK, and DENSE_RANK are all similar
-- here we partitition by the gender and order by salary and assign each a row number, rank or dense rank

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS dense_rank_num
FROM employee_demographics dem
JOIN employee_salary sal
    ON dem.employee_id = sal.employee_id

-- CTE stands for common table expression
-- you can only use a CTE immediately after you create it

WITH CTE_Example AS
(
SELECT gender, AVG(salary) avg_salary, MAX(salary) max_salary, MIN(salary) min_salary, COUNT(salary) count_salary
FROM employee_demographics dem
JOIN employee_salary sal
    ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_salary)
FROM CTE_Example

-- using multiple CTEs example

WITH CTE_Example AS
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_Example2 AS
(
SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_Example
JOIN CTE_Example2
    ON CTE_Example.employee_id = CTE_Example2.employee_id

-- instead of using aliases to title the columns we can put the aliases in the CTE expression

WITH CTE_Example (Gender, AVG_SAL, MAX_SAL, MIN_SAL, COUNT_SAL) AS
(
SELECT gender, AVG(salary) avg_salary, MAX(salary) max_salary, MIN(salary) min_salary, COUNT(salary) count_salary
FROM employee_demographics dem
JOIN employee_salary sal
    ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT *
FROM CTE_Example

-- temp tables

CREATE TABLE #temp_table
(
first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
)

SELECT *
FROM #temp_table