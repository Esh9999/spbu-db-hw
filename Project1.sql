-- Таблица пользователей
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица автомобилей
CREATE TABLE cars (
    car_id SERIAL PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    license_plate VARCHAR(15) UNIQUE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

-- Таблица бронирований
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    car_id INT REFERENCES cars(car_id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(20) CHECK (status IN ('active', 'completed', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица платежей
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Список всех доступных машин
SELECT * FROM cars WHERE is_available = TRUE;

-- Общее количество бронирований по каждому статусу
SELECT status, COUNT(*) AS count 
FROM bookings 
GROUP BY status;

-- Средняя стоимость платежей за бронирования
SELECT AVG(amount) AS average_payment 
FROM payments;


-- Средняя стоимость платежей за бронирования
SELECT u.user_id, u.name, COUNT(b.booking_id) AS booking_count
FROM users u
JOIN bookings b ON u.user_id = b.user_id
GROUP BY u.user_id, u.name
HAVING COUNT(b.booking_id) > 1;
