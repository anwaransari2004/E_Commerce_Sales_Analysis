CREATE DATABASE E_Commerce_Sales_Analysis;

CREATE TABLE customers(
customer_id INT NOT NULL PRIMARY KEY,
name VARCHAR(20) NOT NULL,
city VARCHAR(25) NOT NULL,
country VARCHAR(25) NOT NULL,
signup_date DATE NOT NULL
);

INSERT INTO customers(customer_id,name,city,country,signup_date)
VALUES (1,'Anwar','Mumbai','India','2023-01-10'),
       (2,'Rahul','Delhi','India','2023-02-15'),
       (3,'Ayesha','Pune','India','2023-03-05'),
       (4,'Rohan','Bangalore','India','2023-03-20'),
       (5,'Neha','Chennai','India','2023-04-01');

CREATE TABLE products(
product_id INT NOT NULL PRIMARY KEY,
product_name VARCHAR(20) NOT NULL,
category VARCHAR(20) NOT NULL,
price INT NOT NULL
);

INSERT INTO products(product_id,product_name,category,price)
VALUES (101,'Laptop','Electronics',55000),
       (102,'Mobile','Electronics',20000),
       (103,'Headphones','Accessories',2000),
       (104,'Keyboard','Accessories',1500),
       (105,'Chair','Furniture',7000);

CREATE TABLE orders (
order_id INT NOT NULL PRIMARY KEY,
customer_id INT NOT NULL,
order_date DATE NOT NULL,
total_amount INT NOT NULL
);

INSERT INTO orders(order_id,customer_id,order_date,total_amount)
VALUES (201,1,'2023-04-10',57000),
       (202,2,'2023-04-12',20000),
       (203,3,'2023-04-15',3500),
       (204,1,'2023-05-01',7000),
       (205,4,'2023-05-03',55000),
       (206,5,'2023-05-10',22000);

CREATE TABLE order_items(
order_item_id INT NOT NULL PRIMARY KEY,
order_id INT NOT NULL,
product_id INT NOT NULL,
quantity INT NOT NULL,
price INT NOT NULL
);

INSERT INTO order_items(order_item_id,order_id,product_id,quantity,price)
VALUES (1,201,101,1,55000),
       (2,201,103,1,2000),
       (3,202,102,1,20000),
       (4,203,104,1,1500),
       (5,203,103,1,2000),
       (6,204,105,1,7000),
       (7,205,101,1,55000),
       (8,206,102,1,20000),
       (9,206,103,1,2000);

SELECT *FROM customers;
SELECT *FROM products;
SELECT *FROM orders;
SELECT *FROM order_items;

-- 1. Display all customers from India
SELECT  *FROM customers
WHERE country='India';

-- 2.Show all products with price greater than 5000
SELECT *FROM products
WHERE price>5000;

-- 3.Find total number of customers
SELECT COUNT(*) FROM customers;

-- 4.List all orders placed in April 2023
SELECT *FROM orders
WHERE order_date BETWEEN '2023-04-01' AND '2023-04-30';

-- 5.Display distinct product categories
SELECT DISTINCT category FROM products;

-- 6.Find total sales amount
SELECT SUM(total_amount) FROM orders;

-- 7.Find customer-wise total spending
SELECT c.name , SUM(o.total_amount) AS total_spending FROM customers AS c
JOIN orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.name;

-- 8.Find category-wise total revenue
SELECT p.category, SUM(o.quantity * o.price) AS total_revenue
FROM products AS p
JOIN order_items AS o
ON p.product_id = o.product_id
GROUP BY p.category;

-- 9.Find the most expensive product
    -- method 1
SELECT p.product_name, MAX(o.price) AS price FROM products AS p
JOIN order_items AS o
ON p.product_id=o.product_id
GROUP BY p.product_name
ORDER BY price DESC
LIMIT 1;
    --mehtod 2
SELECT product_name, price FROM products
ORDER BY price DESC
LIMIT 1;

-- 10.Find customers who placed more than one order
SELECT c.name, COUNT(o.order_id) AS total_orders FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.name
HAVING COUNT(o.order_id) > 1;

-- 11.Calculate average order value
SELECT AVG(total_amount) AS average_order_value FROM orders;

-- 12.Find total quantity sold per product
SELECT p.product_id, p.product_name, SUM(o.quantity) AS total_quantity_sold
FROM products AS p
JOIN order_items AS o
ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name;

-- 13.Display month-wise sales
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month, SUM(total_amount) AS total_sales FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;

-- 14.Find top 3 customers by total spending
SELECT c.name , SUM(o.total_amount) AS total_spending FROM customers AS c
JOIN orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.name
ORDER BY total_spending DESC
LIMIT 3;

-- 15.Rank products based on total sales (use window function)
SELECT p.product_id, p.product_name, SUM(o.quantity * o.price) AS total_sales,RANK() OVER 
(ORDER BY SUM(o.quantity * o.price) DESC) AS sales_rank FROM products AS p
JOIN order_items AS o
ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name;

-- 16.Find customers who never placed any order
SELECT c.name FROM customers AS c
LEFT JOIN orders AS o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 17.Find repeat customers
SELECT c.name, COUNT(o.order_id) AS order_count FROM customers AS c
JOIN orders AS  o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) > 1;

-- 18.Calculate running total of monthly sales
SELECT month, total_sales, SUM(total_sales) OVER (ORDER BY month) AS running_total
FROM (
    SELECT TO_CHAR(order_date, 'YYYY-MM') AS month, SUM(total_amount) AS total_sales FROM orders
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
     ) t
ORDER BY month;

-- 19.Find percentage contribution of each category to total sales
SELECT p.category, SUM(o.quantity * o.price) AS category_sales,
    ROUND(
        SUM(o.quantity * o.price) * 100.0 /
        SUM(SUM(o.quantity * o.price)) OVER (),
        2
        ) AS percentage_contribution FROM products AS p
JOIN order_items AS o
ON p.product_id = o.product_id
GROUP BY p.category;

-- 20.Identify best-selling product in each category
SELECT category, product_name, total_sales
      FROM (
            SELECT p.category, p.product_name,
                   SUM(o.quantity * o.price) AS total_sales,
                   RANK() OVER (
                   PARTITION BY p.category
                   ORDER BY SUM(o.quantity * o.price) DESC
            ) AS rnk FROM products AS p
JOIN order_items AS o
ON p.product_id = o.product_id
GROUP BY p.category, p.product_name
) ranked
WHERE rnk = 1;