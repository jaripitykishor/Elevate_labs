create database sales;
use sales;
select * from sales_data;
SELECT 
    EXTRACT(YEAR FROM Date) as Year,
    EXTRACT(MONTH FROM Date) as Month,
    SUM(`Total Revenue`) as Monthly_Revenue,
    COUNT(DISTINCT `Transaction ID`) as Order_Volume
FROM sales_data
GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY Year, Month;

-- 1. Top 3 months by sales revenue
SELECT 
    EXTRACT(YEAR FROM Date) as Year,
    EXTRACT(MONTH FROM Date) as Month,
    SUM(`Total Revenue`) as Monthly_Revenue
FROM sales_data
GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY Monthly_Revenue DESC
LIMIT 3;

-- 2. Monthly analysis with average order value
SELECT 
    EXTRACT(YEAR FROM Date) as Year,
    EXTRACT(MONTH FROM Date) as Month,
    SUM(`Total Revenue`) as Monthly_Revenue,
    COUNT(DISTINCT `Transaction ID`) as Order_Volume,
    ROUND(AVG(`Total Revenue`), 2) as Avg_Order_Value,
    SUM(`Units Sold`) as Total_Units_Sold
FROM sales_data
GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY Year, Month;

-- 3. Quarterly aggregation
SELECT 
    EXTRACT(YEAR FROM Date) as Year,
    EXTRACT(QUARTER FROM Date) as Quarter,
    SUM(`Total Revenue`) as Quarterly_Revenue,
    COUNT(DISTINCT `Transaction ID`) as Quarterly_Orders
FROM sales_data
GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(QUARTER FROM Date)
ORDER BY Year, Quarter;

-- 4. Monthly trends with growth calculation (PostgreSQL/MySQL)
WITH monthly_stats AS (
    SELECT 
        EXTRACT(YEAR FROM Date) as Year,
        EXTRACT(MONTH FROM Date) as Month,
        SUM(`Total Revenue`) as Monthly_Revenue,
        COUNT(DISTINCT `Transaction ID`) as Order_Volume
    FROM sales_data
    GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
)
SELECT 
    Year,
    Month,
    Monthly_Revenue,
    Order_Volume,
    LAG(Monthly_Revenue) OVER (ORDER BY Year, Month) as Previous_Month_Revenue,
    ROUND(
        ((Monthly_Revenue - LAG(Monthly_Revenue) OVER (ORDER BY Year, Month)) / 
         LAG(Monthly_Revenue) OVER (ORDER BY Year, Month)) * 100, 2
    ) as Revenue_Growth_Percent
FROM monthly_stats
ORDER BY Year, Month;
-- 5 Find months where revenue decreased compared to the previous month.
WITH monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM Date) as Year,
        EXTRACT(MONTH FROM Date) as Month,
        SUM(`Total Revenue`) as Monthly_Revenue
    FROM sales_data
    GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
),
revenue_changes AS (
    SELECT 
        Year,
        Month,
        Monthly_Revenue,
        LAG(Monthly_Revenue) OVER (ORDER BY Year, Month) as Previous_Revenue
    FROM monthly_revenue
)
SELECT 
    Year,
    Month,
    Monthly_Revenue,
    Previous_Revenue,
    (Monthly_Revenue - Previous_Revenue) as Revenue_Change
FROM revenue_changes
WHERE Monthly_Revenue < Previous_Revenue
ORDER BY Year, Month;

-- 6.Calculate the 3-month moving average of monthly revenue.
WITH monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM Date) as Year,
        EXTRACT(MONTH FROM Date) as Month,
        SUM(`Total Revenue`) as Monthly_Revenue
    FROM sales_data
    GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
)
SELECT 
    Year,
    Month,
    Monthly_Revenue,
    ROUND(
        AVG(Monthly_Revenue) OVER (
            ORDER BY Year, Month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) as Three_Month_Moving_Avg
FROM monthly_revenue
ORDER BY Year, Month;

-- 7.Find the top 3 product categories by revenue for each month.
WITH monthly_category_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM Date) as Year,
        EXTRACT(MONTH FROM Date) as Month,
        `Product Category`,
        SUM(`Total Revenue`) as Category_Revenue
    FROM sales_data
    GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date), `Product Category`
),
ranked_categories AS (
    SELECT 
        Year,
        Month,
        `Product Category`,
        Category_Revenue,
        ROW_NUMBER() OVER (PARTITION BY Year, Month ORDER BY Category_Revenue DESC) as rn
    FROM monthly_category_revenue
)
SELECT 
    Year,
    Month,
    `Product Category`,
    Category_Revenue
FROM ranked_categories
WHERE rn <= 3
ORDER BY Year, Month, rn;


