#!/usr/bin/perl

my ($TAGSEP) = (",");

my ($ME) = $0 =~ /.*\/(.*)/;

use SNMP;

use POSIX qw(strftime);

die "Usage: $0 <host> <port> <community>" if ($#ARGV < 2);

$sess = new SNMP::Session(

DestHost => "$ARGV[0]:$ARGV[1]",

Community => "$ARGV[2]",

UseNumeric => 1,

NonIncreasing => 1,

UseLongNames => 1,

Version => "2c",

Timeout => 8 * 1000000,

Retries => 2

);

error('create session', $sess->{ErrorStr}) if ($sess->{ErrorNum});

($ifInOctets, $ifDescr) = $sess->bulkwalk(0, 10, [['.1.3.6.1.2.1.2.2.1.10'],['.1.3.6.1.2.1.2.2.1.2']]);

error('bulkwalk [ifInOctets, ifDescr]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

($ifType, $ifAdmin) = $sess->bulkwalk(0, 10, [['.1.3.6.1.2.1.2.2.1.3'],['.1.3.6.1.2.1.2.2.1.7']]);

error('bulkwalk [ifType, ifAdmin]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

($ifInErrors) = $sess->bulkwalk(0, 10, [['.1.3.6.1.2.1.2.2.1.14']]);

error('bulkwalk [ifInErrors]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

($ifHCInOctets, $ifAlias) = $sess->bulkwalk(0, 10, [['.1.3.6.1.2.1.31.1.1.1.6'],['.1.3.6.1.2.1.31.1.1.1.18']]);

error('bulkwalk [ifHCInOctets, ifAlias]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

for $i (0..$#$ifInOctets) {

$json{ $$ifInOctets[$i]->iid } = {};

}

for $i (0..$#$ifDescr) {

if (exists( $json{ $$ifDescr[$i]->iid } )) {

$json{ $$ifDescr[$i]->iid }->{IFDESCR} = $$ifDescr[$i]->val;

$json{ $$ifDescr[$i]->iid }->{IFTAGS} = $TAGSEP . $$ifDescr[$i]->val . $TAGSEP;

}

}

for $i (keys %json) {

delete $json{$i} unless (exists( $json{$i}->{IFDESCR} ));

}

for $i (0..$#$ifType) {

if (exists( $json{ $$ifType[$i]->iid } )) {

$json{ $$ifType[$i]->iid }->{IFTAGS} .= "Type:" . $$ifType[$i]->val . $TAGSEP;

}

}

for $i (0..$#$ifAdmin) {

if (exists( $json{ $$ifAdmin[$i]->iid } )) {

$json{ $$ifAdmin[$i]->iid }->{IFTAGS} .= "AdminStatus:" . (

$$ifAdmin[$i]->val == 1 ? "up" :

$$ifAdmin[$i]->val == 2 ? "down" :

$$ifAdmin[$i]->val == 3 ? "testing" : $$ifAdmin[$i]->val ) . $TAGSEP

}

}

for $i (0..$#$ifInErrors) {

if (exists( $json{ $$ifInErrors[$i]->iid } )) {

$json{ $$ifInErrors[$i]->iid }->{IFTAGS} .= "Physical" . $TAGSEP;

}

}

for $i (0..$#$ifHCInOctets) {

if (exists( $json{ $$ifHCInOctets[$i]->iid } )) {

$json{ $$ifHCInOctets[$i]->iid }->{IFTAGS} .= "Counter64" . $TAGSEP;

}

}

for $i (0..$#$ifAlias) {

if (exists( $json{ $$ifAlias[$i]->iid } )) {

$alias = $$ifAlias[$i]->val;

$flag = quotemeta($ARGV[3]) if $ARGV[3];

if ($flag and $alias =~ s/^(.*)$flag\s*/$1/o) {

$alias =~ s/\s*$//o;

$json{ $$ifAlias[$i]->iid }->{IFTAGS} .= "FLAG" . $TAGSEP;

}

$json{ $$ifAlias[$i]->iid }->{IFALIAS} = $alias;

}

}

#

# Output in JSON format

#

print "{\"data\":[";

$first_data = 1;

while (($index, $data) = each %json) {

$first_data ? $first_data = 0 : print ",";

print "\n{\"{#IFINDEX}\":\"", $index, "\"";

while (($macro, $value) = each %$data) {

print ",\"{#", $macro, "}\":\"", $value, "\"";

}

print "}";

}

print "]}\n";

#

# Logging error to STDERR and exit

#

sub error {

printf STDERR "%6u:%s.000 $ME $ARGV[0]:$ARGV[1] %s failed: %s\n", $$, strftime("%Y%m%d:%H%M%S", localtime()), @_;

exit 1;

}
