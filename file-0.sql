CREATE DATABASE retail_sys;
USE retail_sys;

SELECT * FROM retail_dataset; 
SELECT * FROM datetime_dataset;
     
-- Checking Data Loading
SELECT * 
FROM retail_dataset 
ORDER BY RAND() 
LIMIT 10;
 
SELECT
    MIN(`Order Date`) AS earliest_order,
    MAX(`Ship Date`) AS latest_order,
    DATEDIFF(MAX( `Ship Date`), MIN(`Order Date`)) AS days_covered
FROM retail_dataset;

ALTER TABLE retail_dataset ADD PRIMARY KEY (`Row ID`);
ALTER TABLE datetime_dataset ADD PRIMARY KEY (`Date`);

SHOW KEYS FROM retail_dataset WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM datetime_dataset WHERE Key_name = 'PRIMARY';

SELECT COUNT(*) AS orders_outside_calendar_range
FROM retail_dataset r
LEFT JOIN datetime_dataset d ON r.`Order Date` = d.`Date`
WHERE d.`Date` IS NULL;
