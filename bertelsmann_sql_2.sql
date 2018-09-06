-------------------------------------------------------------------------
-- GROUP BY
/*
Which account (by name) placed the earliest order? Your solution should have
the account name and the date of the order.
*/
SELECT a.name, MIN(o.occurred_at)
 FROM accounts as a
  JOIN orders as o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY MIN(o.occurred_at)
  LIMIT 1;


/*
What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd.
Order from smallest dollar amounts to largest.
*/
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

/*
Find the total sales in usd for each account. You should include two columns -
the total sales for each company's orders in usd and the company name.
*/
SELECT a.name, SUM(total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

/*
Determine the number of times a particular channel was used in the web_events
table for each region. Your final table should have three columns - the region
name, the channel, and the number of occurrences.
Order your table with the highest number of occurrences first.
*/
SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;


--Example for HAVING
SELECT account_id, SUM(total_amt_usd) AS sum_total_sales
  FROM demo.orders
  -- WHERE SUM(total_amt_usd) >= 250000
  -- WHERE cannot be used because it does not alow you to filter on
  -- aggregate columns! You need to use HAVING instead.
  HAVING SUM(total_amt_usd) > = 250000

-----------------------------------------
-- HAVING - Questions
-- How many of the sales reps have more than 5 accounts that they manage?
SELECT s.name, s.id, COUNT(DISTINCT a.id) as num_acc
FROM sales_reps as s
JOIN accounts as a
ON s.id = a.sales_rep_id
GROUP BY s.name, s.id
HAVING COUNT(DISTINCT a.id) > 5;
ORDER BY num_acc;
-- equivalent
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.id, s.name, COUNT(*) num_accounts
     FROM accounts a
     JOIN sales_reps s
     ON s.id = a.sales_rep_id
     GROUP BY s.id, s.name
     HAVING COUNT(*) > 5
     ORDER BY num_accounts) AS Table1;


--Which account has spent the least with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent
LIMIT 1;

--Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

--Which account used facebook most as a channel?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 1;

-----------------------------------------
-- DATE - Questions

--Find the sales in terms of total dollars for all orders in each year, ordered
--from greatest to least. Do you notice any trends in the yearly sales totals?
SELECT date_part('year', occurred_at) as year, SUM(total_amt_usd) as total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

--Which year did Parch & Posey have the greatest sales in terms of total number
--of orders? Are all years evenly represented by the dataset?
SELECT date_part('month', occurred_at) as month, COUNT(id) as nb_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

--In which month of which year did Walmart spend the most on gloss paper in
--terms of dollars?
SELECT date_part('year', occurred_at) as year, date_part('month', occurred_at) as month,
SUM(gloss_amt_usd) as tot_glossy_amt
FROM orders
JOIN accounts
	ON orders.account_id = accounts.id
	AND accounts.name = 'Walmart'
GROUP BY year, month
ORDER BY tot_glossy_amt DESC
LIMIT 1;
-- alternative
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

------------------------------------------
--- CASE
-- Example that uses CASE to tackle a divison by 0 error
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty
                        END AS unit_price
FROM orders
LIMIT 10;


--- CASE and AGGREGATIONS based on groups created with CASE
SELECT CASE WHEN total > 500 THEN 'over'
            ELSE 'under' END AS total_group,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY 1

----------------------------------
-- Exercises (CASE with AGGREGATIONS)
/*
We would like to understand 3 different levels of customers based on the
amount associated with their purchases.Provide a table that includes the
level associated with each account. Order the top spending customers first.
*/
SELECT a.name account, SUM(o.total_amt_usd) amt
CASE
WHEN SUM(o.total_amt_usd) > 200000 THEN 'large'
WHEN SUM(o.total_amt_usd) < 100000 THEN 'small'
ELSE 'med'
END AS totsum
FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
GROUP BY a.name
ORDER BY totsum DESC

-- We would now like to perform a similar calculation to the first, but we want
-- to obtain the total amount spent by customers only in 2016 and 2017
SELECT a.name account, SUM(o.total_amt_usd) amt,
CASE
WHEN SUM(o.total_amt_usd) > 200000 THEN 'large'
WHEN SUM(o.total_amt_usd) < 100000 THEN 'small'
ELSE 'med'
END AS totsum
FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
WHERE DATE_PART('year', o.occurred_at) IN ('2016','2017')
GROUP BY a.name
ORDER BY amt DESC

/* We would like to identify top performing sales reps, which are sales reps
associated with more than 200 orders. Create a table with the sales rep name,
the total number of orders, and a column with top or not depending on if they
have more than 200 orders. Place the top sales people first in your final table.
*/
SELECT s.name, COUNT(o.id) total_orders,
CASE
WHEN COUNT(o.id) > 200 THEN 'top'
ELSE 'not'
END top_sales
FROM sales_reps s
  JOIN accounts a
  ON s.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC;

/*
We would like to identify sales reps associated with more than 200 orders or
more than 750000 in total sales.
The middle group has any rep with more than 150 orders or 500000 in sales.
Create a table with the sales rep name, the total number of orders, total sales
across all orders, and a column with top, middle, or low depending on this
criteria. Place the top sales people based on dollar amount of sales first
in your final table. You might see a few upset sales people by this criteria!
*/
SELECT s.name, COUNT(o.id) total_orders,
 SUM(total_amt_usd) total_sales,
CASE
WHEN COUNT(o.id) > 200 OR SUM(o.total_amt_usd)>750000 THEN 'top'
WHEN COUNT(o.id) <= 150 OR SUM(o.total_amt_usd)<500000 THEN 'low'
ELSE 'middle'
END top_sales
FROM sales_reps s
  JOIN accounts a
  ON s.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
GROUP BY s.name
ORDER BY 3 DESC;
