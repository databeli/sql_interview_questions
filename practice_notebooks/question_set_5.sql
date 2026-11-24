-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Interview questions · Set 5
-- MAGIC
-- MAGIC **Level 3** · Three months in a row, shopping spells, a funnel, keeping a price list in sync with MERGE; the MERGE duplicate-source error; struct vs VARIANT.
-- MAGIC
-- MAGIC **Before you run:** run `00_setup` once, then choose **Serverless** in the compute selector at the top right.
-- MAGIC
-- MAGIC 1. Find the customers who placed at least one order in each of 3 months in a row. Leave out guest orders, whose customer_id is NULL.
-- MAGIC 2. A shopping spell is a run of orders in which each order comes no more than 30 days after the previous one; a longer gap starts a new spell. Number each customer's orders by spell, and show customer 32's orders.
-- MAGIC 3. From the website events, how many customers viewed a product, how many of them also added something to the cart, and how many of those also checked out?
-- MAGIC 4. product_prices holds 4 products. Today's supplier list, supplier_prices, has 4 rows. In one statement: update the prices that changed, add the new products, and mark the products missing from today's list as inactive instead of deleting them.
-- MAGIC 5. MERGE fails with DELTA_MULTIPLE_SOURCE_ROW_MATCHING_TARGET_ROW_IN_MERGE. Why, and how do you fix it?
-- MAGIC 6. When would you use a struct and when VARIANT?

-- COMMAND ----------

-- Run this cell as it is.
USE workspace.sql_interview;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 1. Find the customers who placed at least one order in each of 3 months in a row. Leave out guest orders, whose customer_id is NULL.
-- MAGIC
-- MAGIC **Level 3 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Consecutive months (LAG and LEAD)
-- MAGIC
-- MAGIC ![Customer 32's 11 orders, January to June 2025 every month, and customer 1's months June, July, September and November 2025 and February 2026; the expected output is customers 8, 14, 17, 20, 23, 29, 32, 34, 37 and 38](../images/q5_1_task_three_months.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 2. A shopping spell is a run of orders in which each order comes no more than 30 days after the previous one; a longer gap starts a new spell. Number each customer's orders by spell, and show customer 32's orders.
-- MAGIC
-- MAGIC **Level 3 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Sessionization (spells)
-- MAGIC
-- MAGIC ![Customer 32's 11 orders, and the expected output with new_spell and spell_no from 1 to 6](../images/q5_2_task_spells.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 3. From the website events, how many customers viewed a product, how many of them also added something to the cart, and how many of those also checked out?
-- MAGIC
-- MAGIC **Level 3 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Funnel
-- MAGIC
-- MAGIC ![Customer 34's four events, and the expected output: 32 viewed, 24 also carted, 13 also checked out](../images/q5_3_task_funnel.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 4. product_prices holds 4 products. Today's supplier list, supplier_prices, has 4 rows. In one statement: update the prices that changed, add the new products, and mark the products missing from today's list as inactive instead of deleting them.
-- MAGIC
-- MAGIC **Level 3 · Hands-on**
-- MAGIC
-- MAGIC **Pattern:** Upsert with soft delete
-- MAGIC
-- MAGIC ![product_prices and supplier_prices, and product_prices after the statement: 52.00 for Table Lamp, 17.00 for Phone Charger, Garden Planner 2025 inactive, Herb Planter added](../images/q5_4_task_merge.png)

-- COMMAND ----------

-- Your code here

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 5. MERGE fails with DELTA_MULTIPLE_SOURCE_ROW_MATCHING_TARGET_ROW_IN_MERGE. Why, and how do you fix it?
-- MAGIC
-- MAGIC **Level 3 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** Two rows of the source match the same target row, so MERGE can't tell which one to apply. Remove the duplicates from the source first, for example keep one row per key with QUALIFY row_number() OVER (PARTITION BY product_id ORDER BY ...) = 1.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## 6. When would you use a struct and when VARIANT?
-- MAGIC
-- MAGIC **Level 3 · Theory**

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Answer:** A struct when the shape of the data is fixed and known. VARIANT when it changes from row to row: it needs no fixed schema and is faster to query than JSON text.
-- MAGIC
-- MAGIC ![device as STRUCT<type, os> for a fixed shape and parse_json as VARIANT for a changing one; both give NULL for e0113, which has no device](../images/q5_6_struct_variant.png)