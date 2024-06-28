USE amazon
ALTER TABLE amazon
MODIFY `Invoice ID` VARCHAR(30) NOT NULL,
MODIFY Branch VARCHAR(5) NOT NULL,
MODIFY City VARCHAR(30) NOT NULL,
MODIFY `Customer type` VARCHAR(30) NOT NULL,
MODIFY Gender VARCHAR(10) NOT NULL,
MODIFY `Product line` VARCHAR(100) NOT NULL,
MODIFY `Unit price` DECIMAL(10, 2) NOT NULL,
MODIFY Quantity INT NOT NULL,
MODIFY `Tax 5%` FLOAT(6, 4) NOT NULL,
MODIFY Total DECIMAL(10, 2) NOT NULL,
MODIFY `Date` DATE NOT NULL,
MODIFY `Time` TIME NOT NULL,
MODIFY Payment VARCHAR(50) NOT NULL,
MODIFY cogs DECIMAL(10, 2) NOT NULL,
MODIFY `gross margin percentage` FLOAT(11, 9) NOT NULL,
MODIFY `gross income` DECIMAL(10, 2) NOT NULL,
MODIFY Rating FLOAT NOT NULL;


-- Adding new column timeofday
ALTER TABLE amazon
ADD timeofday VARCHAR(20);

-- Updating values in timeofday
UPDATE amazon
SET timeofday = 
(CASE WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN "Morning"
WHEN Time BETWEEN '12:00:00' AND '18:00:00' THEN "Afternoon"
ELSE "Evening"
END)

-- Adding new column dayname
ALTER TABLE amazon
ADD dayname VARCHAR(10);

-- Updating values in dayname
UPDATE amazon
SET dayname = DAYNAME(Date)

-- Adding new column monthname
ALTER TABLE amazon
ADD monthname VARCHAR(10);

-- Updating values in monthname
UPDATE amazon
SET monthname = MONTHNAME(Date);

-- 1) What is the count of distinct cities in the dataset? CUSTOMER
SELECT City, COUNT(*) AS count FROM amazon 
GROUP BY City
ORDER BY count

-- 2) For each branch, what is the corresponding city?
SELECT DISTINCT Branch, City FROM amazon

-- 3) What is the count of distinct product lines in the dataset? PRODUCT
SELECT `Product line`, COUNT(*) AS Count FROM amazon
GROUP BY `Product line`
ORDER BY Count DESC

-- 4) Which payment method occurs most frequently? CUSTOMER
SELECT  Payment, COUNT(*) AS Count FROM amazon
GROUP BY Payment
ORDER BY Count DESC
LIMIT 1;

-- 5) Which product line has the highest sales? PRODUCT
SELECT `Product line`, SUM(Total) AS Sales FROM amazon
GROUP BY `Product line`
ORDER BY Sales DESC
LIMIT 1;

-- 6) How much revenue is generated each month? SALES
SELECT monthname, SUM(Total) AS Total_Revenue FROM amazon
GROUP BY monthname;

-- 7) In which month did the cost of goods sold reach its peak? SALES
SELECT monthname, SUM(cogs) AS Cost_of_goods_sold FROM amazon
GROUP BY monthname
ORDER BY Cost_of_goods_sold DESC
LIMIT 1;

-- 8) Which product line generated the highest revenue? PRODUCT
SELECT `Product line`, SUM(Total) AS Revenue FROM amazon
GROUP BY `Product line`
ORDER BY Revenue DESC
LIMIT 1;

-- 9) In which city was the highest revenue recorded? SALES
SELECT City, SUM(Total) AS Revenue FROM amazon
GROUP BY City
ORDER BY Revenue DESC
LIMIT 1;

-- 10) Which product line incurred the highest Value Added Tax? PRODUCT
SELECT `Product line`, SUM(`Tax 5%`) AS VAT FROM amazon
GROUP BY `Product line`
ORDER BY VAT DESC
LIMIT 1;

-- 11) For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 
CREATE TEMPORARY TABLE sales AS
(SELECT `Invoice ID`, AVG(Total) OVER(PARTITION BY `Product line`) AS avg_sales FROM amazon
)

-- Adding new column Sales_Rating
ALTER TABLE amazon
ADD Sales_Rating VARCHAR(10);

-- Updating values in Sales_Rating
UPDATE amazon AS A
SET Sales_Rating = (
    CASE 
        WHEN A.Total > (
            SELECT avg_sales 
            FROM sales AS S 
            WHERE A.`Invoice ID` = S.`Invoice ID`
        ) THEN 'Good'
        ELSE 'Bad'
    END
);

SELECT Sales_Rating, COUNT(*) FROM amazon
GROUP BY Sales_Rating

-- 12) Identify the branch that exceeded the average number of products sold.
WITH cte1 AS
(SELECT Branch, SUM(Quantity) AS tot_quantity FROM amazon
GROUP BY Branch)

SELECT Branch FROM cte1
WHERE tot_quantity > (SELECT AVG(tot_quantity) AS avg_quantity FROM cte1)

-- 13) Which product line is most frequently associated with each gender? PRODUCT
SELECT Gender, `Product line`, SUM(Quantity) AS count FROM amazon
GROUP BY Gender, `Product line`
ORDER BY Gender, count DESC

-- 14) Calculate the average rating for each product line. PRODUCT
SELECT `Product line`, ROUND(AVG(Rating),2) AS avg_rating FROM amazon
GROUP BY `Product line`
ORDER BY avg_rating DESC

-- 15) Count the sales occurrences for each time of day on every weekday. SALES
SELECT dayname, timeofday, SUM(Quantity) AS num_of_sales FROM amazon
WHERE dayname NOT IN ('Saturday', 'Sunday')
GROUP BY dayname, timeofday
ORDER BY dayname

-- 16) Identify the customer type contributing the highest revenue. CUSTOMER
SELECT `Customer type`, SUM(Total) AS Revenue FROM amazon
GROUP BY `Customer type`
ORDER BY Revenue DESC
LIMIT 1

-- 17) Determine the city with the highest VAT percentage. SALES
SELECT City, SUM(`Tax 5%`) AS VAT FROM amazon
GROUP BY City
ORDER BY VAT DESC
LIMIT 1

-- 18) Identify the customer type with the highest VAT payments. CUSTOMER
SELECT `Customer type`, SUM(`Tax 5%`) AS VAT FROM amazon
GROUP BY `Customer type`
ORDER BY VAT DESC
LIMIT 1

-- 19) What is the count of distinct customer types in the dataset? CUSTOMER
SELECT `Customer type`, COUNT(*) AS count FROM amazon
GROUP BY `Customer type`

-- 20) What is the count of distinct payment methods in the dataset? CUSTOMER rep
SELECT Payment, COUNT(*) AS count FROM amazon
GROUP BY Payment

-- 21) Which customer type occurs most frequently? CUSTOMER repeated
SELECT `Customer type`, COUNT(*) AS count FROM amazon
GROUP BY `Customer type`
ORDER BY count DESC
LIMIT 1

-- 22) Identify the customer type with the highest purchase frequency. CUSTOMER
SELECT `Customer type`, SUM(Quantity) AS items_bought FROM amazon
GROUP BY `Customer type`
ORDER BY items_bought DESC
LIMIT 1

-- 23) Determine the predominant gender among customers. CUSTOMER rep
SELECT Gender, COUNT(*) AS count FROM amazon
GROUP BY Gender
ORDER BY count DESC

-- 24) Examine the distribution of genders within each branch. CUSTOMER
SELECT Branch, Gender, COUNT(*) AS count FROM amazon
GROUP BY Branch, Gender
ORDER BY Branch, Gender

-- 25) Identify the time of day when customers provide the most ratings. CUSTOMER rep
SELECT timeofday, ROUND(AVG(Rating),2) AS avg_rating FROM amazon
GROUP BY timeofday
ORDER BY avg_rating DESC

-- 26) Determine the time of day with the highest customer ratings for each branch. CUSTOMER
SELECT Branch, timeofday, ROUND(AVG(Rating),2) AS avg_rating FROM amazon
GROUP BY Branch, timeofday
ORDER BY Branch, avg_rating DESC

-- 27) Identify the day of the week with the highest average ratings. CUSTOMER rep
SELECT dayname, ROUND(AVG(Rating),2) AS avg_rating FROM amazon
GROUP BY dayname
ORDER BY avg_rating DESC

-- 28) Determine the day of the week with the highest average ratings for each branch. CUSTOMER
SELECT Branch, dayname, ROUND(AVG(Rating),2) AS avg_rating FROM amazon
GROUP BY Branch, dayname
ORDER BY Branch, avg_rating DESC