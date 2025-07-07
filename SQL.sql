CREATE DATABASE DBT_LABS;

CREATE SCHEMA RAW;

CREATE OR REPLACE TABLE customers (
    customer_id INT AUTOINCREMENT,  -- Auto-increment primary key
    customer_name VARCHAR(255),
    email VARCHAR(255),
    signup_date DATE,
    PRIMARY KEY (customer_id)
);



CREATE OR REPLACE TABLE orders (
    order_id INT AUTOINCREMENT,  -- Auto-increment primary key
    customer_id INT,             -- Foreign key from customers table
    product_id INT,              -- Foreign key from products table
    order_amount DECIMAL(10, 2),
    order_date DATE,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE OR REPLACE TABLE products (
    product_id INT AUTOINCREMENT, -- Auto-increment primary key
    product_name VARCHAR(255),
    category VARCHAR(255),
    price DECIMAL(10, 2),
    PRIMARY KEY (product_id)
);

INSERT INTO customers (customer_name, email, signup_date) VALUES
('John Doe', 'john@example.com', '2023-01-01'),
('Jane Smith', 'jane@example.com', '2023-02-15'),
('Alice Brown', 'alice@example.com', '2023-03-20'),
('Bob White', 'bob@example.com', '2023-04-10');

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 1000.00),
('Smartphone', 'Electronics', 600.00),
('Tablet', 'Electronics', 300.00),
('Chair', 'Furniture', 150.00),
('Desk', 'Furniture', 250.00),
('Monitor', 'Electronics', 200.00);

INSERT INTO orders (customer_id, product_id, order_amount, order_date) VALUES
(1, 1, 1000.00, '2023-05-01'),
(1, 2, 600.00, '2023-05-03'),
(2, 3, 300.00, '2023-05-05'),
(3, 4, 150.00, '2023-05-06'),
(2, 5, 250.00, '2023-05-10'),
(1, 6, 200.00, '2023-05-15'),
(4, 1, 1000.00, '2023-05-20');

-- ---------------------------------------------------------------------------------------------------------------------





SHOW DATABASES;

USE DATABASE DBT_LABS;

USE SCHEMA RAW;

SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERS;
SELECT * FROM PRODUCTS;


-- 1. Question: Given a table orders with columns order_id, customer_id, order_amount, 
-- and order_date, write a query to calculate the total amount spent by each customer.

SELECT customer_id, SUM(order_amount) AS total_spent
FROM orders
GROUP BY customer_id;


-- Question: Write a query to find all orders placed in the last 30 days.
SELECT *
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30' DAY;


-- Write a query to return each customer’s order and 
-- the running total of their order amounts, ordered by the date of the order.
SELECT customer_id, order_id, order_amount, 
       SUM(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS running_total
FROM orders;

-- Question: Write a query to find customers who placed more than 3 orders.
SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 3;


-- Question: Write a query to find the top 3 customers by the total amount spent.
WITH customer_totals AS (
  SELECT customer_id, SUM(order_amount) AS total_spent
  FROM orders
  GROUP BY customer_id
)
SELECT customer_id, total_spent
FROM customer_totals
ORDER BY total_spent DESC
LIMIT 3;

SELECT customer_id, SUM(order_amount) AS total_spent
  FROM orders
  GROUP BY customer_id
  ORDER BY SUM(order_amount) DESC
  LIMIT 3;



-- Question: Write a query to return the total order amount 
-- for each customer, treating NULL order amounts as 0.

SELECT customer_id, SUM(COALESCE(order_amount, 0)) AS total_spent
FROM orders
GROUP BY customer_id;

--  Self Join:
-- Question: Write a query to find all customers 
-- who placed an order on the same day as another customer.

SELECT 
    a.customer_id AS customer1, 
    b.customer_id AS customer2, 
    a.order_date
FROM 
    orders a
JOIN 
    orders b 
ON a.order_date = b.order_date 
AND a.customer_id != b.customer_id;

-- Ranking with Window Functions:
-- Question: Write a query to assign a rank to each customer based 
-- on their total order amount.

SELECT customer_id, SUM(order_amount) AS total_spent,
       RANK() OVER (ORDER BY SUM(order_amount) DESC) AS customer_rank
FROM orders
GROUP BY customer_id;

-- You have three tables: orders, customers, and products. 
-- Write a query to find the total amount spent by each customer 
-- on a specific product category (e.g., 'Electronics').
SELECT 
    c.customer_name, 
    SUM(o.order_amount) AS total_spent
FROM 
    orders o
JOIN 
    customers c 
    ON o.customer_id = c.customer_id
JOIN 
    products p 
    ON o.product_id = p.product_id
WHERE 
    p.category = 'Electronics'
GROUP BY 
    c.customer_name;

-- -----------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------
-- Based on Employee, Manager, Salary tables

CREATE OR REPLACE TABLE employees (
    employee_id INT AUTOINCREMENT,   -- Auto-increment primary key
    employee_name VARCHAR(255),
    hire_date DATE,
    department VARCHAR(255),
    manager_id INT,                  -- Foreign key referencing another employee
    PRIMARY KEY (employee_id)
);

CREATE OR REPLACE TABLE managers (
    manager_id INT AUTOINCREMENT,    -- Auto-increment primary key
    manager_name VARCHAR(255),
    hire_date DATE,
    department VARCHAR(255),
    PRIMARY KEY (manager_id)
);

CREATE OR REPLACE TABLE salaries (
    employee_id INT,                 -- Foreign key referencing employees table
    salary DECIMAL(10, 2),
    bonus DECIMAL(10, 2),
    salary_date DATE,
    PRIMARY KEY (employee_id, salary_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

INSERT INTO managers (manager_name, hire_date, department) VALUES
('Alice Johnson', '2015-05-15', 'Finance'),
('Robert Smith', '2013-11-20', 'IT'),
('Emily Davis', '2016-07-30', 'HR'),
('Michael Brown', '2012-09-12', 'Sales'),
('Sophia Wilson', '2017-03-15', 'Marketing'),
('James Taylor', '2014-01-10', 'Operations'),
('Linda Anderson', '2013-02-25', 'Logistics'),
('Barbara Moore', '2010-06-01', 'Finance'),
('David Harris', '2018-09-14', 'R&D'),
('Jennifer Clark', '2011-11-05', 'HR'),
('Joseph Lewis', '2012-12-22', 'IT'),
('Sarah Walker', '2019-05-18', 'Sales'),
('Karen Hall', '2015-10-25', 'Operations'),
('Thomas Allen', '2017-12-09', 'Finance'),
('Nancy King', '2014-07-19', 'Marketing'),
('Mark Wright', '2011-09-23', 'Logistics'),
('Laura Young', '2010-04-17', 'IT'),
('Christopher Scott', '2016-02-13', 'R&D'),
('Patricia Adams', '2012-08-30', 'Sales'),
('Anthony Turner', '2019-03-07', 'HR');

INSERT INTO employees (employee_name, hire_date, department, manager_id) VALUES
('John Doe', '2019-04-10', 'Finance', 1),
('Jane White', '2020-06-15', 'IT', 2),
('Mark Black', '2021-03-01', 'IT', 2),
('Emma Green', '2018-01-21', 'HR', 3),
('Tom Blue', '2022-08-11', 'Sales', 4),
('Lucy Pink', '2019-02-25', 'Finance', 1),
('James Yellow', '2021-11-05', 'Sales', 4),
('Mia Brown', '2020-09-05', 'Marketing', 5),
('Ethan Grey', '2022-01-14', 'Finance', 8),
('Liam Red', '2021-06-17', 'IT', 12),
('Olivia Purple', '2019-12-20', 'Operations', 6),
('Noah Silver', '2018-05-28', 'Logistics', 7),
('Sophia Gold', '2020-07-30', 'Finance', 8),
('William Pink', '2022-02-10', 'R&D', 9),
('Isabella Blue', '2021-04-25', 'HR', 3),
('Lucas Green', '2020-11-09', 'Sales', 4),
('Mason Orange', '2017-10-12', 'Operations', 13),
('Evelyn Black', '2016-03-30', 'IT', 2),
('Harper Grey', '2023-05-12', 'HR', 20),
('Benjamin Violet', '2022-06-19', 'Finance', 14);

INSERT INTO salaries (employee_id, salary, bonus, salary_date) VALUES
(1, 60000, 5000, '2023-01-01'),
(2, 70000, 6000, '2023-01-01'),
(3, 75000, 5500, '2023-01-01'),
(4, 65000, 3000, '2023-01-01'),
(5, 58000, 4000, '2023-01-01'),
(6, 62000, 5000, '2023-01-01'),
(7, 55000, 4500, '2023-01-01'),
(8, 61000, 4800, '2023-01-01'),
(9, 65000, 5300, '2023-01-01'),
(10, 72000, 7000, '2023-01-01'),
(11, 69000, 4500, '2023-01-01'),
(12, 63000, 4100, '2023-01-01'),
(13, 68000, 6200, '2023-01-01'),
(14, 60000, 5100, '2023-01-01'),
(15, 67000, 5200, '2023-01-01'),
(16, 59000, 4600, '2023-01-01'),
(17, 74000, 6800, '2023-01-01'),
(18, 80000, 7000, '2023-01-01'),
(19, 52000, 3800, '2023-01-01'),
(20, 58000, 4700, '2023-01-01');


INSERT INTO salaries (employee_id, salary, bonus, salary_date) VALUES
(1, 62000, 5200, '2024-01-01'),
(2, 73000, 6200, '2024-01-01'),
(3, 77000, 5700, '2024-01-01'),
(4, 67000, 3200, '2024-01-01'),
(5, 59000, 4200, '2024-01-01'),
(6, 64000, 5200, '2024-01-01'),
(7, 56000, 4700, '2024-01-01'),
(8, 62000, 5000, '2024-01-01'),
(9, 67000, 5500, '2024-01-01'),
(10, 74000, 7200, '2024-01-01'),
(11, 71000, 4800, '2024-01-01'),
(12, 65000, 4300, '2024-01-01'),
(13, 70000, 6400, '2024-01-01'),
(14, 62000, 5300, '2024-01-01'),
(15, 69000, 5400, '2024-01-01'),
(16, 61000, 4800, '2024-01-01'),
(17, 76000, 7000, '2024-01-01'),
(18, 82000, 7200, '2024-01-01'),
(19, 54000, 4000, '2024-01-01'),
(20, 60000, 4900, '2024-01-01');



-- 1. Find the employees who have the highest salary in each department.

SELECT e.department, e.employee_name, s.salary
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.salary = (
    SELECT MAX(salary)
    FROM salaries s2
    JOIN employees e2 ON s2.employee_id = e2.employee_id
    WHERE e2.department = e.department
);

-- 2. Calculate the total compensation (salary + bonus) for each employee in 2024.
SELECT e.employee_name, s.salary, s.bonus, (s.salary + s.bonus) AS total_compensation
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.salary_date = '2024-01-01';

-- 3. List the employees who earn more than the average salary of their department.

WITH department_avg AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees e
    JOIN salaries s ON e.employee_id = s.employee_id
    GROUP BY department
)
SELECT e.employee_name, e.department, s.salary
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
JOIN department_avg da ON e.department = da.department
WHERE s.salary > da.avg_salary;

-- 4. Identify the manager with the most employees.

SELECT m.manager_name, COUNT(e.employee_id) AS employee_count
FROM managers m
JOIN employees e ON m.manager_id = e.manager_id
GROUP BY m.manager_name
ORDER BY employee_count DESC
LIMIT 1;

-- 5. Find employees who have been working longer than their current manager.

SELECT e.employee_name, e.hire_date AS employee_hire_date, 
    m.manager_name, m.hire_date AS manager_hire_date
FROM employees e
JOIN managers m ON e.manager_id = m.manager_id
WHERE e.hire_date < m.hire_date;

-- 6. Get the department with the highest total salary expenditure for 2024.
SELECT e.department, SUM(s.salary) AS total_salary
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.salary_date = '2024-01-01'
GROUP BY e.department
ORDER BY total_salary DESC
LIMIT 1;

-- 7. Find employees whose salary has increased by more than 10% between 2023 and 2024.
WITH salary_diff AS (
    SELECT e.employee_id, e.employee_name, 
           (s2.salary - s1.salary) / s1.salary * 100 AS percent_increase
    FROM employees e
    JOIN salaries s1 ON e.employee_id = s1.employee_id AND s1.salary_date = '2023-01-01'
    JOIN salaries s2 ON e.employee_id = s2.employee_id AND s2.salary_date = '2024-01-01'
)
SELECT employee_name, percent_increase
FROM salary_diff
WHERE percent_increase > 10;

-- 8. List the top 3 highest-paid employees (including bonus) in each department for 2024.

WITH ranked_salaries AS (
    SELECT e.department, e.employee_name, s.salary + s.bonus AS total_compensation,
           RANK() OVER (PARTITION BY e.department ORDER BY s.salary + s.bonus DESC) AS rank
    FROM employees e
    JOIN salaries s ON e.employee_id = s.employee_id
    WHERE s.salary_date = '2024-01-01'
)
SELECT department, employee_name, total_compensation
FROM ranked_salaries
WHERE rank <= 3;


-- Queries Based on Case statement
SELECT 
    e.employee_name,
    s.salary,
    CASE 
        WHEN s.salary >= 75000 THEN 'High Salary'
        WHEN s.salary BETWEEN 60000 AND 74999 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.salary_date = '2024-01-01';


-- Dynamic Bonus Calculation Based on Salary Levels
SELECT 
    e.employee_name,
    s.salary,
    CASE 
        WHEN s.salary >= 75000 THEN s.salary * 0.05
        WHEN s.salary BETWEEN 60000 AND 74999 THEN s.salary * 0.08
        ELSE s.salary * 0.10
    END AS dynamic_bonus
FROM employees e
JOIN salaries s ON e.employee_id = s.employee_id
WHERE s.salary_date = '2024-01-01';





--::::::::::::::::::::::::: LIST OF FUNCTIONS ::::::::::::::::::::::::::::::::::::::::::::::::::::

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::: STRING BASED :::::::::::::::::::::::::::::::::::::::::::::

-- 1. Concatenation Operator: ||
SELECT 'Hello' || ' ' || 'World' AS concatenated_string;  -- Output: 'Hello World'

-- 2. SPLIT_PART: Splitting Full Name into First Name and Last Name
SELECT SPLIT_PART('John Doe', ' ', 1) AS first_name, SPLIT_PART('John Doe', ' ', 2) AS last_name;

-- 3. LIKE: Find Strings Matching Patterns
SELECT 'John' LIKE 'J%' AS starts_with_J;  -- Output: TRUE

-- 4. UPPER: Convert to Uppercase
SELECT UPPER('hello') AS uppercase_string;  -- Output: 'HELLO'

-- 5. LOWER: Convert to Lowercase
SELECT LOWER('HELLO') AS lowercase_string;  -- Output: 'hello'

-- 6. LENGTH: Get Length of a String
SELECT LENGTH('John') AS string_length;  -- Output: 4

-- 7. TRIM: Remove Leading and Trailing Spaces
SELECT TRIM('  John  ') AS trimmed_string;  -- Output: 'John'

-- 8. REPLACE: Replace Substring
SELECT REPLACE('John Doe', ' ', '-') AS replaced_string;  -- Output: 'John-Doe'

-- 9. LPAD: Pad a String from Left
SELECT LPAD('John', 6, '0') AS left_padded_string;  -- Output: '00John'

-- 10. LEFT: Extract Left Characters
SELECT LEFT('John Doe', 4) AS left_part;  -- Output: 'John'

-- 11. RIGHT: Extract Right Characters
SELECT RIGHT('John Doe', 3) AS right_part;  -- Output: 'Doe'

-- 12. REVERSE: Reverse a String
SELECT REVERSE('John') AS reversed_string;  -- Output: 'nhoJ'

-- 13. REGEXP_LIKE: Match a Regular Expression
SELECT REGEXP_LIKE('John123', '[0-9]') AS contains_digit;  -- Output: TRUE

-- 14. SUBSTRING: Extract Substring
SELECT SUBSTRING('John Doe', 1, 4) AS substring_part;  -- Output: 'John'

-- 15. INITCAP: Capitalize First Letter of Each Word
SELECT INITCAP('john doe') AS capitalized_string;  -- Output: 'John Doe'

-- 16. POSITION: Find Position of Substring
SELECT POSITION('Doe' IN 'John Doe') AS position_of_substring;  -- Output: 6

-- 17. RLIKE (or REGEXP): Regular Expression Matching
SELECT 'abc123' RLIKE '[a-z]+[0-9]+' AS regex_match;  -- Output: TRUE

-- 18. CONCAT: Concatenate Strings
SELECT CONCAT('John', ' ', 'Doe') AS concatenated_string;  -- Output: 'John Doe'

-- 19. RTRIM: Remove Trailing Spaces
SELECT RTRIM('John    ') AS right_trimmed_string;  -- Output: 'John'

-- 20. CHARINDEX: Find Position of Substring (SQL Server style)
SELECT CHARINDEX('Doe', 'John Doe') AS charindex_position;  -- Output: 6

-- 21. INSTR: Find Position of Substring (MySQL/Oracle style)
SELECT INSTR('John Doe', 'Doe') AS instr_position;  -- Output: 6

-- 22. RPAD: Pad a String from Right
SELECT RPAD('John', 6, '0') AS right_padded_string;  -- Output: 'John00'

-- 23. TRANSLATE: Replace Characters
SELECT TRANSLATE('1234', '1234', 'abcd') AS translated_string;  -- Output: 'abcd'


-- ::::::::::::::::::::::::::::::::::::::::: DATE RELATED/ TIMESTAMP :::::::::::::::::::::::::::::::::::::::::::::::::::::::

-- 1. CURRENT_DATE: Get Current Date
SELECT CURRENT_DATE AS current_date;  -- Output: Today's date (e.g., '2024-09-25')

-- 2. CURRENT_TIMESTAMP: Get Current Timestamp
SELECT CURRENT_TIMESTAMP AS current_timestamp;  -- Output: Current date and time (e.g., '2024-09-25 12:34:56')

-- 3. EXTRACT: Extract Year, Month, Day from Date
SELECT 
    EXTRACT(YEAR FROM CURRENT_DATE) AS current_year,   -- Output: Current year (e.g., 2024)
    EXTRACT(MONTH FROM CURRENT_DATE) AS current_month, -- Output: Current month (e.g., 9)
    EXTRACT(DAY FROM CURRENT_DATE) AS current_day;     -- Output: Current day (e.g., 25)

-- 4. DATE_PART: Get Specific Part of a Date or Timestamp (Similar to EXTRACT)
SELECT 
    DATE_PART('year', CURRENT_DATE) AS year_part,      -- Output: 2024
    DATE_PART('month', CURRENT_DATE) AS month_part;    -- Output: 9

-- 5. AGE: Calculate the Age Between Two Dates (PostgreSQL example)
SELECT AGE('1990-01-01', CURRENT_DATE) AS age_difference;  -- Output: '34 years 8 months' (Age)

-- 6. DATEDIFF: Get the Difference Between Two Dates in Days
SELECT DATEDIFF(DAY, '2024-01-01', '2024-09-25') AS days_diff;  -- Output: 268 days difference

-- 7. DATEADD: Add or Subtract Days, Months, Years to/from a Date
SELECT 
    DATEADD(DAY, 7, CURRENT_DATE) AS date_plus_7_days,        -- Add 7 days
    DATEADD(MONTH, -1, CURRENT_DATE) AS date_minus_1_month;   -- Subtract 1 month

-- 8. DATE_TRUNC: Truncate Date to the Start of Year, Month, or Day
SELECT 
    DATE_TRUNC('year', CURRENT_DATE) AS start_of_year,    -- Output: '2024-01-01'
    DATE_TRUNC('month', CURRENT_DATE) AS start_of_month,  -- Output: '2024-09-01'
    DATE_TRUNC('day', CURRENT_DATE) AS start_of_day;      -- Output: '2024-09-25'

-- 9. TO_DATE: Convert String to Date (Use format)
SELECT TO_DATE('2024-09-25', 'YYYY-MM-DD') AS converted_date;  -- Output: Date format

-- 10. TO_TIMESTAMP: Convert String to Timestamp
SELECT TO_TIMESTAMP('2024-09-25 12:34:56', 'YYYY-MM-DD HH24:MI:SS') AS converted_timestamp;  -- Output: Timestamp format

-- 11. FORMAT_DATE: Format a Date to a Specific Pattern (PostgreSQL example)
SELECT TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD') AS formatted_date;  -- Output: '2024-09-25'

-- 12. LAST_DAY: Get Last Day of the Month
SELECT LAST_DAY(CURRENT_DATE) AS last_day_of_month;  -- Output: '2024-09-30'

-- 13. NEXT_DAY: Get the Date of the Next Specified Day of the Week
SELECT NEXT_DAY(CURRENT_DATE, 'Monday') AS next_monday;  -- Output: Next Monday's date (e.g., '2024-09-30')

-- 14. ADD_MONTHS: Add a Specific Number of Months to a Date
SELECT ADD_MONTHS(CURRENT_DATE, 6) AS date_after_6_months;  -- Output: Date 6 months from today

-- 15. TIMESTAMPDIFF: Difference Between Two Timestamps
SELECT TIMESTAMPDIFF(HOUR, '2024-09-25 08:00:00', '2024-09-25 14:00:00') AS hours_diff;  -- Output: 6 hours

-- 16. TIMESTAMPADD: Add an Interval to a Timestamp
SELECT TIMESTAMPADD(HOUR, 3, CURRENT_TIMESTAMP) AS timestamp_plus_3_hours;  -- Output: Timestamp 3 hours later

-- 17. YEAR: Extract Year from a Date or Timestamp
SELECT YEAR(CURRENT_DATE) AS year_value;  -- Output: 2024

-- 18. MONTH: Extract Month from a Date or Timestamp
SELECT MONTH(CURRENT_DATE) AS month_value;  -- Output: 9

-- 19. DAY: Extract Day of the Month from a Date
SELECT DAY(CURRENT_DATE) AS day_value;  -- Output: 25

-- 20. IS_DATE: Check if a String is a Valid Date (Snowflake example)
SELECT IS_DATE('2024-09-25') AS valid_date_check;  -- Output: TRUE if valid, FALSE if invalid


-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;

-- ::::::::::::::: WINDOWS FUNCTIONS :::::::::::::::::::
-- Sample Table Creation for Demonstration
CREATE OR REPLACE TABLE employee_data (
    employee_id INT,
    department_id INT,
    salary DECIMAL(10, 2),
    hire_date DATE
);

-- Sample Data Insertion
INSERT INTO employee_data (employee_id, department_id, salary, hire_date) VALUES
(1, 1, 60000.00, '2020-01-15'),
(2, 1, 80000.00, '2019-03-22'),
(3, 2, 75000.00, '2021-06-30'),
(4, 2, 65000.00, '2020-08-18'),
(5, 1, 90000.00, '2021-05-21'),
(6, 3, 70000.00, '2023-07-11'),
(7, 3, 72000.00, '2022-04-15'),
(8, 2, 71000.00, '2021-02-20'),
(9, 1, 85000.00, '2023-01-10'),
(10, 3, 64000.00, '2022-11-30');

-- 1. ROW_NUMBER: Assign a Unique Sequential Integer to Rows
SELECT 
    employee_id,
    department_id,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employee_data;

-- 2. RANK: Assign Ranks to Rows with Gaps
SELECT 
    employee_id,
    department_id,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employee_data;

-- 3. DENSE_RANK: Assign Ranks without Gaps
SELECT 
    employee_id,
    department_id,
    salary,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dense_salary_rank
FROM employee_data;

-- 4. NTILE: Distribute Rows into a Specified Number of Groups
SELECT 
    employee_id,
    department_id,
    salary,
    NTILE(3) OVER (ORDER BY salary) AS salary_quartile
FROM employee_data;

-- 5. SUM: Calculate Running Total of Salaries
SELECT 
    employee_id,
    department_id,
    salary,
    SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_date) AS running_total
FROM employee_data;

-- 6. AVG: Calculate Average Salary in Each Department
SELECT 
    department_id,
    employee_id,
    salary,
    AVG(salary) OVER (PARTITION BY department_id) AS avg_department_salary
FROM employee_data;

-- 7. MIN and MAX: Get Min and Max Salary in Each Department
SELECT 
    department_id,
    employee_id,
    salary,
    MIN(salary) OVER (PARTITION BY department_id) AS min_salary,
    MAX(salary) OVER (PARTITION BY department_id) AS max_salary
FROM employee_data;

-- 8. LEAD: Access Data from the Next Row
SELECT 
    employee_id,
    department_id,
    salary,
    LEAD(salary, 1) OVER (ORDER BY hire_date) AS next_salary
FROM employee_data;

-- 9. LAG: Access Data from the Previous Row
SELECT 
    employee_id,
    department_id,
    salary,
    LAG(salary, 1) OVER (ORDER BY hire_date) AS previous_salary
FROM employee_data;

-- 10. FIRST_VALUE: Get the First Value in the Ordered Partition
SELECT 
    employee_id,
    department_id,
    salary,
    FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_date) AS first_hired_salary
FROM employee_data;

-- 11. LAST_VALUE: Get the Last Value in the Ordered Partition
SELECT 
    employee_id,
    department_id,
    salary,
    LAST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY hire_date 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_hired_salary
FROM employee_data;

-- 12. CUME_DIST: Cumulative Distribution of Salaries
SELECT 
    employee_id,
    department_id,
    salary,
    CUME_DIST() OVER (PARTITION BY department_id ORDER BY salary) AS salary_cume_dist
FROM employee_data;

-- 13. PERCENT_RANK: Calculate the Percent Rank of Salaries
SELECT 
    employee_id,
    department_id,
    salary,
    PERCENT_RANK() OVER (PARTITION BY department_id ORDER BY salary) AS salary_percent_rank
FROM employee_data;

-- 14. COUNT: Count Rows in Each Department
SELECT 
    department_id,
    employee_id,
    salary,
    COUNT(*) OVER (PARTITION BY department_id) AS department_count
FROM employee_data;


-- ::::::::::::::::::: MERGE QUERY :::::::::::::::::::::::::::::::::::::::::::::::::::

-- Creating the target table
CREATE OR REPLACE TABLE target_employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- Inserting sample data into target_employee
INSERT INTO target_employee (employee_id, name, department, salary) VALUES
(1, 'Alice', 'HR', 60000.00),
(2, 'Bob', 'IT', 70000.00),
(3, 'Charlie', 'Finance', 80000.00);

-- Creating the source table
CREATE OR REPLACE TABLE source_employee (
    employee_id INT,
    name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- Inserting sample data into source_employee
INSERT INTO source_employee (employee_id, name, department, salary) VALUES
(2, 'Bob', 'IT', 75000.00),    -- Update
(3, 'Charlie', 'Finance', 80000.00),  -- No change
(4, 'David', 'Marketing', 60000.00);   -- New record

-- Performing the MERGE operation
MERGE INTO target_employee AS target
USING source_employee AS source
ON target.employee_id = source.employee_id
WHEN MATCHED THEN
    UPDATE SET 
        target.name = source.name,
        target.department = source.department,
        target.salary = source.salary
WHEN NOT MATCHED THEN
    INSERT (employee_id, name, department, salary)
    VALUES (source.employee_id, source.name, source.department, source.salary);


-- :::::::::::::::::::::::::::: LEAD-LAG :::::::::::::::::::::::::::::::::::::::

-- Creating the employee_data table
CREATE OR REPLACE TABLE employee_data (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    hire_date DATE,
    salary DECIMAL(10, 2)
);

-- Inserting sample data into employee_data
INSERT INTO employee_data (employee_id, name, hire_date, salary) VALUES
(1, 'Alice', '2021-01-15', 60000.00),
(2, 'Bob', '2020-03-22', 70000.00),
(3, 'Charlie', '2022-06-30', 75000.00),
(4, 'David', '2021-08-18', 65000.00),
(5, 'Eva', '2023-05-21', 90000.00),
(6, 'Frank', '2022-01-11', 72000.00),
(7, 'Grace', '2021-02-15', 67000.00),
(8, 'Hannah', '2020-11-20', 71000.00),
(9, 'Ivy', '2023-01-10', 85000.00),
(10, 'Jack', '2022-03-30', 64000.00);


SELECT 
    employee_id,
    name,
    hire_date,
    salary,
    LAG(salary, 1) OVER (ORDER BY hire_date) AS previous_salary,
    LEAD(salary, 1) OVER (ORDER BY hire_date) AS next_salary,
    (salary - LAG(salary, 1) OVER (ORDER BY hire_date)) AS salary_change_from_previous,
    (LEAD(salary, 1) OVER (ORDER BY hire_date) - salary) AS salary_change_to_next
FROM 
    employee_data
ORDER BY 
    hire_date;

-- :::::::::::::::::::::::::::::::::::::::: COALESCE ::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- 1. COALESCE with two columns
SELECT COALESCE(column1, column2) AS result1 FROM table_name; -- Returns the first non-null value between column1 and column2.

-- 2. COALESCE with multiple columns
SELECT COALESCE(column1, column2, column3) AS result2 FROM table_name; -- Returns the first non-null value among column1, column2, and column3.

-- 3. COALESCE with literal values
SELECT COALESCE(NULL, NULL, 'Default Value') AS result3; -- Returns 'Default Value' since all other values are NULL.

-- 4. COALESCE with a subquery
SELECT COALESCE((SELECT MAX(salary) FROM employee_data WHERE department_id = 1), 0) AS max_salary; -- Returns max salary or 0 if no records exist.

-- 5. COALESCE with aggregate function
SELECT COALESCE(SUM(salary), 0) AS total_salary FROM employee_data; -- Returns the total salary or 0 if there are no records.

-- 6. COALESCE for replacing NULL in joins
SELECT COALESCE(e.name, 'Unknown') AS employee_name, d.department_name FROM employee_data e LEFT JOIN department_data d ON e.department_id = d.id; -- Replaces NULL employee names with 'Unknown'.

-- 7. COALESCE in a CASE statement
SELECT CASE WHEN COALESCE(salary, 0) > 50000 THEN 'High' ELSE 'Low' END AS salary_category FROM employee_data; -- Categorizes salary based on whether it's greater than 50,000.

-- 8. COALESCE in a string concatenation
SELECT CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, 'Unknown')) AS full_name FROM employee_data; -- Concatenates first and last name, replacing NULL with 'Unknown' or empty string.


-- :::::::::::::::::::::::: TYPE CONVERSIONS ::::::::::::::::::::::::::::::::::::::::
-- 1. CAST to convert data types
SELECT CAST(column_name AS VARCHAR(100)) AS converted_value FROM table_name; -- Converts column_name to VARCHAR.

-- 2. CONVERT to convert data types
SELECT CONVERT(INT, column_name) AS converted_value FROM table_name; -- Converts column_name to INT.

-- 3. CAST for date conversion
SELECT CAST('2023-01-01' AS DATE) AS converted_date; -- Converts string to DATE type.

-- 4. CONVERT for date formatting
SELECT CONVERT(VARCHAR, GETDATE(), 101) AS formatted_date; -- Converts current date to formatted string (MM/DD/YYYY).

-- 5. TRY_CAST to safely convert data types
SELECT TRY_CAST(column_name AS INT) AS safe_conversion FROM table_name; -- Attempts to convert column_name to INT; returns NULL if fails.

-- 6. TRY_CONVERT for safe conversion
SELECT TRY_CONVERT(DATE, '2023-01-01') AS safe_converted_date; -- Safely converts string to DATE; returns NULL if fails.

-- 7. CAST with arithmetic operations
SELECT CAST(salary AS DECIMAL(10, 2)) * 1.1 AS increased_salary FROM employee_data; -- Converts salary to DECIMAL before multiplication.

-- 8. CONVERT for changing time format
SELECT CONVERT(VARCHAR, GETDATE(), 108) AS current_time; -- Converts current time to string format (HH:MM:SS).




-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-- Remove duplicate records
-- Assuming we have a table called employee_data with duplicate entries
WITH CTE AS (
    SELECT 
        employee_id,
        name,
        department,
        salary, -- here salary can change
        ROW_NUMBER() OVER (PARTITION BY name, department ORDER BY employee_id) AS row_num
    FROM employee_data
)
DELETE FROM CTE WHERE row_num > 1; -- Deletes duplicate rows, keeping the first occurrence

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-- JOINS CONCEPTS:
table1: ID:: 1,1,1,2,null,3,3
table2: ID:: 1,1,null, 4,4
;

-- RESULT:
-- 1] FOR INNER JOIN OUTPUT : 6 Records
-- Null cannot get joined on another Null
ID	ID2
1	1
1	1
1	1
1	1
1	1
1	1

-- 2] For Left Join: 10 Records

ID	    ID2
1	    1
1	    1
1	    1
1	    1
1	    1
1	    1
2	    null
null	null
3	    null
3	    null

-- 3] For Right Join:: 9 Records
ID	    ID2
1	    1
1	    1
1	    1
1	    1
1	    1
1	    1
null	null
null	4
null	4

-- Full Outer Join:: 13
ID	    ID2
null	null
1	    1
1	    1
1	    1
1	    1
1	    1
1	    1
2	    null
null	null
3	    null
3	    null
null	4
null	4

SHOW DATABASES;

USE DATABASE DBT_LABS;
SHOW SCHEMAS;
USE SCHEMA RAW;

CREATE TABLE TABLE1 (ID INT);
CREATE OR REPLACE TABLE TABLE2 (ID2 INT);

INSERT INTO TABLE1(ID) 
VALUES
(1),(1),(1),(2),(null),(3),(3);

INSERT INTO TABLE2 (ID2)
VALUES
(1),(1),(null),(4),(4);

SELECT * FROM TABLE1;

SELECT * FROM TABLE2;

SELECT TABLE1.ID, TABLE2.ID2 FROM TABLE1 INNER JOIN TABLE2 ON TABLE1.ID = TABLE2.ID2;
SELECT TABLE1.ID, TABLE2.ID2 FROM TABLE1 LEFT JOIN TABLE2 ON TABLE1.ID = TABLE2.ID2;
SELECT TABLE1.ID, TABLE2.ID2 FROM TABLE1 RIGHT JOIN TABLE2 ON TABLE1.ID = TABLE2.ID2;
SELECT TABLE1.ID, TABLE2.ID2 FROM TABLE1 FULL OUTER JOIN TABLE2 ON TABLE1.ID = TABLE2.ID2;



