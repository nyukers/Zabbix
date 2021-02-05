#!/bin/sh

curl -s -k -X POST -H 'Content-Type: application/json-rpc' -d "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {},
    \"auth\": \"${AUTH}\",
    \"id\": 2
} " http://127.0.0.1/api_jsonrpc.php

# List of nodes
# get_host.sh | jq '.result | .[] | { host: .host} | tostring' | tr -d '{}\\' | tr '"' ' ' | cut -d ' ' -f5