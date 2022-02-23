# Домашняя работа к занятию 6.4 «PostgreSQL»

## _Задача №1_

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql
---
```
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ docker run --rm --name psql13 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=netology -v $PWD/backup:/media/postgresql/backup -v $PWD/test_data:/var/lib/postgresql/data -p 5434:5434 -d postgres:13
18da7c20acb7f7a2a9bd5f739f86d9e86e117b4cc2470149131eb0dd16f4b269
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS                                                 NAMES
18da7c20acb7   postgres:13   "docker-entrypoint.s…"   9 seconds ago   Up 7 seconds   5432/tcp, 0.0.0.0:5434->5434/tcp, :::5434->5434/tcp   psql13
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ docker exec -it psql13 bash
root@18da7c20acb7:/# psql -U postgres
psql (13.6 (Debian 13.6-1.pgdg110+1))
Type "help" for help.

postgres=#
```
- вывод списка БД:

 `\l[+]   [PATTERN]      list databases`

- подключение к БД:

```
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
```
- вывод списка таблиц:

`\dt[S+] [PATTERN]      list tables`

- вывод описания содержимого таблиц:
```
\d[S+]                 list tables, views, and sequences
\d[S+]  NAME           describe table, view, sequence, or index
```

- выход из psql:

`\q                     quit psql`


## _Задача №2_

Используя `psql` создайте БД `test_db`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_db`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

---

```
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ docker exec -t psql13 psql -U postgres -c "CREATE DATABASE "test_db";"
CREATE DATABASE
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ cat backup/test_dump.sql | docker exec -i psql13 psql -U postgres test_db
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ docker exec -it psql13 bash
root@9b203551f416:/# psql -U postgres
psql (13.6 (Debian 13.6-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_db=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```
- поиск столбца таблицы `orders` с наибольшим средним значением размера элементов в байтах:

```
test_db=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders' order by avg_width desc limit 1;
 attname | avg_width
---------+-----------
 title   |        16
(1 row)

test_db=#
```

## _Задача №3_

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции:

```
-- создаём новые таблицы
CREATE TABLE orders_1 (CHECK (price > 499)) INHERITS (orders);
CREATE TABLE orders_2 (CHECK (price <= 499)) INHERITS (orders);
-- переносим данные
INSERT INTO orders_1 (title, price) (select title, price from orders where price > 499);
INSERT INTO orders_2 (title, price) (select title, price from orders where price <= 499);

```
Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Да, до наполнения таблицы нужно было прописать RULE:
```
CREATE RULE rule_orders_1 AS ON INSERT TO orders WHERE (price > 499) 
DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);

CREATE RULE rule_orders_2 AS ON INSERT TO orders WHERE (price <= 499) 
DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
```




## _Задача №4_

Используя утилиту `pg_dump` создайте бекап БД `test_db`.


```
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ docker exec -t psql13 pg_dump -U postgres -Fc test_db > backup/test_db.dump
dmitry@Lenovo-B50:~/netology/virt/06-db-4/src$ ls -lha backup/
total 14K
drwxrwxr-x 2 dmitry dmitry 4,0K фев 23 12:30 .
drwxrwxr-x 4 dmitry dmitry 4,0K фев 20 21:06 ..
-rw-r--r-- 1 root   root   2,8K фев 23 12:26 test_db.dump
-rw-rw-r-- 1 dmitry dmitry 2,1K фев 20 21:04 test_dump.sql
```
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_db`?

Нужно добавить в текст дампа, где ппрописано создание таблицы, ограничение уникальности для столбца `title`, аналогично для таблиц-шардов:

```
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) UNIQUE NOT NULL,
    price integer DEFAULT 0
);
```