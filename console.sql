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
       (3, 'Facebook', '1998-09-13');

CREATE TABLE employee
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    salary     INT,
    UNIQUE (first_name, last_name)
);

DROP TABLE employee;

INSERT INTO employee (first_name, last_name, salary)
VALUES ('Ivan', 'Sidorov', 500),
       ('Ivan', 'Ivanov', 1000),
       ('Petr', 'Petrov', 2000),
       ('Sveta', 'Svetikova', 1500);

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

SELECT
       upper(first_name),
--        concat(first_name, ' ', last_name) fio
        first_name || ' ' || last_name fio
FROM employee empl;

SELECT now(), 1 * 2 + 3