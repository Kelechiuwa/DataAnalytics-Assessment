# DataAnalytics-Assessment
This repository contains solutions to a 4-question SQL assessment. Each query solves a business problem using relational database concepts like joins, subqueries, aggregation, and filtering.
This repository contains mySQL solutions for a 4-question SQL data analyst assessment focused on solving real-world business problems using relational databases. 
Each question addresses a different aspect of SQL proficiency, including data retrieval, aggregation, joins, subqueries, and business rule implementation.
I’ve included detailed explanations for each question, describing my approach, logic, and any challenges I encountered during implementation.




## Question 1: High-Value Customers with Multiple Products

**Approach:**
To identify high-value customers who have both a savings and an investment plan, I queried the `plans_plan` table twice — once to count savings plans (`is_regular_savings = 1`) and once for investment plans (`is_a_fund = 1`). I used subqueries to separately aggregate the number of each plan type per customer, avoiding row duplication that can occur with multiple joins to the same table.

I joined the resulting counts with the `users_customuser` table, and also joined a subquery from `savings_savingsaccount` that calculates the sum of confirmed deposits per customer. Since deposit amounts are in kobo, I divided the result by 100 to convert to Naira and rounded to 2 decimal places.

To ensure data consistency, I used `COALESCE()` to handle any missing counts or amounts and filtered the result to include only customers with at least one savings and one investment plan.

**Challenges:**
The primary challenge was joining the same table (`plans_plan`) twice to get both savings and investment plans, which initially caused duplication and incorrect counts. Using subqueries for each condition solved this issue and improved both accuracy and readability. I also updated the `users_customuser` table earlier in the process by merging `first_name` and `last_name` into the `name` column for customers where `name` was null, ensuring name values were available in the final output.






## Question 2: Transaction Frequency Analysis

**Approach:**
This query analyzes customer transaction activity by calculating the average number of monthly transactions per customer. First, I grouped all records from `savings_savingsaccount` by `owner_id` and transaction month (using `transaction_date`) to count how many transactions each customer had in a given month. Then, I calculated each customer's average monthly transaction volume.

Using a `CASE` statement, customers were categorized into:
- **High Frequency** (≥ 10 transactions/month)
- **Medium Frequency** (3–9 transactions/month)
- **Low Frequency** (≤ 2 transactions/month)

Finally, I aggregated the results to determine how many customers fall into each frequency group and their average transaction volume.

**Challenges:**
Initially, using multiple CTEs (`WITH` clauses) caused syntax errors in MySQL. I resolved this by rewriting the query using nested subqueries instead of CTEs. Additionally, I verified that the correct timestamp field was `transaction_date`, not `created_at`, which ensured the correct monthly grouping.







## Question 3: Account Inactivity Alert

**Approach:**
To identify all active savings or investment accounts that have had **no transactions in the past 365 days**, I queried the `plans_plan` table for plans where `is_deleted = 0` and `is_archived = 0`. Savings plans were identified using `is_regular_savings = 1` and investment plans using `is_a_fund = 1`.

Each plan was joined to `savings_savingsaccount` using `plan_id` to retrieve any inflow transactions. I computed the latest transaction date per plan using `MAX(transaction_date)` and used `DATEDIFF(NOW(), MAX(...))` to calculate inactivity duration.

The query flags plans that:
- Have never had any transactions (`MAX(...) IS NULL`), or
- Have not had a transaction in the last **365 days**

The `last_transaction_date` was formatted using `DATE(MAX(...))` to display only the date (no time). The final output includes the plan ID, owner ID, type (Savings or Investment), the last transaction date, and days of inactivity.

**Challenges:**
A subtle challenge was making sure I included both types of inactivity: plans that never transacted, and plans that used to but haven't recently. Using a `LEFT JOIN` and checking both `IS NULL` and `DATEDIFF > 365` handled both scenarios cleanly. Formatting the date without time helped ensure clarity in the results.









## Question 4: Customer Lifetime Value (CLV) Estimation

**Approach:**
To estimate the Customer Lifetime Value (CLV) for each user, I joined the `users_customuser` table with the `savings_savingsaccount` table using `owner_id`. This allowed me to link customer profiles with their corresponding savings transactions.

The CLV was calculated using the formula provided in the question:
CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction


Here's how I implemented each component of the formula:
- **Tenure in months** was calculated using `TIMESTAMPDIFF(MONTH, u.created_on, NOW())`, which gives the number of full months since the customer signed up.
- **Total transactions** were counted using `COUNT(s.id)`, representing the number of savings inflow records for each user.
- **Average profit per transaction** was computed by applying a fixed profit rate of 0.1% (i.e., multiplying each `confirmed_amount` by `0.001` and taking the average with `AVG(...)`).

The full expression was wrapped in the `ROUND(..., 2)` function to produce a clean, 2-decimal-place monetary output in line with financial reporting practices.

To ensure reliability:
- I used `NULLIF(..., 0)` to prevent division by zero in cases where tenure was 0 months.
- I filtered out customers who had **no transactions** or **0 months of tenure** using the `HAVING` clause.

The results were sorted in descending order of `estimated_clv`, allowing the highest-value customers to appear at the top.

**Challenges:**
One notable challenge I encountered was handling **very new users** with 0 months of tenure, which could cause a division-by-zero error. I resolved this by using `NULLIF()` inside the formula to exclude such rows safely. I also had to balance readability and performance — ensuring each step in the CLV formula was well-documented and properly grouped to return accurate results.








## SUMMARY

Throughout this assessment, I aimed to write clear, efficient, and well-structured SQL queries that not only return accurate results but also reflect best practices in readability and maintainability. Each solution was tested and refined based on the schema provided.

This exercise strengthened my understanding of advanced SQL techniques and reinforced the importance of aligning query logic closely with business requirements — especially when working with real-life transaction and customer data.

Thank you for the opportunity to demonstrate my skills.





Author: Uwanaka Immeldah Kelechi
Email: uwanakakelech@gmail.com


