-- QUESTIONS 1
/*-- 1. High-Value Customers with Multiple Products
Scenario: 
The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
Tables:
●	users_customuser
●	savings_savingsaccount
●	plans_plan
*/




/*-- ANSWERS TO Q1: High-Value Customers with Multiple Products
-- Objective:
	-- Find customers who:
		-- Have at least one funded savings plan (is_regular_savings = 1)
		-- Have at least one funded investment plan (is_a_fund = 1)
		-- Count savings and investment plans separately using subqueries.
		-- Sum total deposits from the savings_savingsaccount table.
		-- Filter for users who have at least one of each type of plan.
		 -- Show their owner_id, name, number of each plan type, and total confirmed deposits
		-- Sort by total deposits in descending order.
*/




SELECT 
    u.id AS owner_id,                          -- Customer ID
    u.name,                                    -- Customer name

		-- Count of savings plans per customer
    COALESCE(s.savings_count, 0) AS savings_count,

		-- Count of investment plans per customer
    COALESCE(i.investment_count, 0) AS investment_count,

		-- Total confirmed deposits (in Naira, divided by 100 from kobo)
    ROUND(COALESCE(dep.total_deposits, 0) / 100.0, 2) AS total_deposits

FROM users_customuser u

		-- Subquery 1: Count of savings plans (is_regular_savings = 1)
LEFT JOIN (
    SELECT owner_id, COUNT(*) AS savings_count
    FROM plans_plan
    WHERE is_regular_savings = 1
    GROUP BY owner_id
) s ON s.owner_id = u.id

		-- Subquery 2: Count of investment plans (is_a_fund = 1)
LEFT JOIN (
    SELECT owner_id, COUNT(*) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1
    GROUP BY owner_id
) i ON i.owner_id = u.id

		-- Subquery 3: Sum of all confirmed deposits from savings accounts
LEFT JOIN (
    SELECT owner_id, SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
) dep ON dep.owner_id = u.id

		-- Step: Keep only customers who have at least one savings AND one investment plan
WHERE s.savings_count IS NOT NULL AND i.investment_count IS NOT NULL

		-- Step: Sort by total deposits (from highest to lowest)
ORDER BY total_deposits DESC;
