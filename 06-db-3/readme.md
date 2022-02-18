# Домашняя работа к занятию 6.3 «MySQL»


## _Задача №1_

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

---
Запуск инстанса MySQL:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-3/src$ docker run --rm --name mysql8 -e MYSQL_DATABASE=test_db -e MYSQL_ROOT_PASSWORD=netology -v $PWD/backup:/media/mysql/backup -v $PWD/test_data:/var/lib/mysql -v $PWD/config:/etc/mysql -p 3306:3306 -d mysql:8
540a82a3d7ccb28da591c08eadc82351bc6fdac0ce639ba40105d8ecc658bb4d
```
Раскатываем бэкап БД:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-3/src$ cat backup/test_dump.sql | docker exec -i mysql8 /usr/bin/mysql -u root --password=netology test_db
mysql: [Warning] Using a password on the command line interface can be insecure.
```
Захожу в управляющую консоль `mysql` внутри контейнера:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-3/src$ docker exec -it mysql8  bash
root@540a82a3d7cc:/# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
Команда для выдачи статуса БД - `\s`:
```
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
```
Подключаюсь к восстановленой БД и смотрю список таблиц в ней:
```
mysql> use test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```
Количество записей с `price` > 300:
```
mysql> select * from orders where price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)

mysql> select count(*) from orders where price > 300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)
```

## _Задача №2_

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

---
Создаю нового пользователя:
```
mysql> CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass' WITH MAX_CONNECTIONS_PER_HOUR 100 PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2 ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
Query OK, 0 rows affected (0.02 sec)
```
Предоставляю привелегии пользователю `test` на операции SELECT базы `test_db`:
```
mysql> GRANT SELECT on test_db.* to 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
Данные по пользователю `test`:
```
mysql> SELECT * from INFORMATION_SCHEMA.USER_ATTRIBUTES where user = 'test';
+------+-----------+------------------------------------------------+
| USER | HOST      | ATTRIBUTE                                      |
+------+-----------+------------------------------------------------+
| test | localhost | {"last_name": "Pretty", "first_name": "James"} |
+------+-----------+------------------------------------------------+
1 row in set (0.01 sec)

mysql> SELECT User, max_connections, password_lifetime, User_attributes  FROM mysql.user where user='test';
+------+-----------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------+
| User | max_connections | password_lifetime | User_attributes                                                                                                                              |
+------+-----------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------+
| test |             100 |               180 | {"metadata": {"last_name": "Pretty", "first_name": "James"}, "Password_locking": {"failed_login_attempts": 3, "password_lock_time_days": 2}} |
+------+-----------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

## _Задача №3_

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

---
Используется engine `InnoDB`:
```
mysql> SELECT table_schema,table_name,engine FROM information_schema.tables WHERE table_schema = DATABASE();
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)
```
Меняю `engine`:
```
mysql> set profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> alter table orders engine = 'MyISAM';
Query OK, 5 rows affected (0.09 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                |
+----------+------------+------------------------------------------------------------------------------------------------------+
|        1 | 0.00038450 | set profiling = 1                                                                                    |
|        2 | 0.08329450 | alter table orders engine = 'MyISAM'                                                                 |
+----------+------------+------------------------------------------------------------------------------------------------------+
2 rows in set, 1 warning (0.00 sec)

mysql> alter table orders engine = 'InnoDB';
Query OK, 5 rows affected (0.10 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                |
+----------+------------+------------------------------------------------------------------------------------------------------+
|        1 | 0.00038450 | set profiling = 1                                                                                    |
|        2 | 0.08329450 | alter table orders engine = 'MyISAM'                                                                 |
|        3 | 0.09588275 | alter table orders engine = 'InnoDB'                                                                 |
+----------+------------+------------------------------------------------------------------------------------------------------+
3 rows in set, 1 warning (0.00 sec)
```



## _Задача №4_ 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

---

Изменённый [`my.cnf`](https://github.com/olkhovik/virt/blob/main/06-db-3/src/config/my.cnf):
```
root@540a82a3d7cc:/# cat /etc/mysql/my.cnf
---
#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

# For InnoDb
innodb_flush_method = O_DSYNC
innodb_flush_log_at_trx_commit = 0
innodb_file_per_table = ON
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 2458M
innodb_log_file_size = 100M
```
объём RAM 8Гб
