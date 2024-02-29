-- demonstrate subqueries to show conferences who have teams that won more than 28 games in the 23' season

SELECT DISTINCT(CONF)
FROM cbb23
WHERE CONF IN
        (SELECT CONF
            FROM cbb23
            WHERE W > 28)

-- demonstrates subqueries to show average wins by conference and comparing to overall ncaa wins

SELECT DISTINCT(CONF), AVG(W) AS average_wins,
(SELECT AVG(W)
FROM cbb23) AS average_ncaa_wins
FROM cbb23
GROUP BY CONF

-- demonstrates subqueries to solve for the average of the max orbs in each conference

SELECT AVG(max_orb) as avg_max_orb
FROM
(SELECT CONF, AVG(ORB) AS avg_orb, MAX(ORB) AS max_orb, MIN(ORB) AS min_orb
FROM cbb23
GROUP BY CONF) AS agg_table

-- demonstrates the case statement used to measure a team's 3 point percentage category

SELECT TEAM, CONF, _3P_O,
CASE
    WHEN _3P_O < 30 THEN 'Poor 3-Point shooting team'
    WHEN _3P_O BETWEEN 30 AND 35 THEN 'Average 3-Point shooting team'
    WHEN _3P_O > 35 THEN 'Proficient 3-Point shooting team'
END AS three_point_bracket
FROM cbb23

-- the NCAA is awarding $10,000 for teams that have wins between 20 and 25
-- and awarding $15,000 for teams that have wins between 26 and 30
-- demonstrate the use of CASE statements to indicate awarded teams

SELECT TEAM, CONF, W,
CASE
    WHEN W BETWEEN 20 AND 25 THEN 10000
    WHEN W BETWEEN 26 AND 30 THEN 15000
END AS Bonus
FROM cbb23

-- demonstrate the use of LEN to see the length of characters in TEAM

SELECT TEAM, LEN(TEAM)
FROM cbb23
ORDER BY 2

-- demonstrate the use of UPPER and LOWER to change capitalization

SELECT TEAM, UPPER(TEAM), LOWER(TEAM)
FROM cbb23
ORDER BY 1

-- demonstrate the use of TRIM, LTRIM, and RTRIM to get rid of white spaces

SELECT TRIM('         sky        ')
SELECT LTRIM('         sky        ')
SELECT RTRIM('         sky        ') 

-- LEFT and RIGHT will only show the number of characters you specify from the left most or right most
-- SUBSTRING will show middle characters that you specify - a good use case would be pulling months from a date

SELECT TEAM, 
LEFT(TEAM, 4),
RIGHT(TEAM, 4),
SUBSTRING(TEAM,3,2)
FROM cbb23

-- REPLACE replaces a character with a character that you specify

SELECT TEAM, REPLACE(TEAM, 'a', 'z')
FROM cbb23

-- use CHARINDEX to locate the position of the string
-- you can put this into a CTE or a temp table and then filter down based on these results where it only equals 1

SELECT TEAM, CHARINDEX('St', TEAM)
FROM cbb23

-- CONCAT would be useful to combine first and last name into one column

SELECT TEAM, CONF,
CONCAT(TEAM, ' ', CONF) AS team_conference
FROM cbb23

-- UNION will stack rows on top of each other distinctly

SELECT TEAM, CONF
FROM acc
UNION
SELECT TEAM, CONF
FROM b10

-- UNION ALL will include duplicates if there are the same TEAM and CONF in both tables.  In this situation there aren't any.

SELECT TEAM, CONF
FROM acc
UNION ALL
SELECT TEAM, CONF
FROM b10

-- the office must identify teams from the ACC and B10 who made the NCAA tournament
-- using UNIONs we can accomplish that

SELECT TEAM, CONF, 'NCAA Tournament Team' AS Label
FROM acc
WHERE SEED != 'N/A'
UNION
SELECT TEAM, CONF, 'NCAA Tournament Team' AS Label
FROM b10
WHERE SEED != 'N/A'
ORDER BY CONF

-- inner join will only bring in the rows where both tables share the same information after the ON statement
-- shows which teams earned the same amount of wins

SELECT acc.TEAM, acc.CONF, acc.W, b10.TEAM, b10.CONF, b10.W
FROM acc
INNER JOIN b10
    ON acc.W = b10.W

-- outer join can be left or right

SELECT acc.TEAM, acc.CONF, acc.W, b10.TEAM, b10.CONF, b10.W
FROM acc -- this is the left table
RIGHT JOIN b10 -- this is the right table
    ON acc.W = b10.W

-- self join can modify the table to offset by 1

SELECT acc.W AS acc_win,
acc.TEAM AS acc_team,
acc.CONF AS conference,
b10.W AS b10_win,
b10.TEAM AS b10_team,
b10.CONF AS conference
FROM acc
JOIN b10
    ON acc.W + 1 = b10.W

-- joining multiple columns together

SELECT *
FROM acc
INNER JOIN b10
    ON acc.W = b10.W
INNER JOIN cbb23
    ON b10.EFG_O = cbb23.EFG_O

-- this will only keep the top 3 teams by wins

SELECT TOP 3 *
FROM cbb23
ORDER BY W DESC

-- HAVING comes after GROUP BY to filter

SELECT TEAM, AVG(W)
FROM cbb23
GROUP BY TEAM
HAVING AVG(W) > 20

-- HAVING only works on aggregated functions after GROUP BY
-- the LIKE function will filter to all teams who made it to the round of 64 with wins greater than 20

SELECT TEAM, AVG(W)
FROM cbb23
WHERE POSTSEASON LIKE '%R64'
GROUP BY TEAM
HAVING AVG(W) > 20

-- window function similar to GROUP BY but with every person
-- advantage of a window function: allows you to see other pieces of data
-- you can use ORDER BY in the window function to create a rolling total

SELECT TEAM, CONF, W,
SUM(W) OVER(PARTITION BY CONF ORDER BY TEAM) AS Rolling_Total
FROM cbb23

-- ROW_NUMBER, RANK, and DENSE_RANK are all similar
-- here we partitition by the conference and order by wins and assign each a row number, rank or dense rank

SELECT TEAM, CONF, W,
ROW_NUMBER() OVER(PARTITION BY CONF ORDER BY W DESC) AS row_num,
RANK() OVER(PARTITION BY CONF ORDER BY W DESC) AS rank_num,
DENSE_RANK() OVER(PARTITION BY CONF ORDER BY W DESC) AS dense_rank_num
FROM cbb23
