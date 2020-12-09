#!/bin/bash
token="1263828524:AAGkbvbJGTQ8y_xxxxx"
chat="$1"
subj="$2"
message="$3"
/usr/bin/curl --header 'Content-Type: application/json' --request 'POST' --data "{\"chat_id\":\"${chat}\",\"text\":\"${subj}\n${message}\"}" "https://api.telegram.org/bot${token}/sendMessage"