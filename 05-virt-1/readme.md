# **Домашняя работа к занятию 5.1 «Введение в виртуализацию. Типы и функции гипервизоров. Обзор рынка вендоров и областей применения».**
## _Задача №1_
_Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС._


## _Задача №2_
_Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования._

Организация серверов:

- физические сервера,
- паравиртуализация,
- виртуализация уровня ОС.

Условия использования:

- Высоконагруженная база данных, чувствительная к отказу.
- Различные web-приложения.
- Windows системы для использования бухгалтерским отделом.
- Системы, выполняющие высокопроизводительные расчеты на GPU.

_Опишите, почему вы выбрали к каждому целевому использованию такую организацию._




## _Задача №3_
_Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор._

_Сценарии:_

_1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий._

_2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин._

_3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры._

_4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux._

-------------------------------------

1. Первый сценарий, как мне кажется, лучше разделить на два:

**- 100 виртуальных машин...** - можно построить на базе и Hyper-V и VMWare и KVM в зависимости от имеющиеся инфраструктры и компетенций персонала. Также можно рассмотреть облачные решения: Yandex Cloud, Microsoft Azure, AWS EC2  
**- Преимущественно Windows-based инфраструктура...** - кластер на основе Hyper-V, как оптимальный для Windows инфраструктуры, с помощью его компонентов можно обеспечить и балансировку и репликацию, с помощью Veeam автоматическое резервирование.

2. Здесь я бы выбрал KVM - он бесплатен и производителен
3. Hyper-V Server - бесплатен, будет максимально совместим с Windows-инфраструктурой
4. В этом сценарии я бы использовал Oracle VirtualBox вместе с Vagrant, т.к. решение бесплатно и удобно для автоматического создания виртуальных машин для целей тестирования.

## _Задача №4_
_Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами._

Сам бы я не пошёл на создание гетерогенной среды, а если бы пришлось оказаться в месте, где она существует, то организовал бы её перевод в какую-то одну систему виртуализации.



