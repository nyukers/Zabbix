###########################################
# Zabbix API
# (С)Лохтуров Вячеслав, 2021
#
# Zabbix 3+
# http://127.0.0.1/zabbix/api_jsonrpc.php
# Zabbix 4+
# http://127.0.0.1/api_jsonrpc.php

# Задание: сканировать через nmap определенные узлы и уведомлять, если результаты сканирования изменились 
# cat /root/zab_get_hosts_nmap.sh

#!/bin/sh

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"output\": [\"hostid\", \"host\"],
        \"templateids\": [\"10NNN\"]
    },
    \"auth\": \"${AUTH}\",
    \"id\": 2
} " http://127.0.0.1/zabbix/api_jsonrpc.php \
| jq '.result | .[] | { host: .host} | tostring' \
| tr -d '{}\\' | tr '"' ' ' | cut -d ' ' -f5 

# /root/zab_get_hosts_nmap.sh | tee /root/hosts_nmap.txt

# Периодически сканировать узлы (см. Пример текстового элемента) и передавать результаты сканирования в zabbix
cat /root/nmap_2_zabbix.sh

#!/bin/sh

while read host
do
        echo $host
        zabbix_sender -z 127.0.0.1 -p 10051 -s $host -k my.nmap \
        -o "$(/root/detect_host_nmap.sh $host)"
done

# /root/nmap_2_zabbix.sh < /root/hosts_nmap.txt