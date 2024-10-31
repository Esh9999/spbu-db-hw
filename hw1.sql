CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    is_exam BOOLEAN,
    min_grade INT,
    max_grade INT
);
CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    short_name VARCHAR(20),
    students_ids INT[]
);
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    group_id INT REFERENCES groups(id),
    courses_ids INT[]
);
CREATE TABLE course_grades (
    student_id INT REFERENCES students(id),
    course_id INT REFERENCES courses(id),
    grade INT,
    grade_str VARCHAR(20)
);

-- Вставка данных в таблицу courses
INSERT INTO courses (name, is_exam, min_grade, max_grade) VALUES
('Mathematics', TRUE, 0, 100),
('History', FALSE, 0, 100),
('Biology', TRUE, 0, 100);

-- Вставка данных в таблицу groups
INSERT INTO groups (full_name, short_name, students_ids) VALUES
('Mathematics Group', 'MathGrp', ARRAY[1, 2, 3]),
('History Group', 'HistGrp', ARRAY[4, 5]);

-- Вставка данных в таблицу students
INSERT INTO students (first_name, last_name, group_id, courses_ids) VALUES
('Alice', 'Johnson', 1, ARRAY[1, 2]),
('Bob', 'Smith', 1, ARRAY[1, 3]),
('Charlie', 'Brown', 2, ARRAY[2]);

-- Вставка данных в таблицу course_grades
INSERT INTO course_grades (student_id, course_id, grade, grade_str) VALUES
(1, 1, 95, 'отлично'),
(2, 1, 80, 'хорошо'),
(3, 2, 70, 'удовлетворительно');

SELECT s.first_name, s.last_name, cg.grade
FROM students s
JOIN course_grades cg ON s.id = cg.student_id
JOIN courses c ON cg.course_id = c.id
WHERE c.name = 'Mathematics' AND cg.grade > 80;
SELECT c.name, COUNT(cg.student_id) AS students_passed
FROM courses c
JOIN course_grades cg ON c.id = cg.course_id
WHERE c.is_exam = TRUE AND cg.grade >= c.min_grade
GROUP BY c.name;
SELECT g.full_name AS group_name, s.first_name, s.last_name, c.name AS course_name, cg.grade
FROM groups g
JOIN students s ON g.id = s.group_id
JOIN course_grades cg ON s.id = cg.student_id
JOIN courses c ON cg.course_id = c.id
WHERE g.full_name = 'Mathematics Group';
