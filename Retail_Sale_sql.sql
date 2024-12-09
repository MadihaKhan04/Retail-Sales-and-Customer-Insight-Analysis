create database portfolio_project;

use portfolio_project;

select * from customers_data;
select * from inventory_movements_data;
select * from products_data;
select * from sales_data;

-- Adding Primary Keys
Alter table customers_data
add primary key (customer_id);

Alter table products_data
add primary key (product_id);

Alter table sales_data
add primary key (sale_id);

Alter table inventory_movements_data
add primary key (movement_id);

-- Add Foreign key
alter table sales_data
add constraint fk_customer
foreign key (customer_id)
references customers_data(customer_id);

alter table sales_data
add constraint fk_product
foreign key (product_id) 
references Products_data(product_id);

alter table inventory_movements_data
add constraint fk_product2
foreign key (product_id)
references Products_data(product_id);


-- text to date
ALTER TABLE Sales_data
MODIFY sale_date DATE;

Alter table customers_data
MODIFY date_of_birth DATE;

Alter table customers_data
MODIFY registration_date DATE;

Alter table customers_data
MODIFY last_purchase_date DATE;

Alter table inventory_movements_data
MODIFY movement_date DATE;

-- Module 1: Sales Performance Analysis
-- 1. Total Sales per Month:
-- Calculate the total sales amount per month, including the number of units sold
-- and the total revenue generated.
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
    SUM(quantity_sold) AS units_sold,
    ROUND(SUM(total_amount), 2) AS revenue_generated
FROM
    sales_data
GROUP BY sale_month
ORDER BY sale_month;

-- 2. Average Discount per Month:
-- Calculate the average discount applied to sales in each month and assess how
-- discounting strategies impact total sales.
SELECT
	DATE_FORMAT(sale_date, '%Y-%m') AS sale_month, 
    AVG(discount_applied) AS average_discount,
    ROUND(SUM(total_amount),2) AS total_sales
FROM
    sales_data
GROUP BY sale_month
ORDER BY sale_month;

-- Module 2: Customer Behavior and Insights
-- 3. Identify high-value customers:
-- Which customers have spent the most on their purchases? Show their details
WITH customer_spending as(
SELECT 
    c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, 
    c.email, c.gender,
	SUM(s.total_amount) AS total_spending
FROM customers_data c
JOIN sales_data s 
ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.gender )

select customer_id, full_name, email, gender,
ROUND(total_spending,2) as total_spending
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 10;      -- using Limit to see the top 10 customers

-- 4. Identify the oldest Customer:
--  Find the details of customers born in the 1990s, including their total spending and
-- specific order details.
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    c.date_of_birth,
    ROUND(SUM(s.total_amount),2) AS total_spending
FROM
    customers_data c
        JOIN
    sales_data s ON c.customer_id = s.customer_id
WHERE
    c.date_of_birth BETWEEN '1990-01-01' AND '1999-12-31'
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email, c.date_of_birth;
    
-- 5. Customer Segmentation:
-- Use SQL to create customer segments based on their total spending (e.g., Low
-- Spenders, High Spenders).
WITH customer_spending AS (
    SELECT c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name, c.email,
        ROUND(SUM(s.total_amount), 2) AS total_spending
    FROM customers_data c
        JOIN sales_data s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email )
SELECT *,
    CASE
        WHEN total_spending <= 1500 THEN 'Low Spender'
        WHEN total_spending <= 4000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS Type_of_Spender
FROM customer_spending
ORDER BY customer_id;

-- Module 3: Inventory and Product Management
-- 6. Stock Management:
-- Write a query to find products that are running low in stock (below a threshold like  10 units)
-- and recommend restocking amounts based on past sales performance.

WITH average_sales AS (
    SELECT 
        p.product_id, p.product_name, p.category, p.stock_quantity,
        AVG(s.quantity_sold) AS avg_sales_per_day
    FROM products_data p
    JOIN sales_data s 
    ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity)
    
SELECT 
    product_id, product_name, category, stock_quantity,
    CASE
        WHEN stock_quantity <= 10 THEN "Low in stock"
        ELSE "Sufficient stock"
    END AS restocking_information,
    ROUND(avg_sales_per_day * 7) AS recommended_restocking_amount -- Assuming one week of inventory
FROM 
    average_sales
ORDER BY 
    stock_quantity;

-- 7. Inventory Movements Overview:
-- Create a report showing the daily inventory movements (restock vs. sales) for each product over 
-- a given period.
SELECT 
	movement_date,
    product_id,
    SUM(CASE WHEN movement_type = 'IN' THEN quantity_moved ELSE 0 END) AS restock_quantity,
    SUM(CASE WHEN movement_type = 'OUT' THEN quantity_moved ELSE 0 END) AS sales_quantity
FROM 
    inventory_movements_data
WHERE movement_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY 
    movement_date, product_id
ORDER BY 
    movement_date, product_id;
    
-- 8. Rank Products::
-- Rank products in each category by their prices
SELECT 
    category,
    product_id,
    product_name,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
FROM 
    products_data;

-- Module 4: Advanced Analytics
-- 9. Average order size:
-- What is the average order size in terms of quantity sold for each product?
SELECT 
    product_id,
    AVG(quantity_sold) AS average_order_size
FROM 
    sales_data
GROUP BY 
    product_id;
    
-- 10. Recent Restock Product:
-- Which products have seen the most recent restocks
SELECT 
    p.product_id, p.product_name, p.category,
    MAX(m.movement_date) AS last_restock_date
FROM Inventory_Movements_data m
join products_data p
on p.product_id = m.product_id
WHERE movement_type = 'IN'
GROUP BY p.product_id
ORDER BY last_restock_date DESC
LIMIT 10;

-- Advanced Features to Challenge Students
-- Dynamic Pricing Simulation: 
-- Challenge students to analyze how price changes for
-- products impact sales volume, revenue, and customer behavior.

WITH price_impact AS (
    SELECT s.product_id, DATE_FORMAT(s.sale_date, '%Y-%m') AS sale_month,
	AVG(p.price) AS avg_price, SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
    FROM sales_data s
    JOIN products_data p
    ON s.product_id = p.product_id
    GROUP BY s.product_id, DATE_FORMAT(s.sale_date, '%Y-%m')
),

Analysis AS (
    SELECT product_id, sale_month, avg_price, total_units_sold, total_revenue,
	CASE
	WHEN total_units_sold > 0 THEN ROUND(total_revenue / total_units_sold, 2)
	ELSE 0
	END AS revenue_per_unit
    FROM price_impact
)
SELECT * 
FROM Analysis
ORDER BY product_id, sale_month;

-- Customer Purchase Patterns:
-- Analyze purchase patterns using time-series data and
-- window functions to find high-frequency buying behavior.

WITH Purchase_Patterns AS (
    SELECT 
        c.customer_id, 
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        DATE_FORMAT(s.sale_date, '%Y-%m') AS Purchase_month,
        COUNT(s.sale_id) AS Purchase_count, 
        SUM(s.total_amount) AS Spent_amount,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY SUM(s.total_amount) DESC) AS customer_rank
    FROM customers_data c
    JOIN sales_data s 
    ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, full_name, Purchase_month
)
SELECT  
    customer_id, full_name, Purchase_month, 
    Purchase_count, Spent_amount
FROM  Purchase_Patterns
WHERE customer_rank = 1
ORDER BY Purchase_count DESC, Spent_amount DESC
LIMIT 10;

-- Predictive Analytics:
-- Use past data to predict which customers are most likely to churn
-- and recommend strategies to retain them.

WITH customer_activity AS (
    SELECT 
        c.customer_id, MAX(s.sale_date) AS last_purchase_date,
        COUNT(s.sale_id) AS total_orders, SUM(s.total_amount) AS total_spent
    FROM customers_data c
    LEFT JOIN sales_data s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id
),
churn_prediction AS (
    SELECT 
        customer_id,
        DATEDIFF(CURDATE(), last_purchase_date) AS days_since_last_purchase,
        total_orders, total_spent,
        CASE
            WHEN DATEDIFF(CURDATE(), last_purchase_date) > 180 THEN 'High Risk'
            WHEN DATEDIFF(CURDATE(), last_purchase_date) BETWEEN 90 AND 180 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS churn_risk
    FROM customer_activity
)
SELECT 
    customer_id, days_since_last_purchase,
    total_orders, total_spent, churn_risk
FROM churn_prediction
ORDER BY churn_risk DESC, total_spent DESC;




