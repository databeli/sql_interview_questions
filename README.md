# SQL Interview Questions on Databricks

51 SQL interview questions with answers, by Narender Kumar (@DataBeli). They follow on from the
[SQL Full Course on Databricks](https://youtu.be/6BwprHxQZNk) and use only what the course teaches.
The questions run from the basics to multi-step scenarios.

Everything runs on **Databricks Free Edition**, on serverless compute.

## What's in this repository

| Folder | What it holds |
| --- | --- |
| `practice_notebooks/` | The questions, with the code cells of the hands-on questions left empty (`-- Your code here`): write the SQL yourself. Theory questions keep their answers. |
| `solution_notebooks/` | The same notebooks with every answer filled in and its output, to check your work against. |
| `images/` | The pictures the notebooks show. Keep this folder next to the two notebook folders, or the pictures won't appear. |

## The question sets

The sets go from easy to hard. Each takes about 20-30 minutes.

| Notebook | Level | Questions | What it covers |
| --- | --- | --- | --- |
| `00_setup` | | | Creates the schema `workspace.sql_interview` and its eight tables. Run it first. |
| `question_set_1` | 1 | 10 | The three counts, `CAST` vs `try_cast`, `COALESCE` / `NULLIF`, `LIKE` / `ILIKE`, the type for money, `CASE`, `WHERE` vs `HAVING`, `GROUP BY ALL`; reading dates written two ways, the Nth highest value |
| `question_set_2` | 1 | 10 | Primary and foreign keys, counts that include zero, `CREATE OR REPLACE`; the busiest weekday, average vs median, `collect_list` / `collect_set`, the cancelled share, `PIVOT`; duplicates; `DELETE` / `TRUNCATE` / `DROP` |
| `question_set_3` | 2 | 12 | NULLs in joins, semi and anti joins, self joins, why a join multiplies rows; `UNION`, `INTERSECT` / `EXCEPT`, views; products not sold, top referrers, customers above the average, a de-duplicated copy, SQL functions |
| `question_set_4` | 2 | 13 | `GROUP BY` vs window functions, ranking functions, `QUALIFY`; top N per category, the gap between a customer's first and second order, the day spend reached 500; `MERGE`, time travel, `RESTORE`; loading files and reading JSON |
| `question_set_5` | 3 | 6 | Three months in a row, shopping spells, a funnel, keeping a price list in sync with `MERGE`; the `MERGE` duplicate-source error; struct vs `VARIANT` |

Each question is marked **Theory** or **Hands-on**:

- A **theory** question has a short answer, often with a picture.
- A **hands-on** question names its pattern (for example, anti join). Its picture shows the rows in
  the table and the result your query should return. The answer is one SQL query.

## Get started

### 1. Get a workspace

Sign up for Databricks Free Edition. It gives you a workspace with serverless compute.

### 2. Bring the questions into your workspace

The simplest way is a **Git folder**, which copies the whole repository, pictures included:

1. In the sidebar, click **Workspace** and open the folder where you want the questions.
2. Click **Create** > **Git folder**.
3. In **Git repository URL**, paste this repository's URL. Choose **GitHub** as the Git provider and
   give the folder a name, for example `sql_interview`.
4. Click **Create Git folder**.

The Databricks documentation says Git folders need Git credentials set up in your workspace. If
Databricks asks for them, follow
[Git folders](https://docs.databricks.com/aws/en/repos/git-operations-with-repos) in the Databricks
documentation.

Without Git, you can download the notebooks from GitHub and import them one by one: in **Workspace**,
right-click a folder, click **Import**, and pick a `.ipynb` file. The pictures don't come with the
notebooks this way, so a Git folder is the better choice.

### 3. Run the setup notebook once

Open `practice_notebooks/00_setup`. In the compute selector at the top right, choose **Serverless**,
then click **Run all**. It creates the schema `workspace.sql_interview` with the tables of a small
online store:

| Table | Rows | What it holds |
| --- | --- | --- |
| `customers` | 40 | Customers; `signup_date` is text written in two formats |
| `products` | 20 | Products with their category and price |
| `orders` | 240 | Orders with their date, status, channel and total; guest orders have no `customer_id` |
| `order_items` | 476 | The lines of each order |
| `payments` | 221 | Payments, three of them loaded twice |
| `events` | 150 | Website events: `view`, `add_to_cart` and `checkout` |
| `product_prices` | 4 | A small price list |
| `supplier_prices` | 4 | A supplier's new prices for the price list |

It uses the same store as the course, with a few changes. The setup doesn't need the course's
schema, so you can start here.

Running it again replaces the tables with fresh copies, so it also resets the data.

### 4. Work through the sets in order

Open each notebook in `practice_notebooks/` and run the first cell (`USE workspace.sql_interview;`).
Then, for each question:

- **Theory:** say your answer out loud, as you would in an interview, then read the answer below it.
- **Hands-on:** write the query in the empty cell and compare your result with the picture in the
  question.

To see the answer query and its output, open the same notebook in `solution_notebooks/`.

## Good to know

- **Two questions change the data.** Set 3 creates a table `payments_clean`, and set 5 runs a
  `MERGE` that changes `product_prices`. Run `00_setup` again to reset them.
- **There is often more than one right query.** Your query is right if it returns the same rows as
  the solution.
- **Free Edition has a daily compute limit.** If you go over it, compute stops until the next day.
  Your tables are kept.

## Author

Narender Kumar: Senior Data Architect, Azure certified Solutions Architect, Databricks MVP.
YouTube: [@DataBeli](https://www.youtube.com/@DataBeli)
