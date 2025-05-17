/*-- QUESTION 4. Customer Lifetime Value (CLV) Estimation
		-- Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
-- Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
		-- ●	Account tenure (months since signup)
		-- ●	Total transactions
		-- ●	Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
		-- ●	Order by estimated CLV from highest to lowest
-- Tables:
		-- ●	users_customuser
		-- ●	savings_savingsaccount
*/



/*-- ANSWER TO Q4: Customer Lifetime Value (CLV) Estimation
-- Objective:
			-- Estimate the Customer Lifetime Value for each user based on their account tenure and transaction activity.
			-- CLV Formula:
			-- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
-- Where:
			-- - total_transactions = number of savings transactions
			-- - tenure_months = months since customer signup
			-- - avg_profit_per_transaction = 0.1% (i.e., 0.001) of transaction value
*/


SELECT 
    u.id AS customer_id,        -- Customer ID
    u.name,                     -- Customer name

		-- Step 1: Calculate account tenure in months since the signup date
    TIMESTAMPDIFF(MONTH, u.created_on, NOW()) AS tenure_months,

		-- Step 2: Count total number of savings transactions
    COUNT(s.id) AS total_transactions,

		-- Step 3: Apply the CLV formula using average profit and round to 2 decimal places
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.created_on, NOW()), 0)) 
        * 12 
        * AVG(s.confirmed_amount * 0.001),  -- profit = 0.1% of confirmed amount
        2
    ) AS estimated_clv
FROM users_customuser u

		-- Step 4: Join with the savings transaction table
LEFT JOIN savings_savingsaccount s ON s.owner_id = u.id

		-- Step 5: Group by customer to calculate aggregates per user
GROUP BY u.id, u.name, u.created_on

		-- Step 6: Filter out users with zero tenure or no transactions
HAVING tenure_months > 0 AND total_transactions > 0

		-- Step 7: Sort customers by highest estimated CLV
ORDER BY estimated_clv DESC;