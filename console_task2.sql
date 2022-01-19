--CREATE DATABASE flight_repository;

-- airport (аэропорт)
--     code (уникальный код аэропорта)
--     country (страна)
--     city (город)
CREATE TABLE airport
(
    code    CHAR(3) PRIMARY KEY,
    country VARCHAR(256) NOT NULL,
    city    VARCHAR(128) NOT NULL
);

-- aircraft (самолет)
--      id
--      model (модель самолета - unique)
CREATE TABLE aircraft
(
    id    SERIAL PRIMARY KEY,
    model VARCHAR(128) NOT NULL
);

-- seat (место в самолете)
--      aircraft_id (самолет)
--      seat_no (номер места в самолете)
CREATE TABLE seat
(
    aircraft_id INT REFERENCES aircraft (id),
    seat_no     VARCHAR(4) NOT NULL,
    PRIMARY KEY (aircraft_id, seat_no)
);

-- flight (рейс)
--     id (номер рейса не уникальный, поэтому нужен id)
--     flight_no (номер рейса)
--     departure_date (дата вылета)
--     departure_airport_code (аэропорт вылета)
--     arrival_date (дата прибытия)
--     arrival_airport_code (аэропорт прибытия)
--     aircraft_id (самолет)
--     status (статус рейса: cancelled, arrived, departed, scheduled)
CREATE TABLE flight
(
    id                     BIGSERIAL PRIMARY KEY,
    flight_no              VARCHAR(16)                       NOT NULL,
    departure_date         TIMESTAMP                         NOT NULL,
    departure_airport_code CHAR(3) REFERENCES airport (code) NOT NULL,
    arrival_date           TIMESTAMP                         NOT NULL,
    arrival_airport_code   CHAR(3) REFERENCES airport (code) NOT NULL,
    aircraft_id            INT REFERENCES aircraft (id)      NOT NULL,
    status                 VARCHAR(32)                       NOT NULL -- cancelled, arrived, departed, scheduled
);

-- ticket (билет на самолет)
--     id
--     passenger_no (номер паспорта пассажира)
--     passenger_name (имя и фамилия пассажира)
--     flight_id (рейс)
--     seat_no (номер места в самолете – flight_id + seat-no - unique)
--     cost (стоимость)
CREATE TABLE ticket
(
    id             BIGSERIAL PRIMARY KEY,
    passenger_no   VARCHAR(32)                   NOT NULL,
    passenger_name VARCHAR(128)                  NOT NULL,
    flight_id      BIGINT REFERENCES flight (id) NOT NULL,
    seat_no        VARCHAR(4)                    NOT NULL,
    cost           NUMERIC(8, 2)                 NOT NULL
--    UNIQUE (flight_id, seat_no)
);

CREATE UNIQUE INDEX unique_flight_id_seat_no_idx ON ticket (flight_id, seat_no);
-- flight_id + seat_no = flight_idseat_no

SELECT *
FROM ticket
WHERE seat_no = 'B1'
AND flight_id = 5;

SELECT count(DISTINCT flight_id)
FROM ticket;

SELECT count(*)
FROM ticket;

-- 9 / 55 - селективность плохая
-- 55 / 55 - хорошая селективность

insert into airport (code, country, city)
values ('MNK', 'Беларусь', 'Минск'),
       ('LDN', 'Англия', 'Лондон'),
       ('MSK', 'Россия', 'Москва'),
       ('BSL', 'Испания', 'Барселона');

insert into aircraft (model)
values ('Боинг 777-300'),
       ('Боинг 737-300'),
       ('Аэробус A320-200'),
       ('Суперджет-100');

insert into seat (aircraft_id, seat_no)
select id, s.column1
from aircraft
         cross join (values ('A1'),
                            ('A2'),
                            ('B1'),
                            ('B2'),
                            ('C1'),
                            ('C2'),
                            ('D1'),
                            ('D2')
                     order by 1) s;

insert into flight (flight_no, departure_date, departure_airport_code, arrival_date, arrival_airport_code, aircraft_id,
                    status)
values ('MN3002', '2020-06-14T14:30', 'MNK', '2020-06-14T18:07', 'LDN', 1, 'ARRIVED'),
       ('MN3002', '2020-06-16T09:15', 'LDN', '2020-06-16T13:00', 'MNK', 1, 'ARRIVED'),
       ('BC2801', '2020-07-28T23:25', 'MNK', '2020-07-29T02:43', 'LDN', 2, 'ARRIVED'),
       ('BC2801', '2020-08-01T11:00', 'LDN', '2020-08-01T14:15', 'MNK', 2, 'DEPARTED'),
       ('TR3103', '2020-05-03T13:10', 'MSK', '2020-05-03T18:38', 'BSL', 3, 'ARRIVED'),
       ('TR3103', '2020-05-10T07:15', 'BSL', '2020-05-10T012:44', 'MSK', 3, 'CANCELLED'),
       ('CV9827', '2020-09-09T18:00', 'MNK', '2020-09-09T19:15', 'MSK', 4, 'SCHEDULED'),
       ('CV9827', '2020-09-19T08:55', 'MSK', '2020-09-19T10:05', 'MNK', 4, 'SCHEDULED'),
       ('QS8712', '2020-12-18T03:35', 'MNK', '2020-12-18T06:46', 'LDN', 2, 'ARRIVED');

insert into ticket (passenger_no, passenger_name, flight_id, seat_no, cost)
values ('112233', 'Иван Иванов', 1, 'A1', 200),
       ('23234A', 'Петр Петров', 1, 'B1', 180),
       ('SS988D', 'Светлана Светикова', 1, 'B2', 175),
       ('QYASDE', 'Андрей Андреев', 1, 'C2', 175),
       ('POQ234', 'Иван Кожемякин', 1, 'D1', 160),
       ('898123', 'Олег Рубцов', 1, 'A2', 198),
       ('555321', 'Екатерина Петренко', 2, 'A1', 250),
       ('QO23OO', 'Иван Розмаринов', 2, 'B2', 225),
       ('9883IO', 'Иван Кожемякин', 2, 'C1', 217),
       ('123UI2', 'Андрей Буйнов', 2, 'C2', 227),
       ('SS988D', 'Светлана Светикова', 2, 'D2', 277),
       ('EE2344', 'Дмитрий Трусцов', 3, 'А1', 300),
       ('AS23PP', 'Максим Комсомольцев', 3, 'А2', 285),
       ('322349', 'Эдуард Щеглов', 3, 'B1', 99),
       ('DL123S', 'Игорь Беркутов', 3, 'B2', 199),
       ('MVM111', 'Алексей Щербин', 3, 'C1', 299),
       ('ZZZ111', 'Денис Колобков', 3, 'C2', 230),
       ('234444', 'Иван Старовойтов', 3, 'D1', 180),
       ('LLLL12', 'Людмила Старовойтова', 3, 'D2', 224),
       ('RT34TR', 'Степан Дор', 4, 'A1', 129),
       ('999666', 'Анастасия Шепелева', 4, 'A2', 152),
       ('234444', 'Иван Старовойтов', 4, 'B1', 140),
       ('LLLL12', 'Людмила Старовойтова', 4, 'B2', 140),
       ('LLLL12', 'Роман Дронов', 4, 'D2', 109),
       ('112233', 'Иван Иванов', 5, 'С2', 170),
       ('NMNBV2', 'Лариса Тельникова', 5, 'С1', 185),
       ('DSA586', 'Лариса Привольная', 5, 'A1', 204),
       ('DSA583', 'Артур Мирный', 5, 'B1', 189),
       ('DSA581', 'Евгений Кудрявцев', 6, 'A1', 204),
       ('EE2344', 'Дмитрий Трусцов', 6, 'A2', 214),
       ('AS23PP', 'Максим Комсомольцев', 6, 'B2', 176),
       ('112233', 'Иван Иванов', 6, 'B1', 135),
       ('309623', 'Татьяна Крот', 6, 'С1', 155),
       ('319623', 'Юрий Дувинков', 6, 'D1', 125),
       ('322349', 'Эдуард Щеглов', 7, 'A1', 69),
       ('DIOPSL', 'Евгений Безфамильная', 7, 'A2', 58),
       ('DIOPS1', 'Константин Швец', 7, 'D1', 65),
       ('DIOPS2', 'Юлия Швец', 7, 'D2', 65),
       ('1IOPS2', 'Ник Говриленко', 7, 'C2', 73),
       ('999666', 'Анастасия Шепелева', 7, 'B1', 66),
       ('23234A', 'Петр Петров', 7, 'C1', 80),
       ('QYASDE', 'Андрей Андреев', 8, 'A1', 100),
       ('1QAZD2', 'Лариса Потемнкина', 8, 'A2', 89),
       ('5QAZD2', 'Карл Хмелев', 8, 'B2', 79),
       ('2QAZD2', 'Жанна Хмелева', 8, 'С2', 77),
       ('BMXND1', 'Светлана Хмурая', 8, 'В2', 94),
       ('BMXND2', 'Кирилл Сарычев', 8, 'D1', 81),
       ('SS988D', 'Светлана Светикова', 9, 'A2', 222),
       ('SS978D', 'Андрей Желудь', 9, 'A1', 198),
       ('SS968D', 'Дмитрий Воснецов', 9, 'B1', 243),
       ('SS958D', 'Максим Гребцов', 9, 'С1', 251),
       ('112233', 'Иван Иванов', 9, 'С2', 135),
       ('NMNBV2', 'Лариса Тельникова', 9, 'B2', 217),
       ('23234A', 'Петр Петров', 9, 'D1', 189),
       ('123951', 'Полина Зверева', 9, 'D2', 234);

-- 3. Кто летел позавчера рейсом Минск (MNK) - Лондон (LDN) на месте B1?

SELECT *
FROM ticket t
         JOIN flight f ON t.flight_id = f.id
WHERE seat_no = 'B1'
  AND departure_airport_code = 'MNK'
  AND arrival_airport_code = 'LDN'
  AND departure_date::DATE = (SELECT now() - INTERVAL '2 days')::DATE;
--   AND departure_date::DATE = '2020-12-18';

--------*- - - - - - *--------
SELECT INTERVAL '2 years 1 days'::TIME;
SELECT '123'::INTEGER;

-- 4. Сколько мест осталось незанятыми 2020-06-14 на рейсе MN3002?

SELECT t2.count - t1.count
FROM (
         SELECT f.aircraft_id, count(*)
         FROM ticket t
                  JOIN flight f ON t.flight_id = f.id
         WHERE f.flight_no = 'MN3002'
           AND f.departure_date::DATE = '2020-06-14'
         GROUP BY f.aircraft_id
     ) t1
         JOIN (
    SELECT aircraft_id, count(*)
    FROM seat
    GROUP BY aircraft_id
) t2
              ON t1.aircraft_id = t2.aircraft_id;

SELECT EXISTS(SELECT 1 FROM ticket WHERE id = 1);

-- 2 variant
SELECT s.seat_no
FROM seat s
WHERE aircraft_id = 1
  AND NOT EXISTS(
        SELECT t.seat_no
        FROM ticket t
                 JOIN flight f ON t.flight_id = f.id
        WHERE f.flight_no = 'MN3002'
          AND f.departure_date::DATE = '2020-06-14'
          AND s.seat_no = t.seat_no);

-- 3 variant
SELECT aircraft_id, s.seat_no
FROM seat s
WHERE aircraft_id = 1
EXCEPT
SELECT f.aircraft_id, t.seat_no
FROM ticket t
         JOIN flight f ON t.flight_id = f.id
WHERE f.flight_no = 'MN3002'
  AND f.departure_date::DATE = '2020-06-14';

-- 5. Какие 2 перелета были самые длительные за все время?

SELECT f.id, f.flight_no, f.arrival_date - f.departure_date period
FROM flight f
ORDER BY period DESC
LIMIT 2;

SELECT f.id,
       f.flight_no
FROM flight f
ORDER BY f.arrival_date - f.departure_date DESC
LIMIT 2;

-- 6. Какая максимальная и минимальная продолжительность перелетов между Минском и Лондоном и сколько было всего таких перелетов?
SELECT max(t.period),
       min(t.period),
       count(t.period)
FROM (
         SELECT f.arrival_date - f.departure_date period
         FROM flight f
         WHERE f.departure_airport_code = 'MNK'
           AND f.arrival_airport_code = 'LDN'
     ) t;

SELECT first_value(f.arrival_date - f.departure_date)
       over (ORDER BY (f.arrival_date - f.departure_date) DESC)                                           max_value,
       first_value(f.arrival_date - f.departure_date) over (ORDER BY (f.arrival_date - f.departure_date)) min_value,
       count(*) OVER ()
FROM flight f
         JOIN airport a ON f.arrival_airport_code = a.code
         JOIN airport d ON f.departure_airport_code = d.code
WHERE a.city = 'Лондон'
  AND d.city = 'Минск'
LIMIT 1;

-- 7. Какие имена встречаются чаще всего и какую долю от числа всех пассажиров они составляют?
-- у функций 3 составляющих: - возвращаемое значение, имя функции, и параметры в ()
SELECT t.passenger_name,
       count(t.passenger_name),
       round(100.0 * count(t.passenger_name) / (SELECT count(*) FROM ticket), 2)
FROM ticket t
GROUP BY t.passenger_name
ORDER BY 2 DESC;

-- 8. Вывести имена пассажиров, сколько всего каждый с таким именем купил билетов, а также на сколько это количество
-- меньше от того имени пассажира, кто купил билетов больше всего

SELECT t1.*,
       first_value(t1.cnt) over () - t1.cnt
FROM (
         SELECT t.passenger_no,
                t.passenger_name,
                count(t.passenger_name) cnt
         FROM ticket t
         GROUP BY t.passenger_no, t.passenger_name
         ORDER BY 3 DESC
     ) t1;

-- 9. Вывести стоимость всех маршрутов по убыванию. Отобразить разницу в стоимости между текущим
-- и ближайшими в отсортированном списке маршрутами

SELECT t1.*,
       t1.sum_cost - COALESCE(lead(t1.sum_cost) OVER (ORDER BY t1.sum_cost DESC), t1.sum_cost) diff
FROM (
         SELECT t.flight_id,
                sum(t.cost) sum_cost
         FROM ticket t
         GROUP BY t.flight_id
         ORDER BY 2 DESC
     ) t1;

VALUES (1, 2), (3, 4), (5, 6), (7, 8)
UNION
VALUES (1, 2), (3, 4), (5, 6), (7, 8);

VALUES (1, 2), (3, 4), (5, 6), (7, 8)
UNION ALL
VALUES (1, 2), (3, 4), (5, 6);

VALUES (1, '2'), (3, '4'), (5, '6'), (7, '8')
INTERSECT
VALUES (1, '2'), (4, '4'), (5, '6');

VALUES (1, 3), (3, 4), (5, 7), (7, 8)
EXCEPT
VALUES (1, 2), (3, 4), (7, 8);

SELECT *
FROM ticket
WHERE id = 29;

EXPLAIN SELECT *
FROM ticket;

-- синтаксический оптимизатор (rule-based)
-- стоимостной оптимизатор (cost-based)
--- page_cost (input-output) = 1.0
--- cpu_cost = 0.01

-- 55 * 0.01 = 0.55 (cpu_cost)
-- x * 1.0 = ?

-- x - количество страниц, которое занимает таблица ticket, как определить?
-- 1.0 - стоимость (1 операция ввода-вывода input-output)

-- смотрим, что в pg-class есть на таблицу ticket
SELECT reltuples,
       relkind,
       relpages
FROM flight_repository.pg_catalog.pg_class
WHERE relname = 'ticket';

-- 55 * 0.01 = 0.55 (cpu_cost)
-- 1 * 1.0 = 1 (page_cost)
--      1.55

-- определяем сколько места занимает одна строка в таблице ticket
-- id bigint 8 байт
-- passenger_no varchar(32) 32 символа, но латиница занимает по 1 байту, а русский или китайский алфавит больше
--                          поэтому существует формула для расчета
-- passenger_name varchar(128)
-- flight_id bigint 8
-- seat_no varchar(4)
-- cost numeric(8,2) 8 байт

-- 8 + 6 + 28 + 8 + 2 + 8 = 60 байт весит 1 строка

SELECT avg(bit_length(passenger_no) / 8) p_no,
        avg(bit_length(passenger_name)/ 8) p_name,
       avg(bit_length(seat_no) / 8) s_no
FROM ticket;

EXPLAIN SELECT *
FROM ticket
WHERE passenger_name LIKE 'Иван%'
AND seat_no = 'B1';

EXPLAIN SELECT flight_id, count(*), sum(cost)
FROM ticket
GROUP BY flight_id;

EXPLAIN SELECT *
FROM ticket
WHERE id = 25;

CREATE TABLE test1 (
    id SERIAL PRIMARY KEY ,
    number1 INT NOT NULL ,
    number2 INT NOT NULL ,
    value VARCHAR(32)
);

CREATE INDEX test1_number1_idx ON test1(number1);
CREATE INDEX test1_number2_idx ON test1(number2);

INSERT INTO test1 (number1, number2, value)
SELECT random() * generate_series,
       random() * generate_series,
       generate_series
FROM generate_series(1, 100000);

SELECT relname,
       reltuples,
       relkind,
       relpages
FROM flight_repository.pg_catalog.pg_class
WHERE relname LIKE 'test1%';

ANALYZE test1;

EXPLAIN
SELECT *
FROM test1
WHERE number1 = 1000
AND value = '24234';

EXPLAIN
SELECT *
FROM test1
WHERE number1 = 1000
  OR value = '24234';

EXPLAIN
SELECT number1
FROM test1
WHERE number1 = 1000;

-- index only scan
-- index scan
-- bitmap scan (index scan, heap scan)

EXPLAIN
SELECT *
FROM test1
WHERE number1 < 1000 AND number1 > 90000;

-- 0 1 0 0 1 0 1 1 0 0 ... 636 times
-- 2 5 7 8 ... необходимые для считывания страницы

EXPLAIN
SELECT *
FROM test1
WHERE number1 < 1000 OR number2 > 90000;

-- 0 1 0 0 1 0 1 1 0 0 ... 636 times
-- 0 0 0 1 1 0 0 1 0 0 ... 636 times
--
-- 0 1 0 1 1 0 1 1 0 0 ... 636 times   BitmapOr
-- 0 0 0 0 1 0 0 1 0 0 ... 636 times   BitmapAnd

EXPLAIN
SELECT *
FROM test1
WHERE number1 < 1000 AND number2 > 90000;

EXPLAIN
SELECT *
FROM test1
WHERE number1 < 1000 AND number2 > 90000 AND value = '12334';

EXPLAIN ANALYZE
SELECT *
FROM test1
WHERE number1 < 10000;

-------------------------------------------------------------

CREATE TABLE test2 (
    id SERIAL PRIMARY KEY ,
    test1_id INT REFERENCES test1 (id) NOT NULL,
    number1 INT NOT NULL,
    number2 INT NOT NULL,
    value VARCHAR (32) NOT NULL
);

INSERT INTO test2 (test1_id, number1, number2, value)
SELECT id,
       random() * number1,
       random() * number2,
       value
FROM test1;

CREATE INDEX test2_number1_idx ON test2(number1);
CREATE INDEX test2_number2_idx ON test2(number2);

EXPLAIN ANALYZE
SELECT *
FROM test1 t1
    JOIN test2 t2 ON t1.id = t2.test1_id
LIMIT 100;                                          -- Nested Loop

-- Nested Loop
-- Hash Join
-- Merge Join

EXPLAIN ANALYZE
SELECT *
FROM test1 t1
    JOIN test2 t2 ON t1.id = t2.test1_id;    -- Hash Join

EXPLAIN ANALYZE
SELECT *
FROM test1 t1
    JOIN (SELECT * FROM test2 ORDER BY test1_id) t2
        ON t1.id = t2.test1_id;                      -- Merge Join

-- 1 4 5 6 8 9 10 22 ... test2.test1_id
-- 1 2 4 5 7 9 10 18 ... test1.id

-- сотрировать столбец дорого по стоимости => лучше сделать индекс на внешний ключ

CREATE INDEX test2_test1_id_idx ON test2 (test1_id);

ANALYZE test2;

EXPLAIN ANALYZE
SELECT *
FROM test1 t1
         JOIN test2 t2
              ON t1.id = t2.test1_id;

-- before

INSERT INTO aircraft(model)
VALUES ('new boeing');

-- after


CREATE TABLE audit
(
    id INT,
    table_name TEXT,
    data TIMESTAMP
);

CREATE OR REPLACE FUNCTION audit_function() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
    begin
        INSERT INTO audit(id, table_name,data)
        VALUES (new.id, tg_table_name, now());
        RETURN null;
    end;
    $$;

CREATE TRIGGER audit_aircraft_trigger
    AFTER UPDATE OR INSERT OR DELETE
    ON aircraft
    FOR EACH ROW
    EXECUTE FUNCTION audit_function();

INSERT INTO aircraft(model)
VALUES ('новый боинг');

SELECT *
FROM audit;
