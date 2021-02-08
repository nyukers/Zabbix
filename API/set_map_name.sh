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
} " http://127.0.0.1/api_jsonrpc.php