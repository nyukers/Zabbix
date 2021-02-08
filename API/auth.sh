# Query 1: Get AUTH

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

# Reply 
{"jsonrpc":"2.0","result":"56d7a9c49def0a32696cbe477a145d37","id":1}

# Query 2: Host.get

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d '
{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {},
    "auth": "56d7a9c49def0a32696cbe477a145d37",
    "id": 2
} ' http://127.0.0.1/api_jsonrpc.php | jq

# Query 3: Host.get by params

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d '
{
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
        "output": ["hostid", "10319"],
        "templateids": ["0"]
    },	
    "auth": "56d7a9c49def0a32696cbe477a145d37",
    "id": 2
} ' http://127.0.0.1/api_jsonrpc.php | jq

# Query 4: History.get from host

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d '
{
    "jsonrpc": "2.0",
    "method": "history.get",
    "params": {
        "output": "extend",
        "history": 0,
        "hostids": "10319",
        "sortfield": "clock",
        "sortorder": "DESC",
        "limit": 10
    },
	"auth": "56d7a9c49def0a32696cbe477a145d37",
    "id": 2
} ' http://127.0.0.1/api_jsonrpc.php | jq
