-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Interview questions · Set 3
-- MAGIC
-- MAGIC **Level 2** · NULLs in joins, semi and anti joins, self joins, why a join multiplies rows; UNION, INTERSECT / EXCEPT, views; products not sold, top referrers, customers above the average, a de-duplicated copy, SQL functions.
-- MAGIC
-- MAGIC **Before you run:** run `00_setup` once, then choose **Serverless** in the compute selector at the top right.
-- MAGIC
-- MAGIC 1. What happens to NULL values in a join?
-- MAGIC 2. What are LEFT SEMI and LEFT ANTI joins?
-- MAGIC 3. Find the products that sold nothing in 2026.
-- MAGIC 4. Can you tell me a scenario where you would join a table to itself?
-- MAGIC 5. Which customers referred the most other customers? Show each referrer's name and how many customers they referred, most first.
-- MAGIC 6. Why can a join return more rows than either table?
-- MAGIC 7. What is the difference between UNION and UNION ALL?
-- MAGIC 8. What do INTERSECT and EXCEPT return?
-- MAGIC 9. What is the difference between a view and a temporary view?
-- MAGIC 10. Find the customers whose average order value is higher than the average value of all orders. Each order's value is in order_total.
-- MAGIC 11. Build a table payments_clean with the payments but without the duplicate rows, written so that running it again gives the same table.
-- MAGIC 12. Why would you create a SQL function, and how do you create one?

-- COMMAND ----------

-- Run this cell as it is.
USE workspace.sql_interview;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 1. What happens to NULL values in a join?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A NULL key never matches anything, not even another NULL, because NULL = NULL is unknown rather than true. So the 5 guest orders (customer_id NULL) drop out of an inner join with customers; a LEFT JOIN from orders keeps them, with NULL in the customer columns. To match NULL with NULL, use the null-safe operator <=>: NULL <=> NULL is true, so joining the guest orders to each other on customer_id <=> customer_id gives 25 rows where = gives 0.
-- MAGIC
-- MAGIC ![Orders 1001, 1003, 1065 and 1103 joined to customers: the inner join keeps only 1001 and 1003; the LEFT JOIN keeps all four, with NULL names for the guest orders. With <=>, NULL matches NULL: the 5 guest orders joined to each other give 0 rows with = and 25 with <=>](../images/q3_1_null_keys.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 2. What are LEFT SEMI and LEFT ANTI joins?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** LEFT SEMI JOIN returns the rows of the left table that have at least one match, each once, with only the left table's columns. LEFT ANTI JOIN returns the left rows that have no match, such as customers who never ordered.
-- MAGIC
-- MAGIC ![Customers 1, 2, 15 and 28: LEFT SEMI JOIN orders returns Asha and Ben once each; LEFT ANTI JOIN returns Nora and Arjun, who have no orders](../images/q3_2_semi_anti.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 3. Find the products that sold nothing in 2026.
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Anti join
-- MAGIC
-- MAGIC ![The 20 products and a few 2026 order lines, and the expected output: Watering Can, Smart Plug, Cookbook: Weeknight Dinners and Garden Planner 2025](../images/q3_3_task_unsold.png)

-- COMMAND ----------

SELECT p.*
FROM products p
LEFT ANTI JOIN (
  SELECT i.product_id
  FROM order_items i
  JOIN orders o ON o.order_id = i.order_id
  WHERE year(o.order_date) = 2026
) sold_2026 ON sold_2026.product_id = p.product_id;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 4. Can you tell me a scenario where you would join a table to itself?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** When rows point to other rows in the same table. customers.referred_by holds the customer_id of the customer who referred them, so to show each customer next to their referrer's name you join customers to customers, with two aliases to tell the copies apart. An employee and their manager is the classic case.
-- MAGIC
-- MAGIC ![customers c joined to customers r on c.referred_by = r.customer_id: Kevin and Nora are matched to Chen, Omar and Priya to Nora](../images/q3_4_self_join.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 5. Which customers referred the most other customers? Show each referrer's name and how many customers they referred, most first.
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Self join
-- MAGIC
-- MAGIC ![The 9 customers who have a referrer, and the expected output: Chen, Nora and Yusuf with 2 each, then Ivan, Kevin and Zara with 1](../images/q3_5_task_referrers.png)

-- COMMAND ----------

SELECT r.customer_id, r.first_name,
       count(*) AS referred
FROM customers c
JOIN customers r ON c.referred_by = r.customer_id
GROUP BY ALL
ORDER BY referred DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 6. Why can a join return more rows than either table?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** Each row on one side pairs with every matching row on the other. Order 1016 has 2 items and 2 payments, so joining items to payments gives 2 x 2 = 4 rows for it. To avoid this, aggregate each table to one row per key before joining.
-- MAGIC
-- MAGIC ![Order 1016's 2 items joined to its 2 payments on order_id give 4 rows, so each payment appears twice](../images/q3_6_fanout.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 7. What is the difference between UNION and UNION ALL?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** Both stack the rows of two queries that have the same columns. UNION ALL keeps every row. UNION also removes duplicates, which is extra work, so use UNION ALL unless you need the duplicates gone.
-- MAGIC
-- MAGIC ![product_id and product_name from the two price lists: UNION ALL returns 8 rows with 6, 7 and 14 twice; UNION returns 5 distinct rows](../images/q3_7_union.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 8. What do INTERSECT and EXCEPT return?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** INTERSECT returns the rows that are in both queries. EXCEPT returns the rows of the first query that aren't in the second (other databases call it MINUS). Both need the same number of columns.
-- MAGIC
-- MAGIC ![INTERSECT of the two price lists returns 6, 7 and 14; product_prices EXCEPT supplier_prices returns 20; the reverse returns 21](../images/q3_8_intersect_except.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 9. What is the difference between a view and a temporary view?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A view is a saved query stored in the schema: it holds no rows, and anyone with access can query it. A temporary view is the same idea for your session only: nobody else sees it, and it disappears when the session ends.
-- MAGIC
-- MAGIC ![CREATE VIEW stores the query in the schema for everyone with access; CREATE TEMPORARY VIEW lives only in the session; both run the SELECT when queried](../images/q3_9_view.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 10. Find the customers whose average order value is higher than the average value of all orders. Each order's value is in order_total.
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Compare with an overall value
-- MAGIC
-- MAGIC ![The orders of customers 4 and 5 with order_total and the overall average 111.54, and the expected output: 19 customers, starting with 4 at 185.23](../images/q3_10_task_above_avg.png)

-- COMMAND ----------

SELECT customer_id,
       round(avg(order_total), 2) AS avg_order
FROM orders
WHERE customer_id IS NOT NULL
GROUP BY customer_id
HAVING avg(order_total) > (SELECT avg(order_total) FROM orders);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 11. Build a table payments_clean with the payments but without the duplicate rows, written so that running it again gives the same table.
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Deduplicate, safe to re-run
-- MAGIC
-- MAGIC ![payments with 5049 loaded twice, and the expected output of the check on payments_clean: 218 payments totalling 24825.36](../images/q3_11_task_payments_clean.png)

-- COMMAND ----------

CREATE OR REPLACE TABLE payments_clean AS
SELECT DISTINCT * FROM payments;

SELECT count(*) AS payments, sum(amount) AS total FROM payments_clean;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 12. Why would you create a SQL function, and how do you create one?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** To write a calculation once and use it the same way in every query. CREATE FUNCTION clean_category(c STRING) RETURNS STRING RETURN initcap(trim(c)); then SELECT clean_category(category) FROM products.
-- MAGIC
-- MAGIC ![CREATE FUNCTION clean_category returns initcap(trim(c)): 'kitchen ' becomes Kitchen, 'garden' becomes Garden, 'Home' stays Home](../images/q3_12_function.png)