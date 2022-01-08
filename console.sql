CREATE DATABASE company_repository;

CREATE SCHEMA company_storage;

DROP SCHEMA company_storage;

CREATE TABLE company_storage.company
(
    id   INT,
    name VARCHAR(128) UNIQUE NOT NULL,
    date DATE NOT NULL CHECK (date > '1995-01-01' AND date < '2020-01-01'),
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

