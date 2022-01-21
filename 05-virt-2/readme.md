# **Домашняя работа к занятию 5.2 «Применение принципов IaaC в работе с виртуальными машинами».**
## _Задача №1_

- _Опишите своими словами основные преимущества применения на практике IaaC паттернов._
- _Какой из принципов IaaC является основополагающим?_
---------------------------------------------------------

1. Преимущества применения IaaC паттернов:

- Копии конфигураций серверов всегда доступны в стороннем хранилище, если что-то случится с сервером - есть бекап
- Доступна история изменений, можно откатиться, если что-то пошло не так
- Если нужно что-то уточнить о причинах или принятых решениях в конфигурации - известно к кому обращаться
- Удобно масштабировать
- Удобно вносить изменения - централизованно, через Git

2. Основополагающий принцип IaaC это **Идемпотентность** - возможность описать желаемое состояние того, что конфигурируется, с определённой гарантией что оно будет достигнуто.



## _Задача №2_

- _Чем Ansible выгодно отличается от других систем управление конфигурациями?_
- _Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?_
---------------------------------------------------------

1. Выгодные отличия Ansible от других систем:

- Если не удалось доставить конфигурацию на сервер, он оповестит об этом.
- Более простой синтаксис, чем, например, у **Saltstack**
- Работает без агента на клиентах, использует `ssh` для доступа к клиенту

2. Метод `Push` надёжней, т.к. централизованно управляет конфигурацией и исключает ситуации, когда кто-то что-то исправил напрямую на сервере и не отразил в репозитории - это может потеряться или создавать непредсказуемые ситуации.

## _Задача №3_

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

 _Приложить вывод команд установленных версий каждой из программ, оформленный в markdown._

-----------------------------------------------------------
Всё успешно установил:

1. VirtualBox:
```
dmitry@Lenovo-B50:~$ virtualbox --help | head -n 1 | awk '{print $NF}'
v6.1.32
```
2. Vagrant:
```
dmitry@Lenovo-B50:~$ vagrant --version
Vagrant 2.2.19
```
3. Ansible
```
dmitry@Lenovo-B50:~$ ansible --version
ansible [core 2.12.1]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/dmitry/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/dmitry/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
```


## _Задача №4 (*)_

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды `docker ps`

---------------------------------------------------------------
**Задаю провайдера по умолчанию, загружаю образ ВМ, проверяю доступные образы:**

```
dmitry@Lenovo-B50:/$ export VAGRANT_DEFAULT_PROVIDER=virtualbox
dmitry@Lenovo-B50:/$ vagrant box add bento/ubuntu-20.04 --provider=virtualbox --force
==> box: Loading metadata for box 'bento/ubuntu-20.04'
    box: URL: https://vagrantcloud.com/bento/ubuntu-20.04
==> box: Adding box 'bento/ubuntu-20.04' (v202112.19.0) for provider: virtualbox
    box: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-20.04/versions/202112.19.0/providers/virtualbox.box
==> box: Successfully added box 'bento/ubuntu-20.04' (v202112.19.0) for 'virtualbox'!
dmitry@Lenovo-B50:/$ vagrant box list
bento/ubuntu-20.04 (virtualbox, 202112.19.0)
```

**Конфиг** `Vagrantfile`:
```
# -*- mode: ruby -*-

ISO = "bento/ubuntu-20.04"
NET = "192.168.56."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "../ansible/inventory"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "ansible" do |setup|
        setup.inventory_path = INVENTORY_PATH
        setup.playbook = "../ansible/provision.yml"
        setup.become = true
        setup.extra_vars = { ansible_user: 'vagrant' }
      end
    end
  end
end
```
**Конфиг** `ansible.cfg`:
```
[defaults]
inventory=./inventory
deprecation_warnings=False
command_warnings=False
ansible_port=22
interpreter_python=/usr/bin/python3
```

**Конфиг** `inventory`:
```
[nodes:children]
manager

[manager]
server1.netology ansible_host=127.0.0.1 ansible_port=20011 ansible_user=vagrant
```

**Конфиг** `provision.yml`:
```
---

  - hosts: nodes
    become: yes
    become_user: root
    remote_user: vagrant

    tasks:
      - name: Create directory for ssh-keys
        file: state=directory mode=0700 dest=/root/.ssh/

      - name: Adding rsa-key in /root/.ssh/authorized_keys
        copy: src=~/.ssh/id_rsa.pub dest=/root/.ssh/authorized_keys owner=root mode=0600
        ignore_errors: yes

      - name: Checking DNS
        command: host -t A google.com

      - name: Installing tools
        apt: >
          package={{ item }}
          state=present
          update_cache=yes
        with_items:
          - git
          - curl

      - name: Installing docker
        shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

      - name: Add the current user to docker group
        user: name=vagrant append=yes groups=docker
```

**Запуск ВМ:**
```
dmitry@Lenovo-B50:~/Virt/vagrant$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202112.19.0' is up to date...
==> server1.netology: Setting the name of the VM: server1.netology
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: Warning: Connection reset. Retrying...
    server1.netology: Warning: Remote connection disconnect. Retrying...
    server1.netology:
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology:
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/dmitry/Virt/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
ok: [server1.netology]

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=git)
ok: [server1.netology] => (item=curl)

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
**Захожу в ВМ, проверяю конфигурацию созданной ВМ:**
```
dmitry@Lenovo-B50:~/Virt/vagrant$ vagrant ssh
....

vagrant@server1:~$ cat /etc/*release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.3 LTS"
NAME="Ubuntu"
VERSION="20.04.3 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.3 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
vagrant@server1:~$ ip a | grep inet | grep 192
    inet 192.168.56.11/24 brd 192.168.56.255 scope global eth1
vagrant@server1:~$ hostname -f
server1.netology
vagrant@server1:~$ free
              total        used        free      shared  buff/cache   available
Mem:        1004800      169292      164220         956      671288      682564
Swap:       2009084        2060     2007024
```
**Проверяю наличие Docker в ВМ:**
```
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
