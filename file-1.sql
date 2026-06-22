SELECT 
    d.Year,
    COUNT(DISTINCT r.`Order ID`) AS orders,
    ROUND(SUM(r.Sales), 0) AS revenue,
    ROUND(SUM(r.Profit), 0) AS profit,
    ROUND(SUM(r.Profit) * 100.0 / SUM(r.Sales), 2) AS margin_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
GROUP BY d.Year
ORDER BY d.Year;


SELECT 
    COUNT(DISTINCT `Order ID`)        AS total_orders,
    COUNT(DISTINCT `Customer ID`)     AS total_customers,
    ROUND(SUM(Sales), 0)              AS total_revenue,
    ROUND(SUM(Profit), 0)             AS total_profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS overall_margin_pct,
    SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) AS loss_making_lines,
    ROUND(SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS loss_pct_of_lines
FROM retail_dataset;

SELECT 
    d.Year,
    COUNT(*)                          AS line_items,
    ROUND(AVG(r.Discount) * 100, 2)   AS avg_discount_pct,
    ROUND(SUM(r.Profit) * 100.0 / SUM(r.Sales), 2) AS margin_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
GROUP BY d.Year
ORDER BY d.Year;

SELECT 
    d.Year,
    COUNT(*) AS total_lines,
    SUM(CASE WHEN r.Profit < 0 THEN 1 ELSE 0 END) AS loss_lines,
    ROUND(SUM(CASE WHEN r.Profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS loss_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
GROUP BY d.Year
ORDER BY d.Year;

SELECT 
    d.Year,
    COUNT(*) AS loss_lines,
    ROUND(SUM(r.Profit), 0) AS total_loss_amount,
    ROUND(AVG(r.Profit), 0) AS avg_loss_per_line,
    ROUND(MIN(r.Profit), 0) AS worst_single_loss
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
WHERE r.Profit < 0
GROUP BY d.Year
ORDER BY d.Year;

SELECT 
    d.Year,
    r.Category,
    ROUND(SUM(r.Sales), 0) AS revenue,
    ROUND(SUM(r.Sales) * 100.0 / SUM(SUM(r.Sales)) OVER (PARTITION BY d.Year), 1) AS pct_of_year_revenue,
    ROUND(SUM(r.Profit) * 100.0 / SUM(r.Sales), 2) AS category_margin_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
GROUP BY d.Year, r.Category
ORDER BY d.Year, revenue DESC;

SELECT 
    d.Year,
    r.Category,
    ROUND(SUM(r.Sales), 0) AS revenue,
    ROUND(SUM(r.Sales) * 100.0 / SUM(SUM(r.Sales)) OVER (PARTITION BY d.Year), 1) AS pct_of_year_revenue,
    ROUND(SUM(r.Profit) * 100.0 / SUM(r.Sales), 2) AS category_margin_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
GROUP BY d.Year, r.Category
ORDER BY r.Category;

SELECT 
    d.Year,
    r.`Sub-Category`,
    COUNT(*) AS line_items,
    ROUND(SUM(r.Sales), 0) AS revenue,
    ROUND(SUM(r.Profit), 0) AS profit,
    ROUND(SUM(r.Profit) * 100.0 / SUM(r.Sales), 2) AS margin_pct,
    ROUND(AVG(r.Discount) * 100, 1) AS avg_discount_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
WHERE r.Category = 'Technology' 
GROUP BY d.Year, r.`Sub-Category`
ORDER BY r.`Sub-Category`, d.Year;

SELECT 
    d.Year,
    r.`Sub-Category`,
    COUNT(*) AS line_items,
    ROUND(SUM(r.Sales), 0) AS revenue,
    ROUND(SUM(r.Profit), 0) AS profit,
    ROUND(SUM(r.Profit) * 100.0 / SUM(r.Sales), 2) AS margin_pct,
    ROUND(AVG(r.Discount) * 100, 1) AS avg_discount_pct
FROM retail_dataset r
JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
WHERE r.Category = 'Furniture'
GROUP BY d.Year, r.`Sub-Category`
ORDER BY r.`Sub-Category`, d.Year; 

SELECT 
    Category,
    CASE 
        WHEN Discount = 0       THEN '0%'
        WHEN Discount <= 0.10   THEN '1-10%'
        WHEN Discount <= 0.20   THEN '11-20%'
        WHEN Discount <= 0.30   THEN '21-30%'
        WHEN Discount <= 0.40   THEN '31-40%'
        WHEN Discount <= 0.50   THEN '41-50%'
        ELSE                          '51%+'
    END AS discount_band,
    MIN(Discount) AS band_sort_key,
    COUNT(*) AS line_items,
    ROUND(SUM(Sales), 0) AS revenue,
    ROUND(SUM(Profit), 0) AS profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS margin_pct
FROM retail_dataset
GROUP BY Category, discount_band
ORDER BY Category, band_sort_key;

WITH banded AS (
    SELECT 
        Category,
        CASE 
            WHEN Discount = 0       THEN '0%'
            WHEN Discount <= 0.10   THEN '1-10%'
            WHEN Discount <= 0.20   THEN '11-20%'
            WHEN Discount <= 0.30   THEN '21-30%'
            WHEN Discount <= 0.40   THEN '31-40%'
            WHEN Discount <= 0.50   THEN '41-50%'
            ELSE                          '51%+'
        END AS discount_band,
        MIN(Discount) AS band_sort_key,
        SUM(Sales) AS revenue,
        SUM(Profit) AS profit
    FROM retail_dataset
    GROUP BY Category, discount_band
),
margins AS (
    SELECT 
        Category,
        discount_band,
        band_sort_key,
        ROUND(profit * 100.0 / revenue, 2) AS margin_pct,
        LAG(ROUND(profit * 100.0 / revenue, 2)) OVER (PARTITION BY Category ORDER BY band_sort_key) AS prev_margin_pct
    FROM banded
)
SELECT 
    Category,
    discount_band,
    margin_pct,
    prev_margin_pct,
    CASE WHEN margin_pct < 0 AND prev_margin_pct >= 0 THEN 'BREAKEVEN CROSSED HERE' ELSE '' END AS flag
FROM margins
ORDER BY Category, band_sort_key; 

SELECT 
    `Retail Sales People` AS sales_rep,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS margin_pct,
    ROUND(AVG(Discount) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(CASE WHEN Discount > 0.30 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_deals_above_30
FROM retail_dataset
GROUP BY sales_rep
ORDER BY margin_pct ASC; 

SELECT 
	`Retail Sales People` AS sales_rep, 
    `Sub-Category`, ROUND(AVG(Discount)*100,1) AS avg_discount, 
    ROUND(SUM(Profit),0) AS profit
FROM retail_dataset
WHERE `Sub-Category` IN ('Tables', 'Machines')
GROUP BY sales_rep, Category, `Sub-Category`
ORDER BY profit ASC;

SELECT 
    `Retail Sales People` AS sales_rep,
    `Customer ID`, `Customer Name`,
    COUNT(*) AS deals_above_30pct,
    ROUND(AVG(Discount) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(Profit), 0) AS total_profit
FROM retail_dataset
WHERE `Retail Sales People` IN ('Kelly Williams', 'Cassandra Brandow')
  AND Discount > 0.30
GROUP BY sales_rep, `Customer ID`, `Customer Name`
ORDER BY sales_rep, total_profit ASC;

WITH customer_profit AS (
    SELECT 
        `Customer ID`, `Customer Name`,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        ROUND(SUM(Profit), 0) AS total_profit,
        ROUND(AVG(Discount) * 100, 1) AS avg_discount_pct
    FROM retail_dataset
    GROUP BY `Customer ID`, `Customer Name`
),
tiered AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY total_profit DESC) AS profit_tier
    FROM customer_profit
)
SELECT 
    profit_tier,
    COUNT(*) AS customers,
    ROUND(AVG(avg_discount_pct), 1) AS avg_discount_in_tier,
    ROUND(SUM(total_profit), 0) AS tier_profit
FROM tiered
GROUP BY profit_tier
ORDER BY profit_tier;
