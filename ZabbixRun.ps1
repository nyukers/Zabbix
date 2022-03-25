(Get-LocalGroupMember -Name Администраторы | where -Property PrincipalSource -eq Local).count

# Server <<< Client

# 1) By zabbix_sender 
$admin_local = (Get-LocalGroupMember -Name Администраторы | where -Property PrincipalSource -eq Local).count
c:\zabbix\zabbix_sender.exe -z 192.168.1.202 -s "GOVERLA" -k admin.local -o $admin_local

[int](Get-LocalUser -Name Maxima).Count
$1 = "Maxima"
(Get-LocalUser -Name $1).Count

# Сохраняем предыдущую кодировку
$prev = [Console]::OutputEncoding
# Меняем кодировку на UTF8
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Тут находится наш скрипт
$somedata = @{
    data=@(
        @{'{#NAME}'='Maxima';};
        @{'{#NAME}'='Admin';};
    )
}
$json = $somedata | ConvertTo-Json -Compress
$json = $json -replace '"','"""'
c:\zabbix\zabbix_sender.exe -z 192.168.1.202 -s "GOVERLA" -k admin.list -o $json

# Меняем кодировку на первоначальную
[Console]::OutputEncoding = $prev

# 2) By zabbix agent 
# AllowKey=system.run[*]
# UnsafeUserParameters=1
# UserParameter=admin.local[*],powershell -Command "[int](Get-LocalUser -Name $1).Count"
# UserParameter=admin.list,powershell -Command "@{data=@(@{'{#NAME}'='Maxima'};@{'{#NAME}'='Admin'})} | ConvertTo-Json" 


# 3) By zabbix_get 
c:\zabbix\zabbix_get -s 127.0.0.1 -p 10050 -k agent.ping --tls-connect=psk --tls-psk-identity="GOVERLA-PSK" --tls-psk-file="C:\Zabbix\psk.key"

$1 = "Maxima"
c:\zabbix\zabbix_get -s 127.0.0.1 -p 10050 -k admin.local["$1"] --tls-connect=psk --tls-psk-identity="GOVERLA-PSK" --tls-psk-file="C:\Zabbix\psk.key"

# получаем данные в формате json
$discovery_rules = c:\zabbix\zabbix_get -s 127.0.0.1 -p 10050 -k net.if.discovery --tls-connect=psk --tls-psk-identity="GOVERLA-PSK" --tls-psk-file="C:\Zabbix\psk.key"
# преобразовываем в массив Powershell
$object = $discovery_rules | ConvertFrom-Json

### Server >>> Client

# 4) By zabbix API 
$server = '192.168.1.202'
$url = 'http://'+$server+'/api_jsonrpc.php'

# Get token
$data = @{
    "jsonrpc"="2.0";
    "method"="user.login";
    "params"=@{
        "user"="Admin";
        "password"="*******";
    };
    "id"=1
}

$token = (Invoke-RestMethod -Method 'Post' -Uri $url -Body ($data | ConvertTo-Json) -ContentType "application/json")
$token.result 

# Get hosts
$data = @{
    "jsonrpc"="2.0";
    "method"="host.get";
    "params"=@{
    };
    "id"=2;
    "auth"=$token.result;
}

$data = @{
    "jsonrpc"="2.0";
    "method"="host.get";
    "params"=@{
        "output"=@(
            "hostid";
            "host";
        );
    };
    "id"=2;
    "auth"=$token.result;
}

$data = @{
    "jsonrpc"="2.0";
    "method"="trigger.get";
    "params"=@{
        "hostids"=@(10323;);
    };
    "auth"=$token.result;
    "id"=1;
}

$hosts = Invoke-RestMethod -Method 'Post' -Uri $url -Body ($data | ConvertTo-Json) -ContentType "application/json"
$hosts.result | Select name | Sort name | fl
$hosts.result.host

# Get script output
# получаем ID скрипта
$data = @{
    "jsonrpc"= "2.0";
    "method"= "script.get";
    "params"= @{
         "output" ="extend";
               };
    "auth"= $token.result;
    "id"= 1;
       }

$hosts = Invoke-RestMethod -Method 'Post' -Uri $url -Body ($data | ConvertTo-Json) -ContentType "application/json"
$hosts.result | select name, scriptid, command

# выполняем скрипт на хосте
$data = @{
    "jsonrpc"="2.0";
    "method"="script.execute";
    "params"=@{
       "scriptid"=1;
       "hostid"=10318;
    };
    "auth"=$token.result;
    "id"=1;
}

$hosts = Invoke-RestMethod -Method 'Post' -Uri $url -Body ($data | ConvertTo-Json) -ContentType "application/json"
$hosts.result
$hosts.result.value

