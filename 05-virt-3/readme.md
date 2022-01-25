# **Домашняя работа к занятию 5.3 «Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера.**
## _Задача №1_
_Сценарий выполения задачи:_

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность: запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
_Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo._

-----------------------------------------------------------
1. Dockerfile:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03/nginx$ cat Dockerfile
FROM nginx:1.21.5
COPY index.html /usr/share/nginx/html/index.html
```
2. Сборка Docker образа:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03/nginx$ docker build -t endlessoda/05-virt-3-nginx:1.21.5 .
Sending build context to Docker daemon  3.072kB
Step 1/2 : FROM nginx:1.21.5
1.21.5: Pulling from library/nginx
a2abf6c4d29d: Pull complete
a9edb18cadd1: Pull complete
589b7251471a: Pull complete
186b1aaa4aa6: Pull complete
b4df32aa5a72: Pull complete
a0bcbecc962e: Pull complete
Digest: sha256:0d17b565c37bcbd895e9d92315a05c1c3c9a29f762b011a10c54a66cd53c9b31
Status: Downloaded newer image for nginx:1.21.5
 ---> 605c77e624dd
Step 2/2 : COPY index.html /usr/share/nginx/html/index.html
 ---> 05ac4308e540
Successfully built 05ac4308e540
Successfully tagged endlessoda/05-virt-3-nginx:1.21.5
```
3. Запускаю Docker контейнер:
```dmitry@Lenovo-B50:~/Virt/05-virt-03/nginx$ docker run --rm -d --name nginx -p 8080:80 endlessoda/05-virt-3-nginx:1.21.5
22b57efd17e04119434df512f832658030f4c365cd8f53150a6b34c17f2abdb6
dmitry@Lenovo-B50:~/Virt/05-virt-03/nginx$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS                                   NAMES
22b57efd17e0   endlessoda/05-virt-3-nginx:1.21.5   "/docker-entrypoint.…"   28 seconds ago   Up 27 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   nginx
```
4. Выгружаю Docker образ на DockerHub:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03/nginx$ docker push endlessoda/05-virt-3-nginx:1.21.5
The push refers to repository [docker.io/endlessoda/05-virt-3-nginx]
72fa8a55327a: Pushed
d874fd2bc83b: Mounted from library/nginx
32ce5f6a5106: Mounted from library/nginx
f1db227348d0: Mounted from library/nginx
b8d6e692a25e: Mounted from library/nginx
e379e8aedd4d: Mounted from library/nginx
2edcec3590a4: Mounted from library/nginx
1.21.5: digest: sha256:fea6a0369dd05f5c15a6c58e082773b6e762a08ba2fa9a8dd2b8067b8779c5d4 size: 1777
```
5. Ссылка на DockerHub: https://hub.docker.com/r/endlessoda/05-virt-3-nginx



## _Задача №2_
_Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"_

_Детально опишите и обоснуйте свой выбор._

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.
------------------------------------------------------------
1. **Высоконагруженное монолитное java веб-приложение**

Лучше использовать физический сервер или виртуальную машину, т.к. Docker плохо подходит для высоконагруженных монолитных приложений.

2. **Nodejs веб-приложение**

Докер [подойдёт](https://grafana.com/blog/2019/05/07/ask-us-anything-should-i-run-prometheus-in-a-container/ "Ask Us Anything: Should I Run Prometheus in a Container?") хорошо, т.к. это позволит быстро развернуть приложение со всеми необходимыми библиотеками.

3. **Мобильное приложение c версиями для Android и iOS**

Докер не подходит для мобильных приложений и в целом для приложений с графическим интерфейсом.

[Есть](https://github.com/budtmo/docker-android "Android") [разные](https://github.com/sickcodes/Docker-OSX "OsX") [проекты](https://github.com/sickcodes/Docker-eyeOS "eyeOS"), посвящённые запуску эмуляторов и приложений для Android/iOS с использованием Docker.

Даже если это будет работать, как такие приложения поведут себя в реальной среде на ARM устройствах в интеграции мобильных платформ - вопрос.

4. **Шина данных на базе Apache Kafka**

Не знаком глубоко с Apache Kafka, но судя по найденной информации, такие системы успешно запускают в среде Docker.

Ещё очень важно иметь возможность быстро откатиться если приложение обновили, и в продакшене что-то пошло не так. Docker будет особенно удобен чтобы "вернуть как было" один из центральных узлов приложения - шину.

5. **Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana**

Докер в связке с Kubernetes будет хорошим решением для управления такой инфраструктурой.

6. **Мониторинг-стек на базе Prometheus и Grafana**

Docker подойдёт для этой задачи хорошо. Разворвачивать node_exporter с Docker скорей всего не стоит, т.к. ему требуется прямой доступ к метрикам ядра, но Prometheus и Grafana можно использовать в Докере.

7. **MongoDB, как основное хранилище данных для java-приложения**

Да, вполне подойдёт Docker. У MongoDB даже есть официальный образ на [Docker Hub](https://hub.docker.com/_/mongo  "MongoDB").

8. **Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry**

В общем случае, думаю удобней будет виртуальная машина, т.к. серверу GitLab не требуется масштабирование или деплой новой версии несколько раз в день, а виртуальная машина позволит очень удобно делать бекапы и при необходимости мигрировать её в кластере.

Если в компании повсеместно используются контейнеры - тогда, может, будет удобней Docker, т.к. инженерам это будет привычней.

## _Задача №3_

- Запустите первый контейнер из образа **centos** c любым тэгом в фоновом режиме, подключив папку `/data` из текущей рабочей директории на хостовой машине в `/data` контейнера;
- Запустите второй контейнер из образа **debian** в фоновом режиме, подключив папку `/data` из текущей рабочей директории на хостовой машине в `/data` контейнера;
- Подключитесь к первому контейнеру с помощью `docker exec` и создайте текстовый файл любого содержания в `/data`;
- Добавьте еще один файл в папку `/data` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в `/data` контейнера.
-------------------------------------------------------------
1. Запускаю контейнеры:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03$ docker run -it --rm -d --name centos -v $(pwd)/data:/data centos
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
2a700ef678313fb5635e3a862a3ff85bcc346edf1bc9d76950b3feb62116a30c
dmitry@Lenovo-B50:~/Virt/05-virt-03$ docker run -it --rm -d --name debian -v $(pwd)/data:/data debian
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
0e29546d541c: Pull complete
Digest: sha256:2906804d2a64e8a13a434a1a127fe3f6a28bf7cf3696be4223b06276f32f1f2d
Status: Downloaded newer image for debian:latest
8d5d8b3f3bf26a0b8edc5525f9b23504f6a7388cc2ad69d18dace9b6a1f5ea9f
dmitry@Lenovo-B50:~/Virt/05-virt-03$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
33b7a3fc8bc5   debian    "bash"        2 seconds ago    Up 1 second               debian
0e946f10d4c2   centos    "/bin/bash"   15 seconds ago   Up 13 seconds             centos
```
2. Подключаюсь к первому контейнеру `centos` и создаю файл:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03$ docker exec -it centos bash
[root@0e946f10d4c2 /]# echo "Hello from CentOS!" > /data/centos
[root@0e946f10d4c2 /]# exit
```
3. Создаю на хостовой машине файл:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03$ echo "Hello from Host!" > data/host
```
4. Подключаюсь ко второму контейнеру `debian` и смотрю в директорию `/data`:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03$ docker exec -it debian bash
root@33b7a3fc8bc5:/# ls -lha /data
total 16K
drwxrwxr-x 2 1000 1000 4.0K Jan 25 11:45 .
drwxr-xr-x 1 root root 4.0K Jan 25 11:37 ..
-rw-r--r-- 1 root root   19 Jan 25 11:43 centos
-rw-rw-r-- 1 1000 1000   17 Jan 25 11:45 host
```


## _Задача №4 (*)_
Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

----------------------------------------------
1. Dockerfile:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03/ansible$ cat Dockerfile
FROM alpine:3.15

RUN CARGO_NET_GIT_FETCH_WITH_CLI=1 && \
    apk --no-cache add \
        sudo \
        python3\
        py3-pip \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        openssl-dev \
        libressl-dev \
        build-base && \
    pip install --upgrade pip wheel && \
    pip install --upgrade cryptography cffi && \
    pip install ansible-core==2.12.1 && \
    pip install mitogen ansible-lint jmespath && \
    pip install --upgrade pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

CMD [ "ansible-playbook", "--version" ]
```
2. Сборка Docker образа:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03/ansible$ docker build -t endlessoda/05-virt-3-ansible:2.12.1 .
Sending build context to Docker daemon   2.56kB
Step 1/5 : FROM alpine:3.15
3.15: Pulling from library/alpine
59bf1c3509f3: Pull complete
Digest: sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300
Status: Downloaded newer image for alpine:3.15
 ---> c059bfaa849c
 ....
 OK: 97 MiB in 71 packages
Removing intermediate container 0c1cd56e731f
 ---> 6c2c6f7e6317
Step 3/5 : RUN mkdir /ansible &&     mkdir -p /etc/ansible &&     echo 'localhost' > /etc/ansible/hosts
 ---> Running in 3640a3459e42
Removing intermediate container 3640a3459e42
 ---> 96340f52df28
Step 4/5 : WORKDIR /ansible
 ---> Running in 28c5824e811b
Removing intermediate container 28c5824e811b
 ---> 5999cb232e8b
Step 5/5 : CMD [ "ansible-playbook", "--version" ]
 ---> Running in 9a6e21e9a7c1
Removing intermediate container 9a6e21e9a7c1
 ---> 5d9ac9c71646
Successfully built 5d9ac9c71646
Successfully tagged endlessoda/05-virt-3-ansible:2.12.1
```
3. Выгружаю Docker образ на DockerHub:
```
dmitry@Lenovo-B50:~/Virt/05-virt-03/ansible$ docker login -u endlessoda
Password:
Login Succeeded
dmitry@Lenovo-B50:~/Virt/05-virt-03/ansible$ docker push endlessoda/05-virt-3-ansible:2.12.1
The push refers to repository [docker.io/endlessoda/05-virt-3-ansible]
a200848efa73: Pushed
79d40a1498fb: Pushed
8d3ac3489996: Mounted from library/alpine
2.12.1: digest: sha256:dfc1d43276bd4f2c59abc8532f61be025ec7063800090d46e8c39cc8213e088d size: 947
```
4. Ссылка на DockerHub: https://hub.docker.com/r/endlessoda/05-virt-3-ansible


