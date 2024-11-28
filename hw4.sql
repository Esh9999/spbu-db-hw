-- Создаем таблицу для работы с триггерами
CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    operation_type TEXT,
    table_name TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создаем основную таблицу
CREATE TABLE employees1 (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    position TEXT,
    salary NUMERIC
);

-- Функция, вызываемая триггером
CREATE OR REPLACE FUNCTION log_operations()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (operation_type, table_name)
    VALUES (TG_OP, TG_TABLE_NAME);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер для всех операций
CREATE TRIGGER employees_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_operations();
-- Функция для логирования на уровне оператора
CREATE OR REPLACE FUNCTION log_truncate()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (operation_type, table_name)
    VALUES ('TRUNCATE', TG_TABLE_NAME);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер на операцию TRUNCATE
CREATE TRIGGER employees_truncate_log_trigger
AFTER TRUNCATE ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION log_truncate();
BEGIN;

INSERT INTO employees1 (name, position, salary)
VALUES ('Alice', 'Manager', 75000);

UPDATE employees1
SET salary = salary + 5000
WHERE name = 'Alice';

COMMIT;
BEGIN;

INSERT INTO employees1 (name, position, salary)
VALUES ('Bob', 'Developer', 60000);

-- Ошибка: нарушение уникального ограничения PRIMARY KEY
INSERT INTO employees1 (id, name, position, salary)
VALUES (1, 'Charlie', 'Analyst', 50000);

COMMIT;

-- Функция с RAISE
CREATE OR REPLACE FUNCTION log_operations_with_debug()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Operation: % on table: %', TG_OP, TG_TABLE_NAME;

    -- Логируем операцию
    INSERT INTO logs (operation_type, table_name)
    VALUES (TG_OP, TG_TABLE_NAME);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Переписываем триггер для использования новой функции
DROP TRIGGER IF EXISTS employees_log_trigger ON employees;

CREATE TRIGGER employees_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_operations_with_debug();
