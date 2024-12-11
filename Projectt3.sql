BEGIN;

-- Создаем новое бронирование
INSERT INTO bookings (user_id, car_id, start_time, end_time, status)
VALUES (2, 1, '2024-12-05 10:00:00', '2024-12-05 14:00:00', 'active');

-- Обновляем статус автомобиля
UPDATE cars SET is_available = FALSE WHERE car_id = 1;

COMMIT;

BEGIN;

-- Обновляем статус бронирования
UPDATE bookings 
SET status = 'completed' 
WHERE booking_id = 1;

-- Делаем автомобиль доступным
UPDATE cars 
SET is_available = TRUE 
WHERE car_id = (SELECT car_id FROM bookings WHERE booking_id = 1);

COMMIT;

BEGIN;

-- Отменяем бронирование
UPDATE bookings 
SET status = 'cancelled' 
WHERE booking_id = 2;

-- Освобождаем автомобиль
UPDATE cars 
SET is_available = TRUE 
WHERE car_id = (SELECT car_id FROM bookings WHERE booking_id = 2);

COMMIT;


BEGIN;

-- Проверяем доступность автомобиля
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cars WHERE car_id = 3 AND is_available = TRUE) THEN
        RAISE EXCEPTION 'Автомобиль недоступен для бронирования.';
    END IF;
END;
$$;

-- Создаем новое бронирование
INSERT INTO bookings (user_id, car_id, start_time, end_time, status)
VALUES (3, 3, '2024-12-06 08:00:00', '2024-12-06 12:00:00', 'active');

-- Обновляем статус автомобиля
UPDATE cars 
SET is_available = FALSE 
WHERE car_id = 3;

COMMIT;

BEGIN;

-- Завершаем бронирование
UPDATE bookings 
SET status = 'completed' 
WHERE booking_id = 3;

-- Создаем запись о платеже
INSERT INTO payments (booking_id, amount, paid_at)
VALUES (3, 2000.00, CURRENT_TIMESTAMP);

-- Освобождаем автомобиль
UPDATE cars 
SET is_available = TRUE 
WHERE car_id = (SELECT car_id FROM bookings WHERE booking_id = 3);

COMMIT;

--Тригеры

--Триггер для автоматической проверки времени бронирования
CREATE OR REPLACE FUNCTION validate_booking_time() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.end_time <= NEW.start_time THEN
        RAISE EXCEPTION 'Время окончания бронирования должно быть позже времени начала.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_booking_time
BEFORE INSERT OR UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION validate_booking_time();

--Триггер для автоматического добавления даты создания
CREATE OR REPLACE FUNCTION set_created_at() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_at IS NULL THEN
        NEW.created_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_created_at
BEFORE INSERT ON bookings
FOR EACH ROW
EXECUTE FUNCTION set_created_at();

--Триггер для автоматического удаления связанных платежей
CREATE OR REPLACE FUNCTION delete_related_payments() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM payments WHERE booking_id = OLD.booking_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_delete_related_payments
AFTER DELETE ON bookings
FOR EACH ROW
EXECUTE FUNCTION delete_related_payments();
