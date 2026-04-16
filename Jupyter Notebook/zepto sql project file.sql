# Creating a database
CREATE DATABASE zepto_SQL_project;

#Using that database
USE zepto_SQL_project;

# Creating a table
CREATE TABLE zepto (
	sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(10,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(10,2),
    weightInGms INT,
    outOfStock VARCHAR(5),
    quantity INT
);

# If want to delete a table
DROP TABLE IF EXISTS zepto;


#data exploration

#count of rows
SELECT COUNT(*) FROM zepto;

#sample data
SELECT * FROM zepto
LIMIT 15;

#Lets check if we have any null values
SELECT * FROM zepto
WHERE name is NULL
OR
category is NULL
OR
mrp is NULL
OR
discountPercent is NULL
OR
availableQuantity is NULL
OR
discountedSellingPrice is NULL
OR
weightInGms is NULL
OR
outOfStock is NULL
OR
quantity is NULL;

# lets check different product category
SELECT DISTINCT category
FROM zepto
ORDER by category;

# product in stock vs product out of stock
SELECT outOfStock, COUNT('sku_id')
FROM zepto
GROUP BY outOfStock;

# Product names mentioned multiple times
SELECT name, COUNT(sku_id) as "Number of Stock Keeping Unit"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) >1
ORDER BY COUNT(sku_id) DESC;

# Data Cleaning

# Find the item which have 0 price and delete them
SELECT * FROM zepto
WHERE mrp = 0 or discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0
LIMIT 100;

SELECT COUNT(*) 
FROM zepto
WHERE mrp = 0;

# converting paisa to rupees
UPDATE zepto
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0; 

SELECT mrp, discountedSellingPrice FROM zepto;

# Q.1 Find the top 10 best-value product based on discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

SELECT name, mrp, discountedSellingPrice,
ROUND((mrp - discountedSellingPrice)/mrp * 100,2) AS actual_discount
FROM zepto
ORDER BY actual_discount DESC
LIMIT 10;

# Q.2 What are the Products with the high value but out of Stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = 'TRUE' and mrp > 300 
ORDER BY mrp DESC;

# Q.3 Calculate estimated revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

# Q.4 Find all the products where mrp is greater than 500 and discount is less than 10%
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC;

# Q.5 Identify the top 5 categories offering the highest average discount percentage
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

# Q.6 Find the price per gram of products above 100 gram and sort by value 
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_perGram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_perGram DESC; 

	
# Q.7 Group the product into categories like low, medium and bulk
SELECT DISTINCT name, weightInGms,
CASE 
	WHEN weightInGms <1000 THEN 'Low'
	WHEN weightInGms <5000 THEN 'Medium'
    ELSE 'Bulk'
END As weight_category
FROM zepto;

# Q.8 What is the total Inventory Weight per Category
SELECT category,
SUM(weightInGms*availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

-- Q.9 Top 3 expensive products in each category
SELECT *
FROM (
    SELECT category, name, mrp,
    RANK() OVER (PARTITION BY category ORDER BY mrp DESC) AS rank_in_category
    FROM zepto
) t
WHERE rank_in_category <= 3;

-- Q.10 Categories with highest out-of-stock percentage
SELECT category,
ROUND(SUM(CASE WHEN outOfStock = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS out_of_stock_percentage
FROM zepto
GROUP BY category
ORDER BY out_of_stock_percentage DESC;
 