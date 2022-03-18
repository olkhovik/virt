# Домашняя работа к занятию 7.2 «Облачные провайдеры и синтаксис Terraform».

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud.
Идеально будет познакомится с обоими облаками, потому что они отличаются. 

## Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 

AWS предоставляет достаточно много бесплатных ресурсов в первый год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
    * AmazonEC2FullAccess
    * AmazonS3FullAccess
    * AmazonDynamoDBFullAccess
    * AmazonRDSFullAccess
    * CloudWatchFullAccess
    * IAMFullAccess
1. Добавьте переменные окружения 
    ```
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)
    ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 

В виде результата задания приложите вывод команды `aws configure list`.

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

---

1. **Вариант с AWS:**

```
dmitry@Lenovo-B50:~/netology/virt/07-terraform-2$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************IA6V shared-credentials-file
secret_key     ****************37LS shared-credentials-file
    region               eu-west-2      config-file    ~/.aws/config
```


2. **Вариант с Yandex.Cloud:**

```
dmitry@Lenovo-B50:~/netology/virt/07-terraform-2$ yc config list
token: секретныйтокен
cloud-id: b1geslbp9nuv6dmu2j8d
folder-id: b1giran3f1dor113bp7u
compute-default-zone: ru-central1-a
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 


В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
1. Ссылку на репозиторий с исходной конфигурацией терраформа.  
 
---

1. **Вывод `terraform plan`:**

```
...
Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + aws_account_id     = "564619220947"
  + aws_net_private_ip = (known after apply)
  + aws_net_subnet_id  = (known after apply)
  + aws_region         = "ec2.eu-west-2.amazonaws.com"
  + aws_user_id        = "AIDAYG5PNS7J3ZPE5O5RB"
  + yandex_ip_private  = (known after apply)
  + yandex_vpc_subnet  = (known after apply)
  + yandex_zone        = (known after apply)
yandex_vpc_network.net: Creating...
yandex_vpc_network.net: Creation complete after 1s [id=enpbr2kl6m4eg5go2qo9]
yandex_vpc_subnet.subnet: Creating...
yandex_vpc_subnet.subnet: Creation complete after 1s [id=e9bdcpt63h57babuggv4]
yandex_compute_instance.vm: Creating...
aws_instance.ubuntu: Creating...
yandex_compute_instance.vm: Still creating... [10s elapsed]
aws_instance.ubuntu: Still creating... [10s elapsed]
aws_instance.ubuntu: Creation complete after 14s [id=i-006e5e5fee7b08ddb]
yandex_compute_instance.vm: Still creating... [20s elapsed]
yandex_compute_instance.vm: Creation complete after 23s [id=fhml8f3trfjv4iubadgf]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

aws_account_id = "575720331058"
aws_net_private_ip = "172.31.12.126"
aws_net_subnet_id = "subnet-06f7d1def39a73fd4"
aws_region = "ec2.eu-west-2.amazonaws.com"
aws_user_id = "AIDAYG5PNS7J3ZPE5O5RB"
yandex_ip_private = "10.2.0.11"
yandex_vpc_subnet = "e9bdcpt63h57babuggv4"
yandex_zone = "ru-central1-a"
```
2. **При помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?**
```
Packer
```

3. **Ссылка на репозиторий с исходной конфигурацией терраформа:**

https://github.com/olkhovik/virt/tree/main/07-terraform-2/terraform
