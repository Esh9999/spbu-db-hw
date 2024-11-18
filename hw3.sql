CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL
);
INSERT INTO sales (product_id, employee_id, sale_date, quantity) VALUES
(1, 101, '2024-11-15', 5),
(2, 102, '2024-11-14', 12),
(3, 103, '2024-11-13', 8),
(1, 101, '2024-11-10', 7),
(2, 104, '2024-11-09', 15),
(3, 102, '2024-10-25', 20);
CREATE TEMP TABLE high_sales_products AS
SELECT 
    product_id,
    SUM(quantity) AS total_quantity
FROM sales
WHERE sale_date >= NOW() - INTERVAL '7 days'
GROUP BY product_id
HAVING SUM(quantity) > 10;

-- Вывод данных
SELECT * FROM high_sales_products;
WITH employee_sales_stats AS (
    SELECT 
        employee_id,
        COUNT(*) AS total_sales,
        AVG(quantity) AS avg_sales
    FROM sales
    WHERE sale_date >= NOW() - INTERVAL '30 days'
    GROUP BY employee_id
),
company_avg_sales AS (
    SELECT AVG(total_sales) AS company_avg FROM employee_sales_stats
)
SELECT 
    ess.employee_id, 
    ess.total_sales, 
    ess.avg_sales
FROM employee_sales_stats ess
JOIN company_avg_sales cas ON ess.total_sales > cas.company_avg;
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY, -- Уникальный ID сотрудника
    employee_name VARCHAR(100) NOT NULL, -- Имя сотрудника
    manager_id INT, -- ID менеджера, которому подчиняется сотрудник
    position VARCHAR(50) -- Должность
);
INSERT INTO employees (employee_name, manager_id, position) VALUES
('Alice', NULL, 'CEO'), -- Генеральный директор (без менеджера)
('Bob', 1, 'Head of Sales'), -- Руководитель отдела продаж (подчиняется Alice)
('Charlie', 2, 'Sales Representative'), -- Продавец (подчиняется Bob)
('Diana', 1, 'Head of Engineering'), -- Руководитель отдела разработки (подчиняется Alice)
('Eve', 4, 'Software Engineer'), -- Инженер (подчиняется Diana)
('Frank', 4, 'Software Engineer'); -- Еще один инженер (подчиняется Diana)
WITH RECURSIVE employee_hierarchy AS (
    SELECT 
        employee_id, 
        manager_id, 
        1 AS hierarchy_level
    FROM employees
    WHERE manager_id = 1 -- Укажите ID менеджера

    UNION ALL

    SELECT 
        e.employee_id, 
        e.manager_id, 
        eh.hierarchy_level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy;
WITH monthly_sales AS (
    SELECT 
        product_id,
        DATE_TRUNC('month', sale_date) AS sale_month,
        SUM(quantity) AS total_quantity
    FROM sales
    GROUP BY product_id, DATE_TRUNC('month', sale_date)
),
ranked_products AS (
    SELECT 
        product_id,
        sale_month,
        total_quantity,
        RANK() OVER (PARTITION BY sale_month ORDER BY total_quantity DESC) AS rank
    FROM monthly_sales
)
SELECT 
    product_id,
    sale_month,
    total_quantity
FROM ranked_products
WHERE rank <= 3
ORDER BY sale_month, rank;
-- Создание индекса
CREATE INDEX idx_sales_employee_date ON sales (employee_id, sale_date);

-- Запрос для анализа производительности
EXPLAIN ANALYZE
SELECT 
    employee_id, 
    COUNT(*) AS total_sales
FROM sales
WHERE sale_date >= NOW() - INTERVAL '30 days'
GROUP BY employee_id;
-- Анализ с использованием EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT 
    product_id,
    SUM(quantity) AS total_units_sold
FROM sales
GROUP BY product_id;
