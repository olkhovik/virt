# Домашняя работа к занятию 6.5 «Elasticsearch»

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

---
- Dockerfile:
```
FROM centos:7
WORKDIR /usr/src/elasticsearch
RUN yum -y install wget sudo perl-Digest-SHA && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-linux-x86_64.tar.gz && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-linux-x86_64.tar.gz.sha512 && shasum -a 512 -c elasticsearch-oss-7.10.2-linux-x86_64.tar.gz.sha512 && tar -xzf elasticsearch-oss-7.10.2-linux-x86_64.tar.gz
RUN /bin/sh -c 'mkdir /var/lib/elasticsearch && mkdir /var/lib/elasticsearch/logs && mkdir /var/lib/elasticsearch/data && useradd -s /sbin/nologin elastic'
RUN /bin/sh -c 'rm -f /usr/src/elasticsearch/elasticsearch-7.10.2/config/elasticsearch.yml'
COPY config/* /usr/src/elasticsearch/elasticsearch-7.10.2/config/
RUN /bin/sh -c 'chown -R elastic /usr/src/elasticsearch/elasticsearch-7.10.2 && chown -R elastic /var/lib/elasticsearch'
EXPOSE 9200 9300
ENTRYPOINT sudo -u elastic /usr/src/elasticsearch/elasticsearch-7.10.2/bin/elasticsearch
```
- ссылка на образ в Dockerhub: https://hub.docker.com/r/endlessoda/elastic_netology

- создаём и запускаем контейнер:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker build -t endlessoda/elastic_netology .
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 endlessoda/elastic_netology
```

- ответ `elasticsearch` на запрос пути `/` в json виде:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker exec elastic curl -X GET 'localhost:9200/'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   535  100   535    0     0  34999      0 --:--:-- --:--:-- --:--:-- 35666
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "TaE8fSxBQ0a6CzLB4uM9cQ",
  "version" : {
    "number" : "7.10.2",
    "build_flavor" : "oss",
    "build_type" : "tar",
    "build_hash" : "747e1cc71def077253878a59143c1f785afa92b9",
    "build_date" : "2021-01-13T00:42:12.435326Z",
    "build_snapshot" : false,
    "lucene_version" : "8.7.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

---
- добавляю в `elasticsearch` 3 индекса:
```
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}' http://localhost:9200/ind-1
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 2, "number_of_replicas": 1}}}' http://localhost:9200/ind-2
curl -X PUT -H "Content-Type:application/json" -d '{"settings": {"index": {"number_of_shards": 4, "number_of_replicas": 2}}}' http://localhost:9200/ind-3
```
- список индексов и их статусов:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker exec elastic curl http://localhost:9200/_cat/indices
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   177  100   177    0     0   3715      0 --:--:-- --:--:-- --:--:--  3765
green  open ind-1 smi2JiCQS5q7PO_qxcOkyg 1 0 0 0 208b 208b
yellow open ind-3 dRz4-2n2TAWSjP_zHzKB8w 4 2 0 0 832b 832b
yellow open ind-2 WXowLmi0TSiG6IpIREtA8A 2 1 0 0 416b 416b
```
- состояние кластера `elasticsearch`:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker exec elastic curl 'http://localhost:9200/_cluster/health'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   403  100   403    0     0  34184      0 --:--:-- --:--:-- --:--:-- 36636
{
"cluster_name":"elasticsearch",
"status":"yellow",
"timed_out":false,
"number_of_nodes":1,
"number_of_data_nodes":1,
"active_primary_shards":7,
"active_shards":7,
"relocating_shards":0,
"initializing_shards":0,
"unassigned_shards":10,
"delayed_unassigned_shards":0,
"number_of_pending_tasks":0,
"number_of_in_flight_fetch":0,
"task_max_waiting_in_queue_millis":0,
"active_shards_percent_as_number":41.17647058823529
}
```
- почему часть индексов и кластер находится в состоянии yellow?

Для данных индексов установлено количество реплик отличное от 0 (что подразумевает наличие других узлов не меньше этого значения), но узел в кластере сейчас только один.

- удаляю все индексы:
```
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker exec elastic curl -X DELETE http://localhost:9200/ind-{1..3}
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    21  100    21    0     0    206      0 --:--:-- --:--:-- --:--:--   207
100    21  100    21    0     0    274      0 --:--:-- --:--:-- --:--:--   274
100    21  100    21    0     0    243      0 --:--:-- --:--:-- --:--:--   243
{
"acknowledged":true
}
dmitry@Lenovo-B50:~/netology/virt/06-db-5/src$ docker exec elastic curl 'http://localhost:9200/_cat/indices'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
