#!/usr/bin/perl

$linux="snmpwalk -v 2c -c sunhose -O vQ ".$ARGV[0]." .1.3.6.1.2.1.47.1.1.1.1.13";

@model = `$linux`;

chomp(@model);

@model = grep {! $tmp{$_}++ } @model;

$linux="snmpwalk -v 2c -c sunhose -O vQ ".$ARGV[0]." .1.3.6.1.2.1.47.1.1.1.1.11";

@sn = `$linux`;

chomp(@sn);

@sn = grep {! $tmp{$_}++ } @sn;

print "\t Inventory items of $ARGV[0] (SNMPv2):\n";
printf ("\t%-40s\n", "--------------------------------------------------------");

printf("\t\t%-20s | \t", 'Item');

printf("%-20s\n", 'Serial');


printf ("\t%-40s\n", "--------------------------------------------------------");

for $i (0..$#model) {

$model[$i]=~ s/\"//g;

$sn[$i]=~ s/\"//g;

printf("\t\t%-20s | \t", $model[$i]);

printf("%-20s\n", $sn[$i]);

printf ("\t%-40s\n", "--------------------------------------------------------");

}
