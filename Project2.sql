BEGIN;

-- Создаем временную таблицу, содержащую данные об активных бронированиях.
-- Временные таблицы используются для временного хранения данных в рамках сессии.
CREATE TEMP TABLE temp_active_bookings AS
SELECT 
    b.booking_id, -- Идентификатор бронирования
    u.name AS user_name, -- Имя пользователя, который сделал бронирование
    c.model AS car_model, -- Модель автомобиля
    b.start_time, -- Время начала бронирования
    b.end_time -- Время завершения бронирования
FROM bookings b
JOIN users u ON b.user_id = u.user_id -- Присоединяем данные пользователя
JOIN cars c ON b.car_id = c.car_id -- Присоединяем данные об автомобиле
WHERE b.status = 'active'; -- Учитываем только активные бронирования

-- Проверяем данные из временной таблицы
SELECT * FROM temp_active_bookings;

COMMIT;
BEGIN;

-- Создаем временную таблицу для хранения данных о платежах, выполненных за последние 30 дней
CREATE TEMP TABLE temp_recent_payments AS
SELECT 
    p.payment_id, -- Идентификатор платежа
    p.booking_id, -- Идентификатор бронирования
    b.start_time, -- Время начала бронирования
    b.end_time, -- Время завершения бронирования
    p.amount, -- Сумма платежа
    p.paid_at -- Дата и время платежа
FROM payments p
JOIN bookings b ON p.booking_id = b.booking_id -- Присоединяем данные о бронировании
WHERE p.paid_at >= CURRENT_DATE - INTERVAL '30 days'; -- Фильтруем данные за последние 30 дней

-- Проверяем данные из временной таблицы
SELECT * FROM temp_recent_payments;

COMMIT;

-- Создаем представление для отображения всех доступных автомобилей
CREATE OR REPLACE VIEW view_available_cars AS
SELECT 
    car_id, -- Идентификатор автомобиля
    model, -- Модель автомобиля
    license_plate -- Номерной знак автомобиля
FROM cars
WHERE is_available = TRUE; -- Учитываем только доступные автомобили

-- Получаем список доступных автомобилей
SELECT * FROM view_available_cars;

-- Создаем представление для подсчета количества бронирований по статусу
-- и расчета средней продолжительности бронирований (в часах)
CREATE OR REPLACE VIEW view_booking_statistics AS
SELECT 
    status, -- Статус бронирования (active, completed, cancelled)
    COUNT(*) AS total_bookings, -- Общее количество бронирований для каждого статуса
    AVG(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600) AS avg_duration_hours -- Средняя продолжительность бронирования в часах
FROM bookings
GROUP BY status; -- Группируем по статусу бронирования

-- Получаем статистику бронирований
SELECT * FROM view_booking_statistics;

-- Создаем представление для анализа доходов за последние 30 дней
CREATE OR REPLACE VIEW view_monthly_revenue AS
SELECT 
    SUM(amount) AS total_revenue, -- Общая сумма платежей
    COUNT(payment_id) AS total_payments, -- Количество платежей
    DATE_TRUNC('month', paid_at) AS month -- Группировка по месяцам
FROM payments
WHERE paid_at >= CURRENT_DATE - INTERVAL '30 days' -- Учитываем только последние 30 дней
GROUP BY DATE_TRUNC('month', paid_at); -- Группируем данные по месяцам

-- Получаем данные о доходах
SELECT * FROM view_monthly_revenue;


SELECT 
    -- Вычисляем среднюю продолжительность активных бронирований в часах
    AVG(EXTRACT(EPOCH FROM (end_time - start_time))  / 3600 ) AS avg_active_duration_hours
FROM temp_active_bookings; -- Используем временную таблицу с активными бронированиями


SELECT 
    model, -- Модель автомобиля
    COUNT(car_id) AS total_available -- Количество доступных автомобилей данной модели
FROM view_available_cars -- Используем представление для доступных автомобилей
GROUP BY model; -- Группируем данные по модели автомобиля

-- Запрос для анализа доходов по месяцам за последние 30 дней
-- Используется представление view_monthly_revenue, которое группирует платежи по месяцам.

SELECT 
    month, -- Месяц, в котором были совершены платежи
    total_revenue, -- Общая сумма платежей за месяц
    total_payments -- Общее количество платежей за месяц
FROM view_monthly_revenue; -- Используем представление для месячного анализа доходов
