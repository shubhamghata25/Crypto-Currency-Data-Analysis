USE cryptopunk;
SELECT COUNT(*) AS total_sales
FROM cryptopunkdata;


SELECT name, eth_price, usd_price, day FROM cryptopunkdata
ORDER BY usd_price DESC
LIMIT 5;

WITH moving_avg AS (
    SELECT 
        transaction_hash,
        usd_price,
        AVG(usd_price) OVER (
            ORDER BY transaction_hash ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
        ) AS moving_average
    FROM cryptopunkdata
)
SELECT transaction_hash, usd_price, moving_average
FROM moving_avg;

SELECT * FROM cryptopunkdata;

SELECT name, AVG(usd_price) AS average_price 
FROM cryptopunkdata
GROUP BY name
ORDER BY average_price DESC;

SELECT DAYNAME(day) AS day_of_week,
       COUNT(*) AS sales_count,
       AVG(eth_price) AS average_eth_price
FROM cryptopunkdata
GROUP BY day_of_week
ORDER BY sales_count ASC;

SELECT CONCAT(
       name, ' was sold for $', ROUND(usd_price, 3), ' to ', ï»¿buyer_address, ' from ', seller_address,
       ' on ', day) AS summary
FROM cryptopunkdata;

CREATE VIEW 1919_purchases AS
SELECT *
FROM cryptopunkdata
WHERE ï»¿buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;

SELECT FLOOR(eth_price / 100) * 100 AS price_range,
       COUNT(*) AS count_of_sales
FROM cryptopunkdata
GROUP BY price_range
ORDER BY price_range;

SELECT name, MAX(usd_price) AS price, 'highest' AS status
FROM cryptopunkdata
GROUP BY name
UNION
SELECT name, MIN(usd_price) AS price, 'lowest' AS status
FROM cryptopunkdata
GROUP BY name
ORDER BY name, status;

WITH monthly_sales AS (
    SELECT DATE_FORMAT(day, '%Y-%m') AS month_year,
           name,
           SUM(usd_price) AS total_price
    FROM cryptopunkdata
    GROUP BY month_year, name)
SELECT month_year, name, MAX(total_price) AS max_price
FROM monthly_sales
GROUP BY month_year
ORDER BY month_year;

SELECT DATE_FORMAT(day, '%Y-%m') AS month_year,
       ROUND(SUM(usd_price), -2) AS total_volume
FROM cryptopunkdata
GROUP BY month_year
ORDER BY month_year;
	
SELECT COUNT(*) AS transaction_count
FROM cryptopunkdata
WHERE ï»¿buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

CREATE temporary TABLE daily_avg AS (
    SELECT day,
           usd_price,
           AVG(usd_price) OVER (PARTITION BY day) AS daily_avg_price
    FROM cryptopunkdata
);

SELECT * FROM daily_avg;

WITH daily_avg AS (
    SELECT day,
           usd_price,
           AVG(usd_price) OVER (PARTITION BY day) AS daily_avg_price
    FROM cryptopunkdata
)

SELECT day,
       AVG(usd_price) AS estimated_daily_value
FROM daily_avg
WHERE usd_price >= daily_avg_price * 0.1
GROUP BY day
ORDER BY day;

WITH MonthlyHighestSales AS (
    SELECT 
        DATE_FORMAT(day, '%Y-%m') AS YearMonth,
        name,
        MAX(usd_price) AS MaxPriceUSD
    FROM 
        cryptopunkdata
    GROUP BY 
        YearMonth, name
),
TopNFTsPerMonth AS (
    SELECT 
        YearMonth,
        name,
        MaxPriceUSD,
        ROW_NUMBER() OVER (PARTITION BY YearMonth ORDER BY MaxPriceUSD DESC) AS Rank
    FROM 
        MonthlyHighestSales
)
SELECT 
    YearMonth,
    name,
    MaxPriceUSD
FROM 
    TopNFTsPerMonth
WHERE 
    Rank = 1
ORDER BY 
    YearMonth ASC;

SELECT DATE_FORMAT(STR_TO_DATE(day, '%m/%d/%y'), '%Y-%m') AS yearsmonth, 
    name,
    MAX(usd_price) AS max_usd_price 
FROM 
    cryptopunkdata
GROUP BY 
    DATE_FORMAT(STR_TO_DATE(day, '%m/%d/%y'), '%Y-%m'),
    name 
ORDER BY 
    yearsmonth ASC; 
    

