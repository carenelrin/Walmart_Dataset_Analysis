-- Q.1 What are the different payment methods, and how many transactions and items were sold with each method?
select payment_method,
       count(*) as no_payments,
       sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Q.2 Which category received the highest average rating in each branch? (display the branch, category and average rating)

select branch,
       category,
       AVG(rating) as avg_rating
from walmart
group by branch, category;

SELECT branch, category, avg_rating, ranked
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranked
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE ranked = 1;

-- Q.3 What is the busiest day of the week for each branch based on transaction volume?

-- Q3: Identify the busiest day for each branch based on the number of transactions

SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranked
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranked = 1;

-- Q.4 How many items were sold through each payment method?

select payment_method,
       sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Q.5 What are the average, minimum, and maximum ratings for each category in each city?
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q.6 What is the total profit for each category, ranked from highest to lowest?
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q.7 What is the most frequently used payment method in each branch?
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranked
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE ranked = 1;

-- Q.8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q.9 Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

-- Q.10 Which product categories have the highest average profit margin, and how does this vary across branches?
SELECT 
    branch,
    category,
    AVG(profit_margin) AS avg_profit_margin
FROM walmart
GROUP BY branch, category
ORDER BY avg_profit_margin DESC;

-- Q.11 What is the average cart value (average total per transaction) for each branch?
SELECT 
    branch,
    AVG(total) AS avg_cart_value
FROM walmart
GROUP BY branch
ORDER BY branch ASC;

-- Q.12 What percentage of total revenue does each category contribute?

SELECT 
    category,
    ROUND( SUM(total), 2 ) AS category_revenue,
    ROUND( (SUM(total) / (SELECT SUM(total) FROM walmart)) * 100 , 2 ) AS revenue_percentage
FROM walmart
GROUP BY category
ORDER BY revenue_percentage DESC;

