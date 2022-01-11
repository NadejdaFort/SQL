CREATE TABLE author
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(128) NOT NULL,
    last_name  VARCHAR(128) NOT NULL,
    UNIQUE (first_name, last_name)
);

CREATE TABLE book
(
    id        BIGSERIAL PRIMARY KEY,
    title     VARCHAR(128) NOT NULL,
    year      SMALLINT     NOT NULL,
    pages     SMALLINT     NOT NULL,
    author_id INT          REFERENCES author (id) ON DELETE SET NULL,
    UNIQUE (title, author_id)
);

INSERT INTO author (first_name, last_name)
VALUES ('Кей', 'Хорстманн'),
       ('Стивен', 'Кови'),
       ('Тони', 'Роббинс'),
       ('Наполеон', 'Хилл'),
       ('Роберт', 'Кийосаки'),
       ('Дейл', 'Карнеги');

SELECT *
FROM author;

INSERT INTO book (title, year, pages, author_id)
VALUES ('Java. Библиотека профессионала. Том 1', 2010, 1102, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java. Библиотека профессионала. Том 2', 2012, 954, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('Java SE 8. Вводный курс', 2015, 203, (SELECT id FROM author WHERE last_name = 'Хорстманн')),
       ('7 навыков высокоэффективных людей', 1989, 396, (SELECT id FROM author WHERE last_name = 'Кови')),
       ('Разбуди в себе исполина', 1991, 576, (SELECT id FROM author WHERE last_name = 'Роббинс')),
       ('Думай и богатей', 1937, 336, (SELECT id FROM author WHERE last_name = 'Хилл')),
       ('Богатый папа, бедный папа', 1937, 352, (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Квадрант денежного потока', 1998, 368, (SELECT id FROM author WHERE last_name = 'Кийосаки')),
       ('Как перестать беспокоиться и начать жить', 1948, 368, (SELECT id FROM author WHERE last_name = 'Карнеги')),
       ('Как завоевывать друзей и оказывать влияние на людей', 1936, 352,
        (SELECT id FROM author WHERE last_name = 'Карнеги'));

SELECT *
FROM book;

--     4. Написать запрос, выбирающий: название книги, год и имя автора, отсортированные
--     по году издания книги в возрастающем порядке.
--     Написать тот же запрос, но для убывающего порядка.

SELECT b.title,
       b.year,
       (SELECT first_name || ' ' || last_name FROM author a WHERE a.id = b.author_id) author
FROM book b
ORDER BY b.year;

SELECT b.title,
       b.year,
       (SELECT first_name || ' ' || last_name FROM author a WHERE a.id = b.author_id) author
FROM book b
ORDER BY b.year DESC;

--     5. Написать запрос, выбирающий количество книг у заданного автора

SELECT count(*)
FROM book
WHERE author_id = (SELECT id FROM author WHERE last_name = 'Хорстманн');

--     6. Написать запрос, выбирающий книги, у которых количество страниц больше
--     среднего количества страниц по всем книгам.

SELECT *
FROM book
WHERE pages > (SELECT avg(pages) FROM book);

--     7. Написать запрос, выбирающий 5 самых старых книг
--     Дополнить запрос и посчитать суммарное количество страниц среди этих книг

SELECT sum(pages)
FROM (
         SELECT pages
         FROM book
         ORDER BY year
         LIMIT 5) old_book;

--     8. Написать запрос, изменяющий количество страниц у одной из книг

UPDATE book
SET pages = 596
WHERE title = '7 навыков высокоэффективных людей'
RETURNING id, title, pages;

--     9. Написать запрос, удаляющий автора, который написал самую большую книгу.

DELETE
FROM book
WHERE author_id = (SELECT author_id
                   FROM book
                   WHERE pages = (SELECT max(pages)
                                  FROM book));

-- DELETE
-- FROM author
-- WHERE id = (SELECT author_id
--             FROM book
--             WHERE pages = (SELECT max(pages)
--                            FROM book));

DELETE
FROM author
WHERE id = 1;