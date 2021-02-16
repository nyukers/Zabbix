===INSTALL===
1. Перекреcтиться
2. Подтянуть паровоз пакетов
 (*Centos 7)
 yum install graphviz perl-JSON-PP perl-libwww-perl perl-version gcc net-snmp-perl net-snmp net-snmp-devel perl-SNMP_Session perl-CPAN perl-YAML

3. Установить perl модуль для работы с ZABBIX API

3.1. Взять готовый  пакет
  https://copr-be.cloud.fedoraproject.org/results/ksyz/el7-perl/epel-7-x86_64/
в папке
  *perl-Net-Zabbix

   wget https://copr-be.cloud.fedoraproject.org/results/ksyz/el7-perl/epel-7-x86_64/00146740-perl-Net-Zabbix/perl-Net-Zabbix-2.00-1.el7.centos.noarch.rpm
   yum localinstall perl-Net-Zabbix-2.00-1.el7.centos.noarch.rpm

3.2. Или собираем под себя https://github.com/ksyz/Net-Zabbix

 cd /usr/src/
 wget https://codeload.github.com/ksyz/Net-Zabbix/zip/v2 -O ZabApi.zip
 unzip ZabApi.zip
 cd Net-Zabbix-2/
 perl Makefile.PL
 make install

4. Настраиваем  map_zab.pl
  my $snmpcommunity = "public"; #Комьюнити
  my $map_name = "automap_test";#Имя карты в заббиксе
  my $filename = "mapneato";    #имя файла карты
  $zapi::height = 1200;         #габариты желательные, лишние откромсается
  $zapi::width = 1600;

  $zapi::zab_url="http://127.0.0.1/zabbix/",  # Адрес заббикса, по хорошему ему доступны устройства для сбора статы, так что лучше с него и запускать
  $zapi::zab_user="bot";               #Учетка с правами манипуляции с картами сетей и манипуляции с хостами
  $zapi::zab_pass="passwd"; #Пароль
  my $offset = 100;  #Отступ от краев карты

===USE===
  perl map_zab.pl <Имя группы в заббиксе свитчей> <Имя группы в заббиксе шлюзов> <Имя группы в заббиксе устройств с LLDP>
В итоге получаем два файла pdf, svg в которых graphiz отрисовал примерную карту, а так же получаем в заббиксе карту(или не получаем)

Кроме как рисовать карту скрипт так же переименовывает автоматически хосты, при условии если ip совпадает с именем хоста, иначе не трогает ничего

===PRODUCTION===
Шутка, нафиг костыли в продакшн. Это скорее для наглядности и в документацию на один раз.

===HOW IT WORKS===
Для работы важно чтобы устройства поддерживали протокол LLDP и он был верно настроен, если устройство видит соседей, то скрипт тоже подтянет данные.

===FDB===
Думал прикруть еще определение соседей по FDB таблицам для не поддерживающих LLDP устройств(cisco\mikrotik и прочие), но посмотрев зоопарк OIDов
решил отложить(да и не надежно это, надо пинговать броадкастить со всех сторон, чтобы правильно увидели друг друга).
И на будущее поставил галочку насчет планирования сети, что надо учитывать, либо все CDP, либо все LLDP, не надо смешивать :(

PS До этого перл даже пальцем не тыкал, первый забег, критика и советы как лучше приветствуются.

