############################################
# Zabbix API - построение топологии сети
# (С)Лохтуров Вячеслав, 2021
# https://wikival.bmstu.ru/doku.php?id=zabbix_-_%D0%BF%D0%BE%D1%81%D1%82%D1%80%D0%BE%D0%B5%D0%BD%D0%B8%D0%B5_%D1%82%D0%BE%D0%BF%D0%BE%D0%BB%D0%BE%D0%B3%D0%B8%D0%B8_%D1%81%D0%B5%D1%82%D0%B8
#
# Zabbix 3+
# http://127.0.0.1/zabbix/api_jsonrpc.php
# Zabbix 4+
# http://127.0.0.1/api_jsonrpc.php

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d '
{
   "jsonrpc": "2.0",
   "method": "user.login",
   "params": {
      "user": "Admin",
      "password": "zabbix"
   },
   "id": 1
} ' http://127.0.0.1/zabbix/api_jsonrpc.php

{"jsonrpc":"2.0","result":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx","id":1}

############################################
curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d '
{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": "extend"
    },
    "auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "id": 2
} ' http://127.0.0.1/zabbix/api_jsonrpc.php | jq

############################################
server.corp1.un:~# export AUTH=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
server.corp1.un:~# cat /root/zab_get_hosts.sh

#!/bin/sh

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {},
    \"auth\": \"${AUTH}\",
    \"id\": 2
} " http://127.0.0.1/zabbix/api_jsonrpc.php

server.corp1.un:~# /root/zab_get_hosts.sh | jq '.result | .[] | .host'
server.corp1.un:~# /root/zab_get_hosts.sh | jq '.result | .[] | {hostid: .hostid, host: .host}'
server.corp1.un:~# /root/zab_get_hosts.sh | jq '.result | .[] | {hostid: .hostid, host: .host} | tostring'
server.corp1.un:~# /root/zab_get_hosts.sh | jq '.result | .[] | {hostid: .hostid, host: .host} | tostring' | grep switch | tr -d '{}\\' | tr '"' ' ' | cut -d ' ' -f5,9 

# list_hostid_host.txt:
# 10111 switch1.corp1.un
# 10112 switch2.corp1.un
# 10113 switch3.corp1.un

############################################
# Получение списка карт и их элементов из Zabbix
server.corp1.un:~# cat /root/zab_get_maps.sh

#!/bin/sh

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"map.get\",
    \"params\": {
        \"selectLinks\": \"extend\",
        \"selectSelements\": \"extend\"
    },
    \"auth\": \"${AUTH}\",
    \"id\": 2
} " http://127.0.0.1/zabbix/api_jsonrpc.php | \
#jq
###zabbix3
jq '.result | .[] | .selements | .[] | {elementid: .elementid, selementid: .selementid} | tostring' | tr -d '{}\\' | tr '"' ' ' | cut -d ' ' -f5,9
###zabbix4
#jq '.result[1].selements[] | {elements, selementid} | tostring' | tr -d '{}\\' | tr '"' ' ' | cut -d ' ' -f7,11

# list_hostid_selementid.txt
# 10084 1
# 10111 2
# 10112 3
# 10113 4

############################################
# CDP+RSH:
server.corp1.un:~# cat /root/rsh_get_links.sh

#!/bin/sh

LIST_HOSTID_HOST=/root/list_hostid_host.txt
LIST_HOSTID_SELEMENTID=/root/list_hostid_selementid.txt

while read HOSTID HOST
do
        rsh $HOST -n show cdp nei | dos2unix | grep switch | tr -s " " | cut -d " " -f1,2,3,9,10 |
        while read CDPNEI LINKINTFACES
        do
                HOSTID2=`grep $CDPNEI $LIST_HOSTID_HOST | cut -d' ' -f1`
                SELEMENT2=`grep $HOSTID2 $LIST_HOSTID_SELEMENTID | cut -d' ' -f2`
                SELEMENT1=`grep $HOSTID $LIST_HOSTID_SELEMENTID | cut -d' ' -f2`
                echo $SELEMENT1 $SELEMENT2 $LINKINTFACES
        done
done < $LIST_HOSTID_HOST

server.corp1.un:~# /root/rsh_get_links.sh | tee list_selements_label.txt

# 2 3 Fas 0/2 Fas 0/5
# 2 4 Fas 0/8 Fas 0/5
# 3 2 Fas 0/5 Fas 0/2
# 4 2 Fas 0/5 Fas 0/8

############################################
# Пример изменения конфигурации через Zabbix API
server.corp1.un:~# cat /root/zab_set_map_name.sh

#!/bin/sh

MAPID=$1
MAPNAME=$2

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"map.update\",
    \"params\": {
        \"sysmapid\": \"${MAPID}\",
        \"name\": \"${MAPNAME}\"
    },
    \"auth\": \"${AUTH}\",
    \"id\": 2
} " http://127.0.0.1/zabbix/api_jsonrpc.php

############################################
server.corp1.un:~# cat /root/zab_set_link_name.sh

#!/bin/sh

MAPID=2
SELEMENTS_LABEL=/root/list_selements_label.txt

LINKS=""

while read SELEMENTID1 SELEMENTID2 LABEL
do
        LINKS="$LINKS
                {
                        \"label\": \"${LABEL}\",
                        \"selementid1\": \"${SELEMENTID1}\",
                        \"selementid2\": \"${SELEMENTID2}\"
                },"
done < $SELEMENTS_LABEL

#LINKS=`echo $LINKS | rev | cut -c 2- | rev`
#LINKS=`echo -n ${LINKS::-1}`

JSON="
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"map.update\",
    \"params\": {
        \"sysmapid\": \"${MAPID}\",

        \"links\": [
                ${LINKS}
        ]
    },
    \"auth\": \"${AUTH}\",
    \"id\": 2
} "

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d "$JSON" http://127.0.0.1/zabbix/api_jsonrpc.php

############################################
# Алгоритм добавления коммутатора на карту
#
# Добавляем в GNS новый коммутатор (с поддержкой snmp и rsh) и ждем, пока он появится в Zabbix, затем:
server.corp1.un:~# /root/zab_get_hosts.sh | tee list_hostid_host.txt

# Добавляем новый коммутатор на карту руцями и не забываем сохранить, затем:
server.corp1.un:~# /root/zab_get_maps.sh | tee list_hostid_selementid.txt

# Затем, а так же, при изменении топологии (в GNS перезагрузить узлы для поднятия линков и чистки таблиц CDP)
server.corp1.un:~# /root/rsh_get_links.sh | tee list_selements_label.txt

# Затем, перерисовываем связи:
server.corp1.un:~# /root/zab_set_link_name.sh

