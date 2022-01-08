CREATE DATABASE company_repository;

CREATE SCHEMA company_storage;

DROP SCHEMA company_storage;

CREATE TABLE company_storage.company (
    id INT,
    name VARCHAR(128),
    date DATE
);

-- DROP TABLE public.company;