CREATE TABLE student_courses (
    id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(id),
    course_id INT REFERENCES courses(id),
    UNIQUE(student_id, course_id)  -- Уникальность сочетания student_id и course_id
);
	CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INT REFERENCES groups(id),
    course_id INT REFERENCES courses(id),
    UNIQUE(group_id, course_id)  -- Уникальность сочетания group_id и course_id
);
-- Заполнение таблицы student_courses
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1),  -- Alice записана на курс Mathematics
(1, 2),  -- Alice записана на курс History
(2, 1),  -- Bob записан на курс Mathematics
(2, 3),  -- Bob записан на курс Biology
(3, 2);  -- Charlie записан на курс History

-- Заполнение таблицы group_courses
INSERT INTO group_courses (group_id, course_id) VALUES
(1, 1),  -- Группа 1 (Mathematics Group) на курс Mathematics
(1, 2),  -- Группа 1 на курс History
(2, 2);  -- Группа 2 (History Group) на курс History
-- Удаление поля courses_ids из таблицы students
ALTER TABLE students DROP COLUMN courses_ids;

-- Удаление поля students_ids из таблицы groups
ALTER TABLE groups DROP COLUMN students_ids;
-- Удаление поля courses_ids из таблицы students
ALTER TABLE students DROP COLUMN courses_ids;

-- Удаление поля students_ids из таблицы groups
ALTER TABLE groups DROP COLUMN students_ids;
SELECT s.first_name, s.last_name, c.name AS course_name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id;
SELECT c.name, COUNT(DISTINCT sc.student_id) AS student_count
FROM courses c
JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.name;
SELECT c.name, AVG(cg.grade) AS average_grade
FROM courses c
JOIN student_courses sc ON c.id = sc.course_id
JOIN course_grades cg ON sc.student_id = cg.student_id AND sc.course_id = cg.course_id
GROUP BY c.name;
