SELECT occurred_at, account_id, channel
    FROM web_events
ORDER BY occurred_at ASC
LIMIT 15;


SELECT id, account_id, total_amt_usd
    FROM orders
ORDER BY occurred_at ASC
LIMIT 10;

SELECT id, account_id, total_amt_usd
    FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

SELECT id, account_id,
        total_amt_usd
    FROM orders
ORDER BY account_id ASC, total_amt_usd DESC
LIMIT 20;

--Pull the first 5 rows and all columns from the orders table that have a dollar
--amount of gloss_amt_usd greater than or equal to 1000.

SELECT *
    FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5

--Use the accounts table to find all companies whose names contain the string
-- 'one' somewhere in the name.
SELECT *
FROM accounts
WHERE name LIKE '%one%'

--Use the accounts table to find the account name, primary_poc, and
--sales_rep_id for Walmart, Target, and Nordstrom.
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ("Walmart", "Target", "Nordstrom")

--Returns all the orders where the standard_qty is over 1000, the poster_qty is 0,
-- and the gloss_qty is 0.
SELECT *
FROM accounts
WHERE (name NOT LIKE 'C%') AND (name LIKE '%s');
--Use the web_events table to find all information regarding individuals who
--were contacted via organic or adwords and started their account at any point
--in 2016 sorted from newest to oldest.
SELECT *
FROM web_events
WHERE channel IN ('organic','adwords')
AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
           AND primary_poc NOT LIKE '%eana%');
-------------------------------------------------------------------------
-- JOINS

SELECT orders.*,
       accounts.*
    FROM demo.orders
    JOIN demo.accounts
      ON orders.account_id = accounts.id

SELECT *
    FROM web_events
    JOIN accounts
      ON web_events.account_id = accounts.id
      JOIN orders
      ON accounts.id = orders.account_id
/*
-- Alias examples
FROM tablename AS t1
JOIN tablename2 AS t2
FROM tablename t1
JOIN tablename2 t2

SELECT col1 + col2 AS total, col3
SELECT col1 + col2 total, col3

Select t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2

*/
SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';

SELECT s.name, r.name, a.name
FROM sales_reps as s
JOIN accounts as a
ON s.id = a.sales_rep_id
JOIN region as r
ON s.region_id = r.id
ORDER BY a.name

/*
Provide the name for each region for every order,
as well as the account name and the unit price they paid (total_amt_usd/total)
for the order. Your final table should have 3 columns: region name,
account name, and unit price. A few accounts have 0 for total, so I divided by
(total + 0.01) to assure not dividing by zero.
*/
SELECT r.name, a.name, o.total_amt_usd/(o.total+0.01) AS price
FROM orders as o
JOIN accounts as a
ON a.id = o.account_id
JOIN sales_reps
ON a.sales_rep_id = sales_reps.id
JOIN region as r
ON sales_reps.region_id = r.id


-- check all orders brought in by a particular sales rep
SELECT orders.*
        accounts.*
    FROM demo.orders
    LEFT JOIN demo.accounts
        ON orders.account_id = accounts.id
    WHERE accounts.sales_rep_id = 321500
-- move filtering logic from WHERE to ON clause
-- to reduce rows BEFORE the JOIN is done; this effectively pre-filters
-- the right table before the JOIN is executed
    SELECT orders.*
            accounts.*
        FROM demo.orders
        LEFT JOIN demo.accounts
            ON orders.account_id = accounts.id
            AND accounts.sales_rep_id = 321500

----------------------------------------------------
/*Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for the Midwest region. Your final table
should include three columns: the region name, the sales rep name, and the
account name. Sort the accounts alphabetically (A-Z) according to account name.*/
SELECT s.name AS sales_rep,
    r.name AS region,
    a.name AS account
FROM sales_reps as s
JOIN region as r
 ON s.region_id = r.id
 AND r.name = 'Midwest'
    JOIN accounts as a
    ON s.id = a.sales_rep_id
ORDER BY a.name

/*Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for accounts where the sales rep has a
first name starting with S and in the Midwest region. Your final table should
include three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT s.name AS sales_rep,
    r.name AS region,
    a.name AS account
FROM
(SELECT * FROM sales_reps
WHERE sales_reps.name LIKE 'S%') s
JOIN region as r
 ON s.region_id = r.id
 AND r.name = 'Midwest'
    JOIN accounts as a
    ON s.id = a.sales_rep_id
ORDER BY a.name

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
    JOIN region r
    ON s.region_id = r.id
    JOIN accounts a
    ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;

/*
Provide a table that provides the region for each sales_rep along with their
associated accounts. This time only for accounts where the sales rep has a last
name starting with K and in the Midwest region. Your final table should include
three columns: the region name, the sales rep name, and the account name.
Sort the accounts alphabetically (A-Z) according to account name.
*/
SELECT s.name AS sales_rep,
    r.name AS region,
    a.name AS account
FROM
(SELECT * FROM sales_reps
WHERE sales_reps.name LIKE '% K%') s
JOIN region as r
 ON s.region_id = r.id
 AND r.name = 'Midwest'
    JOIN accounts as a
    ON s.id = a.sales_rep_id
ORDER BY a.name

/*
Provide the name for each region for every order, as well as the account name
and the unit price they paid (total_amt_usd/total) for the order. However, you
should only provide the results if the standard order quantity exceeds 100.
Your final table should have 3 columns: region name, account name, and unit price.
In order to avoid a division by zero error, adding .01 to the denominator here
is helpful total_amt_usd/(total+0.01).
*/
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) AS price
FROM orders as o
JOIN accounts as a
    ON a.id = o.account_id
    AND o.standard_qty > 100
JOIN sales_reps
ON a.sales_rep_id = sales_reps.id
JOIN region as r
ON sales_reps.region_id = r.id

/*
Provide the name for each region for every order, as well as the account name
and the unit price they paid (total_amt_usd/total) for the order. However, you
should only provide the results if the standard order quantity exceeds 100 and
the poster order quantity exceeds 50. Your final table should have 3 columns:
region name, account name, and unit price. Sort for the smallest unit price first.
In order to avoid a division by zero error, adding .01 to the denominator here
is helpful (total_amt_usd/(total+0.01).
*/
SELECT r.name region, a.name account, o.total_amt_usd/(o.total+0.01) price
FROM orders as o
JOIN accounts as a
    ON a.id = o.account_id
    AND o.standard_qty > 100
    AND o.poster_qty > 50
JOIN sales_reps
ON a.sales_rep_id = sales_reps.id
JOIN region as r
ON sales_reps.region_id = r.id
ORDER BY price

/*
What are the different channels used by account id 1001? Your final table should
 have only 2 columns: account name and the different channels. You can try SELECT
 DISTINCT to narrow down the results to only the unique values.
*/
SELECT DISTINCT w.channel, a.name
    FROM web_events as w
    JOIN accounts as a
    ON a.id = w.account_id
    AND a.id = 1001

/*
Find all the orders that occurred in 2015. Your final table should have 4
columns: occurred_at, account name, order total, and order total_amt_usd.
*/
SELECT o.occurred_at, o.total, o.total_amt_usd, a.name
    FROM
    (SELECT * FROM orders
    WHERE EXTRACT(YEAR FROM occurred_at) = 2015) o
    JOIN accounts as a
    ON a.id = o.account_id

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;


---------------------------------
-- NULLS
SELECT *
    FROM accounts
  WHERE primary_poc IS NULL
/*
Though this is more advanced than what we have covered so far try finding -
what is the MEDIAN total_usd spent on all orders.
Since there are 6912 orders - we want the average of the 3457 and 3456 order
amounts when ordered. This is the average of 2483.16 and 2482.55. This gives
the median of 2482.855. This obviously isn't an ideal way to compute.
If we obtain new orders, we would have to change the limit.
*/
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;















