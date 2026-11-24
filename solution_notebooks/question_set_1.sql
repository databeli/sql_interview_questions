-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Interview questions · Set 1
-- MAGIC
-- MAGIC **Level 1** · The three counts, CAST vs try_cast, COALESCE / NULLIF, LIKE / ILIKE, the type for money, CASE, WHERE vs HAVING, GROUP BY ALL; reading dates written two ways, the Nth highest value.
-- MAGIC
-- MAGIC **Before you run:** run `00_setup` once, then choose **Serverless** in the compute selector at the top right.
-- MAGIC
-- MAGIC 1. What is the difference between count(*), count(column) and count(DISTINCT column)?
-- MAGIC 2. What is the difference between CAST and try_cast?
-- MAGIC 3. What do COALESCE and NULLIF do?
-- MAGIC 4. The signup_date column is text written in two formats: 2025-04-03 (year-month-day) and 26/09/2025 (day/month/year). Show every customer with their sign-up date as a real date.
-- MAGIC 5. What is the difference between LIKE and ILIKE?
-- MAGIC 6. In what data type do you store money and why?
-- MAGIC 7. In a CASE expression, what happens when two conditions are true? And when none is true and there is no ELSE?
-- MAGIC 8. Find the second most expensive product.
-- MAGIC 9. What is the difference between WHERE and HAVING?
-- MAGIC 10. What is GROUP BY ALL?

-- COMMAND ----------

-- Run this cell as it is.
USE workspace.sql_interview;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 1. What is the difference between count(*), count(column) and count(DISTINCT column)?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** count(*) counts rows. count(column) counts the values that aren't NULL. count(DISTINCT column) counts the different non-NULL values. On orders: 240 rows, 235 with a customer_id (5 guest orders), 39 different customers.
-- MAGIC
-- MAGIC ![On five orders rows, count(*) is 5, count(customer_id) is 3 and count(DISTINCT customer_id) is 2; on all orders, 240, 235 and 39](../images/q1_1_counts.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 2. What is the difference between CAST and try_cast?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** CAST stops the query when a value can't be converted (CAST_INVALID_INPUT). try_cast returns NULL for that value and the query carries on.
-- MAGIC
-- MAGIC ![CAST on signup_date stops the query at 26/09/2025 with CAST_INVALID_INPUT; try_cast converts 2025-04-03 and returns NULL for 26/09/2025, unknown and 2025-02-30](../images/q1_2_cast.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 3. What do COALESCE and NULLIF do?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** coalesce(a, b, ...) returns the first value that isn't NULL, so it fills in a default: coalesce(loyalty_tier, 'None'). nullif(a, b) returns NULL when a equals b, which turns a placeholder such as 'unknown' into a real NULL.
-- MAGIC
-- MAGIC ![coalesce(loyalty_tier, 'None') fills the NULL tiers of customers 4 and 9 and keeps Silver; nullif(signup_date, 'unknown') turns customer 22's unknown into NULL](../images/q1_3_coalesce.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 4. The signup_date column is text written in two formats: 2025-04-03 (year-month-day) and 26/09/2025 (day/month/year). Show every customer with their sign-up date as a real date.
-- MAGIC
-- MAGIC **Level 1 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Standardise messy values
-- MAGIC
-- MAGIC ![Six customers with signup_date as text in two formats, and the expected output with signup_dt as a date: 2025-04-03, 2025-09-26, 2025-12-26, 2024-12-03, then NULL for unknown and 2025-02-30](../images/q1_4_task_signup.png)

-- COMMAND ----------

SELECT *,
  coalesce(try_cast(signup_date AS DATE),
           try_to_date(signup_date, 'dd/MM/yyyy')) AS signup_dt
FROM customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 5. What is the difference between LIKE and ILIKE?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** LIKE matches a pattern and is case-sensitive (% is any run of characters, _ is one character). ILIKE does the same but ignores case.
-- MAGIC
-- MAGIC ![LIKE '%@example.com' matches only the lower-case email; ILIKE matches all four, including those written Example.com](../images/q1_5_like_ilike.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 6. In what data type do you store money and why?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** DECIMAL(p, s), such as the DECIMAL(10,2) the course tables use for every price and amount. DECIMAL stores exact digits, so amounts add up to the cent. DOUBLE stores an approximation, so sums drift: 0.1 + 0.2 as doubles gives 0.30000000000000004.
-- MAGIC
-- MAGIC ![The payments of orders 1001 to 1003 add up to 500.04 as DECIMAL and 500.03999999999996 as DOUBLE](../images/q1_6_decimal.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 7. In a CASE expression, what happens when two conditions are true? And when none is true and there is no ELSE?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** CASE returns the result of the first condition that is true and stops checking. When nothing matches and there is no ELSE, it returns NULL.
-- MAGIC
-- MAGIC ![A CASE with two WHEN conditions: 79.00 meets both and gets the first, premium; 29.00 gets mid; 19.00 meets neither and, with no ELSE, gets NULL](../images/q1_7_case.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 8. Find the second most expensive product.
-- MAGIC
-- MAGIC **Level 1 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Nth highest
-- MAGIC
-- MAGIC ![The 20 products with their unit_price, and the expected output: one row, product 7, Wool Throw, Home, 65.00](../images/q1_8_task_second_price.png)

-- COMMAND ----------

SELECT *
FROM products
ORDER BY unit_price DESC
LIMIT 1 OFFSET 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 9. What is the difference between WHERE and HAVING?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** WHERE filters rows before they are grouped. HAVING filters the groups after grouping, so it can use aggregates such as count(*) > 5. An aggregate in WHERE fails.
-- MAGIC
-- MAGIC ![240 orders, WHERE status = 'cancelled' keeps 28 rows, GROUP BY customer_id makes 16 groups, HAVING count(*) >= 3 keeps 5](../images/q1_9_where_having.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 10. What is GROUP BY ALL?
-- MAGIC
-- MAGIC **Level 1 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A Databricks shorthand that groups by every column in SELECT that isn't an aggregate, so you don't repeat them. SELECT channel, status, count(*) FROM orders GROUP BY ALL is the same as GROUP BY channel, status.
-- MAGIC
-- MAGIC ![SELECT channel, status, count(*) AS orders FROM orders written with GROUP BY channel, status and with GROUP BY ALL; both return the same 8 rows](../images/q1_10_group_by_all.png)