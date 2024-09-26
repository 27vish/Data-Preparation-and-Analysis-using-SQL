/* Create the Table */

CREATE TABLE IF NOT EXISTS store(
ROW_ID SERIAL, 
Order_ID CHAR(25),
Order_Date DATE, 
Ship_Date DATE,
Ship_Mode VARCHAR(50), 
Customer_ID VARCHAR(25), 
Customer_Name VARCHAR(75),
Segment VARCHAR(25), 
Country VARCHAR(50), 
City VARCHAR(50), 
States VARCHAR(50),
Postal_Code INTEGER,
Region VARCHAR(12), 
Product_ID VARCHAR(75), 
Category VARCHAR(25),
Sub_Category VARCHAR(25), 
Product_Name VARCHAR(255), 
Sales FLOAT,
Quantity INTEGER, 
Discount FLOAT, 
Profit FLOAT, 
Discount_Amount FLOAT, 
Years INTEGER, 
Customer_Duration VARCHAR(50),
Returned_Items VARCHAR(50),
Return_Reason VARCHAR(255)
);
                                
/* Importing csv file */

COPY store(
ROW_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,States,
Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales,Quantity,Discount,Profit,Discount_Amount,
Years,Customer_Duration,Returned_Items,Return_Reason)
FROM 'C:\Users\vishc\Downloads\Store.csv' 
WITH DELIMITER ',' CSV HEADER ENCODING 'windows-1251';


/* First dataset look */

SELECT * FROM store;

/* Check the size of database */

SELECT pg_size_pretty(pg_database_size('Data_Analysis'));

/* Check the Table size */

SELECT pg_size_pretty(pg_relation_size('store'));

/* Check Dataset Information */

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'store';

/* Get column names of store data */

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'store';

/* Dropping Unnecessary column like Row_ID */

ALTER TABLE store
DROP COLUMN row_id;

/* checking null values of store data */

SELECT * FROM store
WHERE store is NULL;



/* PRODUCT LEVEL ANALYSIS */

/* What are the unique product categories? */

SELECT DISTINCT(category) FROM store;

/* What are the different sub-category in each of The category */

SELECT category, sub_category FROM store
GROUP BY category, sub_category
ORDER BY category ASC, sub_category ASC;

/* What are the number of unique products in each category? */

SELECT category, COUNT(DISTINCT(product_name)) AS Prodcuts_count
FROM store
GROUP BY category
ORDER BY COUNT(product_name) DESC;

/* Find the number of unique products in each sub-category? */
SELECT Sub_Category, COUNT(DISTINCT(product_name)) AS No_of_products
FROM store
GROUP BY Sub_Category
ORDER BY COUNT(product_name) DESC;

/* Which are the Top 10 Products that are ordered frequent. */

SELECT product_name, COUNT(order_id) AS No_of_Products 
FROM store
GROUP BY product_name
ORDER BY COUNT(order_id) DESC
LIMIT 10;

/* Which are the Least 10 sold Products. */

SELECT product_name, COUNT(order_id) AS No_of_Products 
FROM store
GROUP BY product_name
ORDER BY COUNT(order_id) ASC
LIMIT 10;

/* Calculate the cost for each Order_ID with respective Product Name. */
SELECT order_id, product_name, 
ROUND((sales-profit)::NUMERIC,2) AS cost
FROM store;

/* Calculate % profit for each Order_ID with respective Product Name. */

SELECT order_id, product_name, 
ROUND((profit/(sales-profit)*100)::NUMERIC,2) AS percentage_profit
FROM store;

/* Calculate the overall profit of the store. */

SELECT ROUND((SUM(profit)/(SUM(sales)-SUM(profit))*100)::NUMERIC,2) AS overall_percentage_profit
FROM store;

/* Calculate the total sales, total profit and overall profit of the store. */

SELECT SUM(sales) AS total_sale, SUM(profit) AS toal_profit, 
ROUND((SUM(profit)/(SUM(sales)-SUM(profit))*100)::NUMERIC,2) AS overall_percentage_profit
FROM store;

/* Find the unique years present in the data set */

SELECT DISTINCT(years) FROM store;

-- In four years just 14.24% returns is too less in business that is not good.

/* Where can we trim loses?
   In which products?
   We can do this by calculating the average sales and profits, and comparing the values of
   that average.
   If the sales or profits are below average, then they are not best sellers and
   can be analysed deeper to see it its worth selling them anymore*/

SELECT ROUND((AVG(sales)::NUMERIC),2) AS avg_sales
FROM store;

--The average sales on any given product is 229.83, so approx 230.

SELECT ROUND((AVG(profit)::NUMERIC),2) AS avg_profit
FROM store;

--The average profit on any given product is 28.6, so approx 29.


--I want to see the products which are not meeting my average sales.
/* Find average sales per sub-cateegory. */

SELECT Sub_Category, ROUND((AVG(sales)::NUMERIC),2) AS avg_sales
FROM store
GROUP BY Sub_Category
ORDER BY avg_sales ASC
LIMIT 9;

--These are the products which are not meeting my entire store average sales

--I want to see the products which are not meeting my average profit.
/* Find average profit per sub-cateegory. */

SELECT ROUND((AVG(profit)::NUMERIC),2) AS avg_profit, Sub_Category
FROM store
GROUP BY Sub_Category
ORDER BY avg_profit ASC
LIMIT 11;

--These are the products which are not meeting my entire store average profit.


/* CUSTOMER LEVEL ANALYSIS */

/* What is the number of unique customer IDs? */

SELECT COUNT(DISTINCT(customer_id)) AS unique_customer
FROM store;

/* Find those customer who registered during 2013-2016 */

SELECT DISTINCT(customer_name), customer_id, order_id, city, postal_code 
FROM store
WHERE (customer_id IS NOT NULL);

/* Calculae Total Frequency of each order id by each customer Name is descending order */

SELECT order_id, customer_name, COUNT(order_id) AS total_order_id
FROM store
GROUP BY order_id, customer_name
ORDER BY total_order_id DESC;

/* Calculate cost of each customer name. */

SELECT customer_id, order_id, quantity, 
customer_name, (sales-profit) AS costs 
FROM store
GROUP BY customer_id, order_id, quantity, customer_name, costs
ORDER BY costs DESC;

/* Display No of Customers in each region in descending order. */

SELECT region, COUNT(customer_id) AS no_of_customers
FROM store
GROUP BY region
ORDER BY no_of_customers DESC;

/* Find Top 10 customers who order frequently. */

SELECT customer_name, COUNT(order_id) AS no_of_orders
FROM store
GROUP BY customer_name
ORDER BY no_of_orders DESC
LIMIT 10;

/* Display the records for customers who live in state California 
   and Have Postal code 90032. */

SELECT * FROM store
WHERE states = 'California' AND postal_code = 90032;

/* Find Top 20 customers who benifited the store. */

SELECT customer_name, profit, city, states
FROM store
GROUP BY  customer_name, Profit, ciTy, states
ORDER BY  profit DESC
LIMIT 20;

/* Which state(S) is the superstore most succesful in? Least?
   Top 10 results: */

SELECT states, ROUND(SUM(sales)::NUMERIC,2) AS state_sales
FROM store
GROUP BY states
ORDER BY state_sales DESC
LIMIT 10;



/* ORDER LEVEL ANALYSIS */

/* Number of unique orders */

SELECT COUNT(DISTINCT(order_id)) AS no_of_unique_orders 
FROM store;

/* Find Sum Total Sales of Superstore. */

SELECT ROUND(SUM(sales)::NUMERIC,2) AS Total_Sales
FROM store;

/* Calculate the time taken for an order to ship and converting the 
   no. of days in int format. */

SELECT order_id, customer_id, customer_name city, states, 
(ship_date - order_date) AS delivery_duration
FROM store
ORDER BY delivery_duration DESC
LIMIT 20;

/* Extract the year for respective order ID and Cusomer ID wih quantity. */

SELECT order_id, customer_id, quantity,
EXTRACT(YEAR FROM order_date)
FROM store 
GROUP BY order_id, customer_id, quantity, EXTRACT(YEAR FROM order_date) 
ORDER BY quantity DESC;

/* What is the Sales impact? */

SELECT EXTRACT(YEAR FROM order_date) AS years, sales,
ROUND((profit/(sales-profit)*100)::NUMERIC,2) AS profit_percentage
FROM store
GROUP BY EXTRACT(YEAR FROM order_date), sales, profit_percentage
ORDER BY profit_percentage
LIMIT 20;

/* Breakdown by Top vs Worst Seller:
   Find Top 10 Categories (with the addition of best sub-category within the category) */

/* Find Top 10 Sub-Categories. */

SELECT ROUND(SUM(sales)::NUMERIC, 2) AS prod_sales, category, sub_category
FROM store
GROUP BY category, sub_category
ORDER BY prod_sales DESC
LIMIT 10;

/* Find Worst 10 Sub-Categories. */

SELECT ROUND(SUM(sales)::NUMERIC, 2) AS prod_sales, category, sub_category
FROM store
GROUP BY category, sub_category
ORDER BY prod_sales ASC
LIMIT 10;

/* Show the Basic Order information. */

SELECT COUNT(order_id) AS Purchases,
ROUND(SUM(sales)::NUMERIC, 2) AS Total_Sales,
ROUND((SUM(((profit/(sales-profit))*100))/COUNT(*))::NUMERIC,2) AS Avg_Percentage_Profit,
MIN(order_date) AS First_purchase_date,
MAX(order_id) AS Latest_purchase_date,
COUNT(DISTINCT(product_name)) AS Product_Purchased,
COUNT(DISTINCT(city)) AS Location_count
FROM store;



/* RETURN LEVEL ANALYSIS */

/* Find the number of returned orders. */

SELECT COUNT(returned_items) AS Reurned_Items_Count
FROM store
WHERE returned_items = 'Returned' 

/* Find Top 10 returned categories. */

SELECT category, returned_items, 
COUNT(returned_items) AS No_of_Returned
FROM store
WHERE  returned_items = 'Returned'
GROUP BY category, sub_category, returned_items
ORDER BY No_of_Returned DESC
LIMIT 10;

/* Find Top 10 returned sub_categories. */

SELECT sub_category, returned_items, 
COUNT(returned_items) AS No_of_Returned
FROM store
WHERE  returned_items = 'Returned'
GROUP BY category, sub_category, returned_items
ORDER BY No_of_Returned DESC
LIMIT 10;

/* Find Top 10 Customers Returned frequently. */

SELECT customer_id, customer_name, city, returned_items, 
COUNT(returned_items) AS Returned_Iems_Count
FROM store
WHERE  returned_items = 'Returned'
GROUP BY customer_id, customer_name, city, returned_items
ORDER BY Returned_Iems_Count DESC
LIMIT 10;