-- 1. How many sales occurred during this time period? 

SELECT COUNT(*) AS Sales FROM pricedata
WHERE event_date >= '2018-01-01' AND event_date <= '2021-12-31';


-- 2.Return the top 5 most expensive transactions (by USD price) for this data set. 
-- Return the name, ETH price, and USD price, as well as the date.

SELECT name, eth_price, usd_price, event_date FROM pricedata
ORDER BY usd_price DESC
LIMIT 5;





-- 3. Return a table with a row for each transaction with an event column,
--  a USD price column, and a moving average of USD price that averages the last 50 transactions.

SELECT event_date AS event,
AVG(usd_price) OVER(ORDER by event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_average
FROM pricedata;



-- 4. Return all the NFT names and their average sale price in USD. Sort descending.
-- Name the average column as average_price.

SELECT name, 
AVG(usd_price) AS average_price 
FROM pricedata
GROUP BY name, usd_price
ORDER BY average_price DESC;


-- 5. Return each day of the week and the number of sales that occurred on that day of the week,
-- as well as the average price in ETH. Order by the count of transactions in ascending order.

SELECT dayofweek(event_date) as week_day,
Count(*) as num_of_sales,
AVG(eth_price) AS average_price
FROM pricedata
GROUP BY week_day
ORDER BY num_of_sales;


-- 6. Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, 
-- who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
-- Here’s an example summary:  “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d
-- from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”

SELECT 
CONCAT(
name, " was sold for $", 
ROUND(usd_price, -3), " to " , buyer_address, " from ", seller_address, " on ", 
event_date) AS Summary FROM pricedata;


-- 7. Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.

CREATE VIEW 1919_purchases AS
SELECT * FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;


-- 8.Create a histogram of ETH price ranges. Round to the nearest hundred value. 

SELECT ROUND(eth_price,-2) AS price_ranges,
COUNT(*) AS Count,
RPAD(' ', COUNT(*),'*') AS bar
FROM pricedata
GROUP BY price_ranges
ORDER BY price_ranges;


-- 9.Return a unioned query that contains the highest price each NFT was bought for and a new column called
-- status saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. 
-- The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT,
-- and the status, in ascending order. 

SELECT  name,  MAX(usd_price) AS price,  'highest' AS status
FROM pricedata
GROUP BY name
UNION
SELECT  name, MIN(usd_price) AS price,  'lowest' AS status
FROM pricedata
GROUP BY name
ORDER BY status ASC, name;

-- 10 What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. 

SELECT 
CONCAT(substring(event_date, 1, 4), '/', substring(event_date,6,2)) as Date,
name, 
MAX(usd_price) as usd_price
FROM pricedata
GROUP BY Date, name
order by Date; 

-- 11 Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).


SELECT CONCAT(extract(MONTH FROM event_date), '/', extract(YEAR FROM event_date)) as salemonth,
ROUND(SUM(usd_price),-2) as rounded
FROM pricedata
GROUP BY salemonth;


-- 12 Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"
-- had over this time period.

SELECT COUNT(*) AS Sales FROM pricedata
WHERE seller_address= '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685'
AND event_date >= '2018-01-01' AND event_date <= '2021-12-31';




--  13 Create an “estimated average value calculator” that has a representative price of the collection 
-- every day based off of these criteria:-- 
-- Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
-- Take the daily average of remaining transactions

-- a)First create a query that will be used as a subquery. Select the event date, 
-- the USD price, and the average USD price for each day using a window function. Save it as a temporary table.

CREATE TEMPORARY TABLE dailyprice
(SELECT event_date, usd_price , 
AVG(usd_price) OVER(PARTITION BY event_date) as dailyaverage 
FROM pricedata);

-- b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and 
-- return a new estimated value which is just the daily average of the filtered data

SELECT event_date, AVG(usd_price) as dailyaverage
FROM dailyprice
WHERE usd_price >=(0.1*(dailyaverage))
GROUP BY event_date
ORDER BY event_date;



-- 14 Give a complete list ordered by wallet profitability (whether people have made or lost money)

SELECT buyer_address,
SUM(usd_price - eth_price) AS profitablity
FROM pricedata
GROUP BY buyer_address
ORDER BY profitablity ASC;


SELECT * FROM pricedata
WHERE token_id = 1139;

SELECT * FROM pricedata
WHERE buyer_address ='0x91338ccfb8c0adb7756034a82008531d7713009d';