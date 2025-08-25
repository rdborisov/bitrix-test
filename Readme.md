Для выполнения проекта было развернуто 3 виртуальные машины в кластере proxmox
OS: Ubuntu 22.04-live-server 
bitrix-main 192.168.0.136 - manager | 4 Gb ОЗУ | 4 cores
bitrix-prod 192.168.0.45 - worker | 4 Gb ОЗУ | 3 cores
bitrix-monitor 192.168.0.63 - worker | 2 Gb ОЗУ | 2 cores


После их развертывания был импортирован ssh ключ на manager машину командой
```
ssh-copy-id ruslan@192.168.0.63
```
docker был установлен при помощи bash скрипта ./sh/docker-setup.sh

В проекте использовался Portainer для отладки

Подключение portainer-agent требовалось только для ВМ manager:
```
docker network create \
--driver overlay \
  portainer_agent_network

docker service create \
  --name portainer_agent \
  --network portainer_agent_network \
  -p 9001:9001/tcp \
  --mode global \
  --constraint 'node.platform.os == linux' \
  --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
  --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes \
  --mount type=bind,src=//,dst=/host \
  portainer/agent:2.21.5
```
Подключение worker к manager выполнялось командой:
```
docker swarm join --token SWMTKN-1-27w2t1x3i7apeqor342mqze5jobd8rujeudq2ou1luxs-a6058jl8ii165127vv1vbrgi7 192.168.0.136:2377
```


Обычные редакции битрикса не работают с psql 
https://github.com/bitrix-tools/env-docker/issues/3#issuecomment-3034974273
Судя по комменту требуется версия "Энтерпрайз для Постгрес"
[Ссылка на Bitrix Enterprise для работы с postgresql](https://www.1c-bitrix.ru/download/portal/bitrix24_enterprise_postgresql_encode.tar.gz)


Для загрузки версии установщика выполнить на контейнере bitrix_php
```
docker compose exec --user=bitrix php sh
cd /opt/www/
wget https://www.1c-bitrix.ru/download/portal/bitrix24_enterprise_postgresql_encode.tar.gz
tar -xvzf bitrix24_enterprise_postgresql_encode.tar.gz

```