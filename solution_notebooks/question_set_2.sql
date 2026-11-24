-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Interview questions · Set 2
-- MAGIC
-- MAGIC **Level 1** · Primary and foreign keys, counts that include zero, CREATE OR REPLACE; the busiest weekday, average vs median, collect_list / collect_set, the cancelled share, PIVOT; duplicates; DELETE / TRUNCATE / DROP.
-- MAGIC
-- MAGIC **Before you run:** run `00_setup` once, then choose **Serverless** in the compute selector at the top right.
-- MAGIC
-- MAGIC 1. What is the difference between a primary key and a foreign key? Does Databricks stop you inserting a duplicate primary key?
-- MAGIC 2. List every customer with their number of orders. Customers who have never ordered should show 0.
-- MAGIC 3. Explain CREATE OR REPLACE TABLE and CREATE TABLE IF NOT EXISTS.
-- MAGIC 4. On which day of the week do customers place the most orders? Show every weekday with its number of orders, busiest first.
-- MAGIC 5. What is the difference between average and median?
-- MAGIC 6. What is the difference between collect_list and collect_set?
-- MAGIC 7. For each year, show the number of orders, how many of them were cancelled, and the cancelled share as a percentage with one decimal.
-- MAGIC 8. How do you turn rows into columns, and columns back into rows?
-- MAGIC 9. Some payments were loaded twice. Find the payments that appear more than once, with every column identical, and how many times each appears.
-- MAGIC 10. What is the difference between DELETE, TRUNCATE and DROP? Can you get a dropped table back?

-- COMMAND ----------

-- Run this cell as it is.
USE workspace.sql_interview;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 1. What is the difference between a primary key and a foreign key? Does Databricks stop you inserting a duplicate primary key?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A primary key identifies each row; a foreign key holds the primary key of a row in another table (orders.customer_id points at customers). In Databricks, PRIMARY KEY and FOREIGN KEY are informational: they are not checked, so a duplicate goes in. NOT NULL and CHECK are enforced.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 2. List every customer with their number of orders. Customers who have never ordered should show 0.
-- MAGIC
-- MAGIC **Level 1 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Count with a LEFT JOIN
-- MAGIC
-- MAGIC ![A few customers and Ben's four orders, and the expected output: Nora, Arjun, Isaac and Liam with 0 orders first, then Chen with 1](../images/q2_2_task_zero_orders.png)

-- COMMAND ----------

SELECT c.customer_id, c.first_name,
       count(o.order_id) AS orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY ALL
ORDER BY orders;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 3. Explain CREATE OR REPLACE TABLE and CREATE TABLE IF NOT EXISTS.
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** CREATE OR REPLACE TABLE replaces the table if it already exists, so its old rows are gone. CREATE TABLE IF NOT EXISTS creates the table only when it is missing and otherwise does nothing. Without either, creating a table that exists fails with TABLE_OR_VIEW_ALREADY_EXISTS.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 4. On which day of the week do customers place the most orders? Show every weekday with its number of orders, busiest first.
-- MAGIC
-- MAGIC **Level 1 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Date bucketing
-- MAGIC
-- MAGIC ![Six orders with their dates, and the expected output: Sunday 45, Friday 38, Saturday 38, Tuesday 34, Wednesday 32, Thursday 31, Monday 22](../images/q2_4_task_weekday.png)

-- COMMAND ----------

SELECT date_format(order_date, 'EEEE') AS weekday,
       count(*) AS orders
FROM orders
GROUP BY ALL
ORDER BY orders DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 5. What is the difference between average and median?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** The average uses every value, so a few large values pull it up. The median is the middle value, so extremes don't move it. On payments the average is 113.49 and the median 89.85: a few large payments lift the average.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 6. What is the difference between collect_list and collect_set?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** Both gather the values of a group into an array. collect_list keeps duplicates; collect_set keeps each value once.
-- MAGIC
-- MAGIC ![Customer 2's channels gathered as app, app, web, web by collect_list and app, web by collect_set; customer 22's as web three times and web once](../images/q2_6_collect.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 7. For each year, show the number of orders, how many of them were cancelled, and the cancelled share as a percentage with one decimal.
-- MAGIC
-- MAGIC **Level 1 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Conditional aggregation
-- MAGIC
-- MAGIC ![Six orders with date and status, and the expected output: 2025 has 157 orders, 18 cancelled, 11.5 percent; 2026 has 83, 10, 12.0](../images/q2_7_task_cancelled.png)

-- COMMAND ----------

SELECT year(order_date) AS year,
       count(*) AS orders,
       count_if(status = 'cancelled') AS cancelled,
       round(100 * count_if(status = 'cancelled') / count(*), 1) AS cancelled_pct
FROM orders
GROUP BY ALL
ORDER BY year;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 8. How do you turn rows into columns, and columns back into rows?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** PIVOT turns the values of one column into columns: one row per year, a column per channel. UNPIVOT turns columns back into rows.
-- MAGIC
-- MAGIC ![Orders per year and channel as four rows, pivoted to one row per year with web and app columns: 2025 111 and 46, 2026 52 and 31](../images/q2_8_pivot.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 9. Some payments were loaded twice. Find the payments that appear more than once, with every column identical, and how many times each appears.
-- MAGIC
-- MAGIC **Level 1 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Find duplicates
-- MAGIC
-- MAGIC ![payments 5047 to 5051 with 5049 loaded twice, and the expected output: payments 5049, 5112 and 5208, each with 2 copies](../images/q2_9_task_duplicates.png)

-- COMMAND ----------

SELECT payment_id, order_id, method, amount, paid_at,
       count(*) AS copies
FROM payments
GROUP BY ALL
HAVING count(*) > 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 10. What is the difference between DELETE, TRUNCATE and DROP? Can you get a dropped table back?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** DELETE removes the rows that match its WHERE (all rows without one). TRUNCATE removes every row and keeps the table. DROP removes the table itself. UNDROP TABLE brings a dropped managed table back within 7 days by default.
-- MAGIC
-- MAGIC ![On product_prices, DELETE WHERE product_id = 20 removes one row, TRUNCATE leaves the table with no rows, DROP removes the table, and UNDROP TABLE brings it back within 7 days](../images/q2_10_drop.png)