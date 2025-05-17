/*-- QUESTION3 Account Inactivity Alert
-- Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
-- Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .
-- Tables:
-- ●	plans_plan
-- ●	savings_savingsaccount
*/




-- Q3 ANSWERS: Account Inactivity Alert
-- Objective:
		-- Identify active savings or investment plans that have had no inflow transactions in the last 365 days.
-- Notes:
		-- - Savings plans: is_regular_savings = 1
		-- - Investment plans: is_a_fund = 1
		-- - Active plans must have is_deleted = 0 and is_archived = 0
		-- - Inflows are recorded in savings_savingsaccount using transaction_date
		-- - Output includes plan ID, owner ID, type, last transaction date (date only), and days since last transaction


SELECT 
    p.id AS plan_id,          -- Unique plan ID
    p.owner_id,               -- Customer who owns the plan
    
			-- Identify the plan type (Savings or Investment)
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    
			-- Get only the DATE (no time) of the most recent transaction
    DATE(MAX(s.transaction_date)) AS last_transaction_date,
    
			-- Calculate days of inactivity since the last transaction
    DATEDIFF(NOW(), MAX(s.transaction_date)) AS inactivity_days
FROM plans_plan p

			-- Join transactions to find the last activity per plan
LEFT JOIN savings_savingsaccount s ON s.plan_id = p.id

			-- Filter to include only active savings or investment plans
WHERE 
    p.is_deleted = 0 
    AND p.is_archived = 0
    AND (
        p.is_regular_savings = 1 OR p.is_a_fund = 1
    )
    
			-- Group by plan to get per-plan last transaction date
GROUP BY p.id, p.owner_id, type
			-- Filter for inactivity:
			-- - No transactions at all (NULL)
			-- - OR last transaction was more than 365 days ago

HAVING 
    MAX(s.transaction_date) IS NULL
    OR DATEDIFF(NOW(), MAX(s.transaction_date)) > 365
    
			-- Show the most inactive plans first
ORDER BY inactivity_days DESC;

