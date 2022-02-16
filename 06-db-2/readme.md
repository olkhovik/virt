# Домашняя работа к занятию 6.2 «SQL»


## _Задача №1_

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

---
Манифест `docker-compose.yaml`:
```
version: '3.6'

volumes:
  data: {}
  backup: {}

services:

  postgres:
    image: postgres:12
    container_name: psql
    ports:
      - "0.0.0.0:5433:5433"
    volumes:
      - data:/var/lib/postgresql/data
      - backup:/media/postgresql/backup
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "netology"
    restart: always
```
Запуск инстанса:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker-compose up -d
[+] Running 4/4
 ⠿ Network src_default  Created                                                                                                                                                                                                         0.1s
 ⠿ Volume "src_data"    Created                                                                                                                                                                                                         0.0s
 ⠿ Volume "src_backup"  Created                                                                                                                                                                                                         0.0s
 ⠿ Container psql       Started
 dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker exec -it psql  bash
 root@bc4451f7cabc:/# psql -h localhost -U postgres
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=#
```

## _Задача №2_

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

---
Создание ролей и базы данных:
```
postgres=# CREATE ROLE "test-admin-user";
CREATE ROLE
postgres=# CREATE DATABASE "test_db";
CREATE DATABASE
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# CREATE TABLE orders(id serial PRIMARY KEY, "Наименование" character varying(100), "Цена" integer);
CREATE TABLE
test_db=# CREATE TABLE clients(id serial PRIMARY KEY, "Фамилия" character varying(100), "Страна проживания" character varying(100), "Заказ" serial, FOREIGN KEY ("Заказ") REFERENCES orders(id));
CREATE TABLE
test_db=# GRANT ALL PRIVILEGES ON orders, clients TO "test-admin-user";
GRANT
test_db=# CREATE ROLE "test-simple-user";
CREATE ROLE
test_db=# GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";
GRANT
```
- итоговый список БД после выполнения пунктов выше:
```
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)
```
- описание таблиц (describe)

`clients`:
```
test_db=# \d clients
                                            Table "public.clients"
      Column       |          Type          | Collation | Nullable |                 Default
-------------------+------------------------+-----------+----------+------------------------------------------
 id                | integer                |           | not null | nextval('clients_id_seq'::regclass)
 Фамилия           | character varying(100) |           |          |
 Страна проживания | character varying(100) |           |          |
 Заказ             | integer                |           | not null | nextval('"clients_Заказ_seq"'::regclass)
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
```
`clients`:
```
test_db=# \d orders
                                       Table "public.orders"
    Column    |          Type          | Collation | Nullable |              Default
--------------+------------------------+-----------+----------+------------------------------------
 id           | integer                |           | not null | nextval('orders_id_seq'::regclass)
 Наименование | character varying(100) |           |          |
 Цена         | integer                |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db:

```
test_db=# SELECT grantee, table_name, privilege_type FROM information_schema.table_privileges WHERE grantee in ('test-admin-user','test-simple-user') and table_name in ('clients','orders') order by 1,2,3;
```
- список пользователей с правами над таблицами test_db:

```
grantee      | table_name | privilege_type
------------------+------------+----------------
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | TRIGGER
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | UPDATE
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
(22 rows)
```


## _Задача №3_

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

---
- Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

`orders`:
```
test_db=# SELECT * FROM orders;
 id | Наименование | Цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)
```

`clients`:
```
test_db=# SELECT * FROM clients;
 id |       Фамилия        | Страна проживания | Заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     
  2 | Петров Петр Петрович | Canada            |     
  3 | Иоганн Себастьян Бах | Japan             |     
  4 | Ронни Джеймс Дио     | Russia            |     
  5 | Ritchie Blackmore    | Russia            |     
(5 rows)
```
- вычислите количество записей для каждой таблицы:
`test_db=# SELECT COUNT(*) FROM orders;`
```
 count
-------
     5
(1 row)
```
`test_db=# SELECT COUNT(*) FROM clients;`
```
count
-------
     5
(1 row)
```

## _Задача №4_

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

---

- SQL-запросы для выполнения данных операций:
```
test_db=# UPDATE clients SET Заказ = (select id from orders where Наименование = 'Книга') where Фамилия = 'Иванов Иван Иванович';
UPDATE 1
test_db=# UPDATE clients SET Заказ = (select id from orders where Наименование = 'Монитор') where Фамилия = 'Петров Петр Петрович';
UPDATE 1
test_db=# UPDATE clients SET Заказ = (select id from orders where Наименование = 'Гитара') where Фамилия = 'Иоганн Себастьян Бах';
UPDATE 1
```

- SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса:
```
test_db=# SELECT c.* FROM clients c JOIN orders o on c.Заказ = o.id;
 id |       Фамилия        | Страна проживания | Заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```
 
## _Задача №5_

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

---
```
test_db=# explain select c.* from clients c join orders o on c.Заказ = o.id;
                              QUERY PLAN
-----------------------------------------------------------------------
 Hash Join  (cost=17.20..29.36 rows=170 width=444)
   Hash Cond: (c."Заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..11.70 rows=170 width=444)
   ->  Hash  (cost=13.20..13.20 rows=320 width=4)
         ->  Seq Scan on orders o  (cost=0.00..13.20 rows=320 width=4)
(5 rows)
```

1. Сначала будет полностью построчно прочитана таблица `orders`
2. Для неё будет создан хэш по полю `id`
3. После будет прочитана таблица `clients`,
4. Для каждой строки по полю `Заказ` будет проверено, соответствует ли она чему-то в кеше `orders`:
- Если ничему не соответствует - строка будет пропущена
- Если соответствует, то на основе этой строки и всех подходящих строках хеша СУБД сформирует вывод

При запуске просто `explain`, Postgres напишет только примерный план выполнения запроса и для каждой операции предположит:

- сколько роцессорного времени уйдёт на поиск первой записи и сбор всей выборки: `cost`=`первая_запись`..`вся_выборка`
- сколько примерно будет строк: `rows`
- какой будет средняя длина строки в байтах: `width`

**Postgres** делает предположения на основе статистики, которую собирает периодический выполня `analyze` запросы на выборку данных из служебных таблиц.

Если запустить `explain analyze`, то запрос будет выполнен и к плану добавятся уже точные данные по времени и объёму данных,
если `explain verbose` и `explain analyze verbose`, то для каждой операции выборки будут написаны поля таблиц, которые в выборку попали.

```
test_db=# explain analyze select c.* from clients c join orders o on c.Заказ = o.id;
                                                   QUERY PLAN
-----------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=17.20..29.36 rows=170 width=444) (actual time=0.122..0.135 rows=5 loops=1)
   Hash Cond: (c."Заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..11.70 rows=170 width=444) (actual time=0.022..0.026 rows=5 loops=1)
   ->  Hash  (cost=13.20..13.20 rows=320 width=4) (actual time=0.047..0.048 rows=6 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Seq Scan on orders o  (cost=0.00..13.20 rows=320 width=4) (actual time=0.020..0.027 rows=6 loops=1)
 Planning Time: 0.360 ms
 Execution Time: 0.203 ms
(8 rows)

test_db=# explain verbose select c.* from clients c join orders o on c.Заказ = o.id;
                                  QUERY PLAN
------------------------------------------------------------------------------
 Hash Join  (cost=17.20..29.36 rows=170 width=444)
   Output: c.id, c."Фамилия", c."Страна проживания", c."Заказ"
   Inner Unique: true
   Hash Cond: (c."Заказ" = o.id)
   ->  Seq Scan on public.clients c  (cost=0.00..11.70 rows=170 width=444)
         Output: c.id, c."Фамилия", c."Страна проживания", c."Заказ"
   ->  Hash  (cost=13.20..13.20 rows=320 width=4)
         Output: o.id
         ->  Seq Scan on public.orders o  (cost=0.00..13.20 rows=320 width=4)
               Output: o.id
(10 rows)

test_db=# explain analyze verbose select c.* from clients c join orders o on c.Заказ = o.id;
                                                       QUERY PLAN
------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=17.20..29.36 rows=170 width=444) (actual time=0.074..0.087 rows=5 loops=1)
   Output: c.id, c."Фамилия", c."Страна проживания", c."Заказ"
   Inner Unique: true
   Hash Cond: (c."Заказ" = o.id)
   ->  Seq Scan on public.clients c  (cost=0.00..11.70 rows=170 width=444) (actual time=0.022..0.025 rows=5 loops=1)
         Output: c.id, c."Фамилия", c."Страна проживания", c."Заказ"
   ->  Hash  (cost=13.20..13.20 rows=320 width=4) (actual time=0.030..0.031 rows=6 loops=1)
         Output: o.id
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Seq Scan on public.orders o  (cost=0.00..13.20 rows=320 width=4) (actual time=0.011..0.017 rows=6 loops=1)
               Output: o.id
 Planning Time: 0.361 ms
 Execution Time: 0.155 ms
(13 rows)
```

## _Задача №6_

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

```
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker exec -it psql  bash
root@bc4451f7cabc:/# pg_dump -U postgres -Fc test_db > /media/postgresql/backup/test_db.dump
```

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

```
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker-compose stop
[+] Running 1/1
 ⠿ Container psql  Stopped                                                                                                                                                                                                              0.4s
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED       STATUS                      PORTS     NAMES
bc4451f7cabc   postgres:12   "docker-entrypoint.s…"   5 hours ago   Exited (0) 34 seconds ago             psql
```

Поднимите новый пустой контейнер с PostgreSQL.

```
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker run --rm -d -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=netology -e POSTGRES_DB=test_db -v pgsl_backup:/media/postgresql/backup --name psql2 postgres:12
8700504a90ec0cb7912ac23d51a0c77b51fb5581549ee89425ded6fb965562da
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                      PORTS      NAMES
8700504a90ec   postgres:12   "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes               5432/tcp   psql2
bc4451f7cabc   postgres:12   "docker-entrypoint.s…"   6 hours ago      Exited (0) 10 minutes ago              psql
```

Восстановите БД test_db в новом контейнере.

```
dmitry@Lenovo-B50:~/netology/virt/06-db-2/src$ docker exec -it psql2  bash
root@8700504a90ec:/# pg_restore -U postgres -d test_db /media/postgresql/backup/test_db.dump
root@8700504a90ec:/#
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 


