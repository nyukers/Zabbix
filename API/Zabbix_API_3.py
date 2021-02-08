#!/usr/bin/python3

from pyzabbix import ZabbixAPI

import os
import sys
import pprint

# activate these lines for tracing
#import logging
#logging.basicConfig(filename='pyzabbix_debug.log' ,level=logging.DEBUG)

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = 'https://'+os.environ['Zhost']+'/zabbix'

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(os.environ['Zuser'], os.environ['Zpass'])

# Command line arg is the host_group to process
t_group = str(sys.argv[1])

host_group = zapi.hostgroup.get(output='extend',filter={'name': t_group},selectHosts=["name", "hostid"])

for host in host_group[0]["hosts"]:
host_info = zapi.host.get(hostids=host["hostid"],selectItems=["name", "description", "key_", "type"])
for item in host_info[0]["items"]:
if item["type"] == "8":
print(host_info[0]["name"], item["name"], item["description"], item["key_"])
 