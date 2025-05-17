/*-- QUESTION 2
-- Transaction Frequency Analysis
-- Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
-- Task: Calculate the average number of transactions per customer per month and categorize them:
-- ●	"High Frequency" (≥10 transactions/month)
-- ●	"Medium Frequency" (3-9 transactions/month)
-- ●	"Low Frequency" (≤2 transactions/month)
-- Tables:
-- ●	users_customuser
-- ●	savings_savingsaccount
*/




/*-- ANSWER TO Q2: --Transaction Frequency Analysis
-- Objective:
		-- Categorize customers based on how frequently they transact each month using savings transaction data.
-- Frequency Buckets:
		-- - High Frequency: ≥ 10 transactions/month
		-- - Medium Frequency: 3–9 transactions/month
		-- - Low Frequency: ≤ 2 transactions/month
-- This query calculates the average number of monthly transactions per customer,
-- classifies them into the frequency buckets, and aggregates customer counts per category.
*/
    
    
    
    SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM (

			-- Step 2: For each customer, calculate average monthly transaction count
    SELECT 
        owner_id,
        AVG(monthly_txn_count) AS avg_txn_per_month,
        CASE
            WHEN AVG(monthly_txn_count) >= 10 THEN 'High Frequency'
            WHEN AVG(monthly_txn_count) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM (
    
			-- Step 1: Count number of transactions per customer per month
        SELECT 
            owner_id,
            DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
            COUNT(*) AS monthly_txn_count
        FROM savings_savingsaccount
        GROUP BY owner_id, txn_month
    ) AS monthly_counts
    GROUP BY owner_id
) AS categorized_customers
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');