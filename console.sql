CREATE DATABASE company_repository;

CREATE SCHEMA company_storage;

DROP SCHEMA company_storage;

CREATE TABLE company_storage.company
(
    id   INT,
    name VARCHAR(128) UNIQUE NOT NULL,
    date DATE                NOT NULL CHECK (date > '1995-01-01' AND date < '2020-01-01'),
    PRIMARY KEY (id),
    UNIQUE (name, date)

-- NOT NULL
-- UNIQUE
-- CHECK
-- PRIMARY KEY == UNIQUE + NOT NULL
-- FOREIGN KEY
);

DROP TABLE company_storage.company;

-- DROP TABLE public.company;

INSERT INTO company (id, name, date)
VALUES (1, 'Google', '2001-01-01'),
       (2, 'Apple', '2002-10-29'),
       (3, 'Facebook', '1998-09-13'),
       (4, 'Amazon', '2005-06-17');

CREATE TABLE employee
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    company_id INT REFERENCES company (id) ON DELETE CASCADE,
    salary     INT,
    UNIQUE (first_name, last_name)
--     FOREIGN KEY (company_id) REFERENCES company (id)
);

DROP TABLE employee;

INSERT INTO employee (first_name, last_name, salary, company_id)
VALUES ('Ivan', 'Sidorov', 500, 1),
       ('Ivan', 'Ivanov', 1000, 2),
       ('Arni', 'Paramonov', NULL, 2),
       ('Petr', 'Petrov', 2000, 3),
       ('Sveta', 'Svetikova', 1500, NULL);

CREATE TABLE company_storage.contact
(
    id     SERIAL PRIMARY KEY,
    number VARCHAR(16) NOT NULL,
    type   VARCHAR(128)
);

INSERT INTO contact (number, type)
VALUES ('234-56-78', 'домашний'),
       ('987-65-43', 'рабочий'),
       ('953-08-07', 'мобильный'),
       ('134-34-18', 'домашний'),
       ('987-65-43', 'рабочий'),
       ('953-00-00', NULL),
       ('334-66-79', 'домашний'),
       ('900-00-43', NULL),
       ('955-88-77', 'мобильный');

CREATE TABLE company_storage.employee_contact
(
    employee_id INT NOT NULL REFERENCES employee (id),
    contact_id  INT NOT NULL REFERENCES contact (id)
);

INSERT INTO employee_contact (employee_id, contact_id)
VALUES ((SELECT id FROM employee WHERE last_name = 'Sidorov'), 1),
       ((SELECT id FROM employee WHERE last_name = 'Sidorov'), 2),
       ((SELECT id FROM employee WHERE last_name = 'Ivanov'), 3),
       ((SELECT id FROM employee WHERE last_name = 'Ivanov'), 4),
       ((SELECT id FROM employee WHERE last_name = 'Paramonov'), 5),
       ((SELECT id FROM employee WHERE last_name = 'Petrov'), 6),
       ((SELECT id FROM employee WHERE last_name = 'Petrov'), 7),
       ((SELECT id FROM employee WHERE last_name = 'Svetikova'), 8),
       ((SELECT id FROM employee WHERE last_name = 'Svetikova'), 9);

DROP TABLE company_storage.employee_contact;

SELECT DISTINCT id,
                first_name f_name,
                last_name  l_name,
                salary
FROM employee empl

WHERE salary IN (1000, 1100, 2000)
   OR (first_name LIKE ('Iv%')
    AND last_name ILIKE ('%ov'))
ORDER BY first_name, salary DESC;

-- > < >= <= = != (<>)
-- BETWEEN
-- LIKE (ILIKE) %           AND - OR
-- IN

SELECT count(salary)
FROM employee empl;
-- sum, avg, max, min, count

SELECT upper(first_name),
--        concat(first_name, ' ', last_name) fio
       first_name || ' ' || last_name fio
FROM employee empl;

SELECT now(), 1 * 2 + 3;

SELECT id, first_name
FROM employee
WHERE company_id IS NOT NULL
UNION
SELECT id, first_name
FROM employee
WHERE salary IS NULL;

SELECT avg(empl.salary)
FROM (SELECT *
      FROM employee
      ORDER BY salary
      LIMIT 2) empl;

SELECT *,
       (SELECT max(salary) FROM employee) - salary diff
FROM employee;

SELECT *
FROM employee
WHERE company_id IN (SELECT company.id FROM company WHERE date > '2000-01-01');

DELETE
FROM employee
WHERE salary IS NULL;

DELETE
FROM employee
WHERE salary = (SELECT max(salary) FROM employee);

DELETE
FROM company
WHERE id = 1;

DELETE
FROM employee
WHERE company_id = 1;

DELETE
FROM company
WHERE id = 2;

SELECT *
FROM employee;

UPDATE employee
SET company_id = 1,
    salary     = 1700
WHERE id = 10
   OR id = 9
RETURNING id, first_name || ' ' || last_name fio;

------------------------------------------------------------

SELECT company.name,
       employee.first_name || ' ' || employee.last_name fio
FROM employee,
     company
WHERE employee.company_id = company.id;

-- INNER JOIN               JOIN
-- CROSS JOIN               CROSS JOIN
-- LEFT OUTER JOIN          LEFT JOIN
-- RIGHT OUTER JOIN         RIGHT JOIN
-- FULL OUTER JOIN          FULL JOIN

SELECT company.name,
       employee.first_name || ' ' || employee.last_name fio,
       concat(contact.number, ' ', contact.type)
FROM employee
         JOIN company ON employee.company_id = company.id
         JOIN employee_contact ON employee.id = employee_contact.employee_id
         JOIN contact ON employee_contact.contact_id = contact.id;

SELECT *
FROM company
         CROSS JOIN
         (SELECT count(*) FROM employee) c;

SELECT c.name,
       e.first_name || ' ' || e.last_name fio
FROM company c
         LEFT JOIN employee e ON c.id = e.company_id;

SELECT c.name,
       e.first_name || ' ' || e.last_name fio
FROM employee e
         RIGHT JOIN company c ON c.id = e.company_id
    AND c.date > '2001-01-01';

SELECT c.name,
       e.first_name || ' ' || e.last_name fio
FROM employee e
         FULL JOIN company c ON c.id = e.company_id;

SELECT c.name,
       e.first_name || ' ' || e.last_name fio
FROM employee e
         CROSS JOIN company c;

SELECT c.name, count(e.id)
FROM company c
         LEFT JOIN employee e
                   ON c.id = e.company_id
-- WHERE c.name = 'Amazon'
GROUP BY c.id
HAVING count(e.id) > 0;

SELECT c.name,
       e.last_name,
--        count(e.id) OVER (),
--        max(e.salary) OVER (PARTITION BY c.name),
--        avg(e.salary) OVER (),
       row_number() OVER (),
       rank() OVER (ORDER BY e.salary NULLS FIRST), -- ранжирование по зарплате
       e.salary,
       lag(e.salary) OVER (ORDER BY e.salary) - e.salary,    -- предыдущая зарплата по компаниям
       dense_rank() OVER (ORDER BY e.salary NULLS FIRST),
       dense_rank() OVER (PARTITION BY c.name ORDER BY e.salary NULLS FIRST)
FROM company c
         LEFT JOIN employee e
                   ON c.id = e.company_id
ORDER BY c.name;