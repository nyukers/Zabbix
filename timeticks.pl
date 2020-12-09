#!/usr/bin/perl

use strict;

use warnings;

use diagnostics;


use Net::SNMP; #Подключение библиотеки для работы с SNMP

my $snmp_host = $ARGV[0];
my $snmp_community = $ARGV[1];

#my $snmp_community = 'sunhose';

my $snmp_oid = '1.3.6.1.2.1.1.3.0';

my $snmp_session = Net::SNMP->session(

-hostname=>$snmp_host,

-community=>$snmp_community,

-version=>2,

) or die ('Its doesnt connected!');


my $result = $snmp_session->get_request(

-varbindlist=>[$snmp_oid],

) or die ('Its doesnt work!');


print "$result->{$snmp_oid}\n";

$snmp_session->close;
