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
} " http://127.0.0.1/api_jsonrpc.php | jq