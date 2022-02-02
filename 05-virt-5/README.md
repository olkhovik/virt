# **Домашняя работа к занятию 5.5 «Оркестрация кластером Docker контейнеров на примере Docker Swarm.»**

## _Задача №1_

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: `replication` и `global`?
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
- Что такое Overlay Network?
---
**1.** В режиме `replicated` приложение запускается в том количестве экземпляров, какое укажет пользователь. При этом на отдельной ноде может быть как несколько экземпляров приложения, так и не быть совсем.

В режиме `global` приложение запускается обязательно на каждой ноде и в единственном экземпляре.

**2.** Используется алгоритм выбора лидера **Raft:**

- Протокол решает проблему согласованности: чтобы все `manager` ноды имели одинаковое представление о состоянии кластера
- Для отказоустойчивой работы должно быть не менее трёх `manager` нод.
- Количество нод обязательно должно быть нечётным, но лучше не более 7 (это рекомендация из документации Docker).
- Среди `manager` нод выбирается лидер, его задача гарантировать согласованность.
- Лидер отправляет `keepalive` пакеты с заданной периодичностью в пределах 150-300мс. Если пакеты не пришли, менеджеры начинают выборы нового лидера.
- Если кластер разбит, нечётное количество нод должно гарантировать, что кластер останется консистентным, т.к. факт изменения состояния считается совершенным, если его отразило большинство нод. Если разбить кластер пополам, нечётное число гарантирует что в какой-то части кластера будеть большинство нод.

**3.** **Overlay Network** - это L2 VPN сеть для связи демонов Docker между собой. В основе используется технология `vxlan`


## _Задача №2_

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```
---
```
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
w6ybewkgnlt5g7i4q3hgyme61 *   node01.netology.yc   Ready     Active         Leader           20.10.12
ekfi92uhqlxxnadutgolexm8o     node02.netology.yc   Ready     Active         Reachable        20.10.12
mnxh7ih941g5w3ptny32ea647     node03.netology.yc   Ready     Active         Reachable        20.10.12
ubldfkmmjfx8z029hkpfzozr6     node04.netology.yc   Ready     Active                          20.10.12
2svyltmuh4d2hsnpu7ong2eb7     node05.netology.yc   Ready     Active                          20.10.12
bpbcwmpihvd2f48vuo3bb2nd9     node06.netology.yc   Ready     Active                          20.10.12
```

## _Задача №3_

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
---
```
[root@node01 ~]# docker stack ls
NAME               SERVICES    ORCHESTRATOR
swarm_monitoring   8           Swarm
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
z6nu16w6zpug   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
jud7cb3gfypa   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
363o2ywxvq8r   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
56ij34t47v6t   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
yxr7vbw9obd9   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
xamzy4a9g8pr   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
gsmotafkyd7k   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
aq6yo2py6rs3   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0 
```


## _Задача №4 (*)_

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```
---
```
[root@node02 ~]# docker node ls
Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.
[root@node03 ~]# docker swarm unlock
Please enter unlock key: 
[root@node03 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
w6ybewkgnlt5g7i4q3hgyme61     node01.netology.yc   Ready     Active         Leader           20.10.12
...
```
**`autolock`** - это функция, которая защищает Docker Swarm кластер от несанкционированного доступа к файлам нод.

При загрузке/перезапуске Docker в память каждой `manager` ноды загружается как ключ TLS, используемый для шифрования связи между нодами Docker Swarm, так и ключ, используемый для шифрования и расшифровки журналов Raft на диске. `autolock` защищает эти ключи. 
 
Функция `autolock` потребует вводить ключ разблокировки на `manager` ноде, чтобы она могла заново присоединиться к кластеру, если была перезапущена. Ввод ключа позволит расшифровать журнал Raft и загрузить в память ноды логины, пароли, TLS ключи и сертификаты, SSH ключи, имена баз данных и серверов.

