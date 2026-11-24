-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Interview questions · Set 4
-- MAGIC
-- MAGIC **Level 2** · GROUP BY vs window, ranking functions, QUALIFY; top N per category, the first-to-second order gap, the day spend reached 500; MERGE, time travel, RESTORE; loading files and reading JSON.
-- MAGIC
-- MAGIC **Before you run:** run `00_setup` once, then choose **Serverless** in the compute selector at the top right.
-- MAGIC
-- MAGIC 1. What is the difference between GROUP BY and a window function?
-- MAGIC 2. What is the difference between ROW_NUMBER, RANK and DENSE_RANK?
-- MAGIC 3. What is QUALIFY?
-- MAGIC 4. Show the two best-selling products in each category, by units sold.
-- MAGIC 5. On average, how many days pass between a customer's first order and their second?
-- MAGIC 6. For each customer, find the date on which their total spend first reached 500. Count every order except cancelled ones; each order's value is in order_total.
-- MAGIC 7. What does MERGE do, and what does each WHEN clause handle?
-- MAGIC 8. What is time travel?
-- MAGIC 9. How do you undo a bad UPDATE on a Delta table?
-- MAGIC 10. What is the difference between CTAS from read_files and COPY INTO?
-- MAGIC 11. What is the _rescued_data column?
-- MAGIC 12. Which functions have you used to read JSON data?
-- MAGIC 13. What is the difference between explode and explode_outer?

-- COMMAND ----------

-- Run this cell as it is.
USE workspace.sql_interview;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 1. What is the difference between GROUP BY and a window function?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** GROUP BY collapses each group to one row. A window function computes over a group but keeps every row, so you can show each order next to its customer's total number of orders: count(*) OVER (PARTITION BY customer_id).
-- MAGIC
-- MAGIC ![GROUP BY customer_id returns one row per customer (2 has 4 orders, 22 has 3); count(*) OVER (PARTITION BY customer_id) keeps all 7 orders with their customer's total beside each](../images/q4_1_group_vs_window.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 2. What is the difference between ROW_NUMBER, RANK and DENSE_RANK?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** They differ only on ties. Ranking customers by their number of orders, customers 35 and 23 tie for third with 15 orders each: row_number gives 1, 2, 3, 4, 5 (it breaks the tie arbitrarily); rank gives 1, 2, 3, 3, 5 (it skips a number); dense_rank gives 1, 2, 3, 3, 4 (no gap).
-- MAGIC
-- MAGIC ![Customers ranked by orders: 35 and 23 tie with 15; row_number gives 3 and 4, rank gives 3, 3, then 5, dense_rank gives 3, 3, then 4](../images/q4_2_ranking.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 3. What is QUALIFY?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A Databricks clause that filters on the result of a window function, the way HAVING filters on an aggregate: QUALIFY row_number() OVER (PARTITION BY customer_id ORDER BY order_date DESC) = 1 keeps each customer's latest order.
-- MAGIC
-- MAGIC ![The orders of customers 2 and 22 numbered newest first; QUALIFY row_number() = 1 keeps 1193 and 1091](../images/q4_3_qualify.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 4. Show the two best-selling products in each category, by units sold.
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Top N per group
-- MAGIC
-- MAGIC ![A few order lines with their product's category, and the expected output: the two products with the most units in each of the five categories](../images/q4_4_task_top2.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 5. On average, how many days pass between a customer's first order and their second?
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Period over period (lag)
-- MAGIC
-- MAGIC ![The first orders of customers 1, 2 and 4 with each second order marked, and the expected output: 51.4](../images/q4_6_task_gap.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 6. For each customer, find the date on which their total spend first reached 500. Count every order except cancelled ones; each order's value is in order_total.
-- MAGIC
-- MAGIC **Level 2 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Running total
-- MAGIC
-- MAGIC ![Customer 35's first six orders that aren't cancelled, and the expected output: 20 customers, 35 first on 2025-02-27](../images/q4_7_task_500.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 7. What does MERGE do, and what does each WHEN clause handle?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** MERGE applies a source table to a target table in one statement. WHEN MATCHED: the row is in both, usually UPDATE. WHEN NOT MATCHED: the row is only in the source, usually INSERT. WHEN NOT MATCHED BY SOURCE: the row is only in the target, DELETE it or UPDATE it (for example, mark it inactive).
-- MAGIC
-- MAGIC ![product_prices and supplier_prices matched on product_id: 6, 7 and 14 match, 21 is only in the source, 20 only in the target](../images/q4_8_merge.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 8. What is time travel?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** Every change to a Delta table is saved as a new version. DESCRIBE HISTORY lists the versions, and SELECT ... VERSION AS OF n (or TIMESTAMP AS OF) reads the table as it was then.
-- MAGIC
-- MAGIC ![product_prices versions 0 to 2; DESCRIBE HISTORY lists them and VERSION AS OF 1 reads Table Lamp at 49.00](../images/q4_9_time_travel.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 9. How do you undo a bad UPDATE on a Delta table?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** RESTORE TABLE t TO VERSION AS OF n, with n read from DESCRIBE HISTORY. The restore is itself a new version, so both the mistake and the fix stay in the history. You can only go back while the old files exist: VACUUM removes them after the retention period, 7 days by default.
-- MAGIC
-- MAGIC ![Version 2 sets Table Lamp to 0.00 by mistake; RESTORE TO VERSION AS OF 1 makes version 3 with 49.00 again](../images/q4_10_restore.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 10. What is the difference between CTAS from read_files and COPY INTO?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** CTAS (CREATE TABLE ... AS SELECT * FROM read_files(...)) creates a table from the files in one go; to reload, you replace the whole table. COPY INTO loads into an existing table and remembers which files it has loaded, so running it again adds only new files.
-- MAGIC
-- MAGIC ![Running the CTAS from read_files again reloads all 21 rows; running COPY INTO again inserts 0 rows because the file was already loaded](../images/q4_11_copy_into.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 11. What is the _rescued_data column?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A column read_files adds. When a value doesn't fit its column's type, it is kept in _rescued_data instead of being lost.
-- MAGIC
-- MAGIC ![read_files on products_day2.csv adds _rescued_data, NULL on every row because every value fits its column](../images/q4_12_rescued.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 12. Which functions have you used to read JSON data?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** The : path on JSON text (raw_json:device.os); from_json(text, schema) to turn it into a struct; parse_json to store it as VARIANT. A missing field gives NULL, not an error.
-- MAGIC
-- MAGIC ![Event e0001's JSON read three ways: raw_json:device.os, from_json(...).device.os and parse_json(raw_json):device.os all give Android, and NULL for e0113, which has no device](../images/q4_13_json.png)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 13. What is the difference between explode and explode_outer?
-- MAGIC
-- MAGIC **Level 2 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** Both turn each element of an array into its own row. explode drops rows whose array is empty or NULL; explode_outer keeps them, with NULL.
-- MAGIC
-- MAGIC ![explode(items) turns e0001's and e0002's items into 4 rows and drops e0028, whose array is empty; explode_outer keeps e0028 with a NULL item](../images/q4_14_explode.png)