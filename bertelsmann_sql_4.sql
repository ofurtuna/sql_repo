-- Cleaning data with SQL --

--Use the accounts table and a CASE statement to create two groups: one group
--of company names that start with a number and a second group of company names
--that start with a letter. What proportion of company names start with a letter?
SELECT groups, COUNT(*)
FROM
(SELECT
CASE
WHEN LEFT(name, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
THEN 'number'
ELSE 'letter'
END as groups
FROM accounts) x
GROUP BY groups;
-- alternative
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                       THEN 1 ELSE 0 END AS num,
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;


--Consider vowels as a, e, i, o, and u. What proportion of company names start
--with a vowel, and what percent start with anything else?
SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                        THEN 1 ELSE 0 END AS vowels,
          CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U')
                       THEN 0 ELSE 1 END AS other
         FROM accounts) t1;

--Use the accounts table to create first and last name columns that hold the
--first and last names for the primary_poc.
SELECT
LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS first,
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))AS last,
primary_poc from accounts LIMIT 2;

-----------------------------------------------------------------------------
-- Use CONCAT
--Each company in the accounts table wants to create an email address for each
--primary_poc. The email address should be the first name of the primary_poc .
--last name primary_poc @ company name .com.
SELECT
LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) ||'.'||
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))||'@' ||
replace(name, ' ', '')||'.com'
as email from accounts

--We would also like to create an initial password, which they will change
--after their first log in. The first password will be the first letter of the
--primary_poc's first name (lowercase), then the last letter of their first name
--(lowercase), the first letter of their last name (lowercase), the last letter
--of their last name (lowercase), the number of letters in their first name, the
-- number of letters in their last name, and then the name of the company they
--are working with, all capitalized with no spaces.
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

-----------------------------------------------------------------------------
-- Use CAST
-- Get  date out of string "01/31/2014 08:00:00 AM +0000"
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' ||
SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;
-- equivalent
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' ||
SUBSTR(date, 4, 2))::DATE new_date FROM sf_crime_data;











-------------------------------------------------------------------------------
-- Use COALESCE (to label nulls differently (as 0 or empty strings)
-- ONe case is when you want nulls as 0; another is when you have unmatched rows
-- after a join and you want them to display sth other than a null

-- Note! By using COALESCE we have filled null values and now we get some value
-- in each cell, so we get more results from COUNT()

-- examples
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- Use COALESCE to fill in the accounts.id column with the account_id column from
-- the other table in that one case where the first is missing
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

SELECT COALESCE(a.id, a.id) filled_id,
a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,
COALESCE(o.account_id, a.id) account_id,
o.occurred_at, o.standard_qty, o.gloss_qty, o.poster_qty, o.total,
o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- Fill in qty and usd with 0
SELECT COALESCE(a.id, a.id) filled_id,
a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,
COALESCE(o.account_id, a.id) account_id, o.occurred_at,
COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty,
COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total,
COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd,
COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
