# Retail-Sales-and-Customer-Insight-Analysis
Welcome to the Retail Sales and Customer Insights Analysis project! This project uses SQL to analyze retail data, focusing on sales, customer behavior, and inventory. It looks at a fictional retail company’s data to find useful insights for better business decisions.

📋 **Project Overview:**
This project uses SQL to analyze sales, customer, and product data, identifying trends and patterns. It applies advanced SQL techniques like window functions, CTEs, joins, and aggregations to deliver detailed insights. The main areas of focus are:
- Sales Patterns
- Customer Groups
- Product Performance
- Inventory Management

📊 **Dataset Description:**
The dataset consists of four interrelated tables:

**1. Customers Table**
Details about the company's customers.
- customer_id (Primary Key)
- first_name, last_name, email, gender, date_of_birth, registration_date, last_purchase_date

**2. Products Table**
Information about products in the inventory.
- product_id (Primary Key)
- product_name, category, price, stock_quantity, date_added

**3. Sales Table**
Details about each sale made.
- sale_id (Primary Key)
- customer_id (Foreign Key), product_id (Foreign Key)
- quantity_sold, sale_date, discount_applied, total_amount

**4. Inventory Movements Table**
Tracks inventory changes.
- movement_id (Primary Key)
- product_id (Foreign Key)
- movement_type (IN for restock, OUT for sales), quantity_moved, movement_date


🎯 **Key Objectives & Questions:**

**Module 1: Sales Performance Analysis**
- Calculate total sales per month (units and revenue).
- Determine the average discount applied monthly.

**Module 2: Customer Behavior and Insights**
- Identify high-value customers and their details.
- Find the oldest customers born in the 1990s and their order details.
- Create customer segments (e.g., Low, Medium, High Spenders) based on total spending.

**Module 3: Inventory and Product Management**
- Identify products running low on stock and recommend restocking amounts.
- Analyze daily inventory movements (restock vs. sales).
- Rank products within each category by price.

**Module 4: Advanced Analytics**
- Calculate the average order size by product.
- Identify products with recent restocking activity.

**SQL Features Used**
This project employs advanced SQL concepts to handle complex queries efficiently:
- Common Table Expressions (CTEs)
- Window Functions
- Subqueries
- Joins (Inner, Left, Right)
- Group By & Having Clauses
- Aggregations (SUM, AVG, COUNT)
- Case Statements


📜 **Deliverables**  
- **SQL Queries:** Organized SQL scripts for each module.  
- **Analysis Report:** Detailed report summarizing key insights.  
