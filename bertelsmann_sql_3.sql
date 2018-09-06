-------------------------------------------------------------------------
-- SUBQUERIES and TEMPORARY TABLES
/*
First select number of web events per day and per channel.
Then average the results.
*/
SELECT day,
    channel,
    AVG(event_count)
FROM
    (SELECT DATE_TRUNC('day', occurred_at) AS day,
    channel,
    COUNT(*) AS event_count
    FROM web_events
    GROUP BY 1,2
    ) sub
GROUP BY 1
ORDER BY 2 DESC

-- Average number of events per day for each channel
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

---- Subqueries in conditional logic
-- Use subquery result to filter table (if subquery returns 1 result)
SELECT *
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
 (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
  FROM orders)
  ORDER BY occurred_at

-- Pull the first month/year combo from the orders table
SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders;

SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

----------------------------
-- Example: Finding the top channel used by each account, and how often it was used
/*
Create several tables and nest them with subqueries.
End table will have account id, web event associated with max for that account,
how often the event occurred.
T1 has the event and account of how often it occured, for
each web event, for each account.
Then, t2 has the maximum for each account.
Then, match t2 with the original table (t3) to get the rows that match.
*/
SELECT t3.id, t3.name, t3.chanel, t3.ct
FROM (SELECT a.id, a.name, w.channel, COUNT(*) ct
    FROM accounts a
    JOIN web_events w
    ON a.id = w.account_id
    GROUP BY a.id, a.name, w.channel) t3
JOIN (SELECT t1.id, t1.name, MAX(ct) max_chan
      FROM (SELECT a.id, a.name, w.channel, COUNT(*) ct
            FROM accounts a
            JOIN web_events w
            ON a.id = w.account_id
            GROUP BY a.id, a.name, w.channel) t1
        GROUP BY t1.id, t1.name) t2
ON t2.id = t3.id AND t2.max_chan = t3.ct
ORDER BY t3.id
----------------------------
-- SUBQUERIES
-- Provide the name of the sales_rep in each region with the largest amount of
--total_amt_usd sales.
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

-- For the region with the largest (sum) of sales total_amt_usd, how many
-- total (count) orders were placed?
--      my solution
SELECT r.name region_name, COUNT(*) as total_orders
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT SUM(o.total_amt_usd)
                                FROM sales_reps s
                                JOIN accounts a
                                ON a.sales_rep_id = s.id
                                JOIN orders o
                                ON o.account_id = a.id
                                JOIN region r
                                ON r.id = s.region_id
                            GROUP BY s.region_id
                            ORDER BY 1 DESC
                            LIMIT 1)
LIMIT 1
--      course solution
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

--For the name of the account that purchased the most (in total over their
--lifetime as a customer) standard_qty paper, how many accounts still had more
-- first:
SELECT a.name account_name,
        SUM(o.total) total,
        SUM(o.standard_qty) std_qty
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1;
-- then, pull all accounts with more total sales:
SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                  FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                        FROM accounts a
                        JOIN orders o
                        ON o.account_id = a.id
                        GROUP BY 1
                        ORDER BY 2 DESC
                        LIMIT 1) inner_tab);
-- finally, apply the count on top:
SELECT COUNT(*)
FROM (SELECT a.name
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT total
                  FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                        FROM accounts a
                        JOIN orders o
                        ON o.account_id = a.id
                        GROUP BY 1
                        ORDER BY 2 DESC
                        LIMIT 1) inner_tab)
            ) counter_tab;

--For the customer that spent the most (in total over their lifetime as a
--customer) total_amt_usd, how many web_events did they have for each channel?




--What is the lifetime average amount spent in terms of total_amt_usd for the
--top 10 total spending accounts?


--What is the lifetime average amount spent in terms of total_amt_usd for only
--the companies that spent more than the average of all orders.











------------------------------
------------------------------
------------------------------
-- USE of "WITH"
-- Start with a query and break into components for ease of reading/ comprehension
-- with a common table expression
SELECT channel,
    AVG(event_count) AS avg_event_count
    FROM
    (SELECT DATE_TRUNC('day', occurred_at) AS day,
            channel,
            COUNT(*) AS event_count
        FROM web_events
    GROUP BY 1,2
) sub
GROUP BY 1
ORDER BY 2 DESC

-- using 'with'
WITH events AS (SELECT DATE_TRUNC('day', occurred_at) AS day,
        channel,
        COUNT(*) AS event_count
    FROM web_events
  GROUP BY 1,2)

SELECT channel,
    AVG(event_count) AS avg_event_count
    FROM events
GROUP BY 1
ORDER BY 2 DESC
------------------------------------
-- using 'with'- Examples
-- Example 1
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

--select inner query and put it inside WITH
SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2

WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

--Now, we can use this newly created events table as if it is any other table
--in our database
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day,
                        channel, COUNT(*) as events
          FROM web_events
          GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;

--We can create more tables like this (table1, table2)
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)

SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;

---
