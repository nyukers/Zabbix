#!/usr/bin/perl

$linux="snmpwalk -v 2c -c ".$ARGV[1]." -O vQ ".$ARGV[0]." .1.3.6.1.2.1.1.5.0";

@model = `$linux`; chomp(@model);@model = grep {! $tmp{$_}++ } @model;

$linux="snmpwalk -v 2c -c ".$ARGV[1]." -O vQ ".$ARGV[0]." .1.3.6.1.2.1.1.3.0";

@uptime = `$linux`; chomp(@uptime);

$linux="snmpwalk -v 2c -c ".$ARGV[1]." -O vQ ".$ARGV[0]." .1.3.6.1.2.1.16.19.2.0";

@ios_ver = `$linux`; chomp(@ios_ver);

$linux="snmpwalk -v 2c -c ".$ARGV[1]." -O vQ ".$ARGV[0]." .1.3.6.1.4.1.9.9.109.1.1.1.1.5.1";

@load_cpu = `$linux`; chomp(@load_cpu);

$linux="snmpwalk -v 2c -c ".$ARGV[1]." -O vQ ".$ARGV[0]." .1.3.6.1.2.1.47.1.1.1.1.13.1";

@pid_router = `$linux`; chomp(@pid_router);

$linux="snmpwalk -v 2c -c ".$ARGV[1]." -O vQ ".$ARGV[0]." .1.3.6.1.2.1.47.1.1.1.1.2.1001";

@pid_switch = `$linux`; chomp(@pid_switch);



@uptime = grep {! $tmp{$_}++ } @uptime; print "\t\t Cisco Device Information (SNMPv2)\n";

printf ("\t%-40s\n Hostname",

"--------------------------------------------------------");

for $i

(0..$#model) { $model[$i]=~ s/\"//g; $sn[$i]=~ s/\"//g;

printf("\t\t%-20s\n Uptime(d:h:m:s.ms)", $model[$i]);

printf("\t%-20s\n IOS version", $uptime[$i]);

printf("\t\t%-20s\n CPU load", $ios_ver[$i]);

printf("\t\t%-20s\n ProductID router",$load_cpu[$i]);

printf("\t%-20s\n ProductID switch",$pid_router[$i]);

printf("\t%-20s\n",$pid_switch[$i]);

printf ("\n\t%-40s\n",

"--------------------------------------------------------");

}
