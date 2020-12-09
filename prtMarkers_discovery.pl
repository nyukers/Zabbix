#!/usr/bin/perl

use strict;
use warnings;
use SNMP;
use POSIX qw(strftime);

use constant TAGSEP => ",";

die "Usage: $0 <host> <port> <community> [regex]" if scalar @ARGV < 3;

my $ME      = $0 =~ /.*\/(.*)/;
my $REGEX   = $ARGV[3] ? $ARGV[3] : undef;

my $DEBUG   = 0;
my $tmp     = undef;

my %json    = ();

debug('START');

my $sess    = new SNMP::Session(
    DestHost        => "$ARGV[0]:$ARGV[1]",
    Community       => "$ARGV[2]",
    UseNumeric      => 1,
    NonIncreasing   => 1,
    UseLongNames    => 1,
    Version         => "2c",
    Timeout         => 8 * 1000000,
    Retries         => 1
);
error('new SNMP::Session', $sess->{ErrorStr}) if ($sess->{ErrorNum});

my ($prtMarkerDesc, $prtMarkerType, $prtMarkerColor) = ();

($prtMarkerDesc) = $sess->bulkwalk(0, 10, ['Printer-MIB::prtMarkerSuppliesDescription.1']);
#($prtMarkerDesc) = $sess->bulkwalk(0, 10, ['.1.3.6.1.2.1.43.11.1.1.6.1']);
error('bulkwalk [prtMarkerSuppliesDescription]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

debug('GET prtMarkerSuppliesDescription');

($prtMarkerType) = $sess->bulkwalk(0, 10, ['Printer-MIB::prtMarkerSuppliesType.1']);
#($prtMarkerType) = $sess->bulkwalk(0, 10, ['.1.3.6.1.2.1.43.11.1.1.5.1']);
error('bulkwalk [prtMarkerSuppliesType]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

debug('GET prtMarkerSuppliesType');

($prtMarkerColor) = $sess->bulkwalk(0, 10, ['Printer-MIB::prtMarkerColorantValue.1']);
#($prtMarkerColor) = $sess->bulkwalk(0, 10, ['.1.3.6.1.2.1.43.12.1.1.4.1']);
error('bulkwalk [prtMarkerColorantValue]', $sess->{ErrorStr}) if ($sess->{ErrorNum});

debug('GET prtMarkerColorantValue');

for (@$prtMarkerDesc) {
    $tmp = $_->val;
    $tmp =~ s/\000//g;
    $json{ $_->iid }->{MARKER_DESCR} = $tmp;
    $json{ $_->iid }->{MARKER_TAGS} = TAGSEP . $tmp . TAGSEP;
}

for (@$prtMarkerType) {
    $json{ $_->iid }->{MARKER_TAGS} .= "Type:" . $_->val . TAGSEP if exists $json{ $_->iid } and $_->val =~ /^\d+$/;
}

for (@$prtMarkerColor) {
    $tmp = $_->val;
    $tmp =~ s/\000//g;
    $json{ $_->iid }->{MARKER_TAGS} .= "Color:" . $tmp . TAGSEP if exists $json{ $_->iid };
}

#
# Regex filter
#
if ($REGEX) {
    for (keys %json) {
        delete $json{$_} unless $json{$_}->{MARKER_TAGS} =~ /$REGEX/o;
    }
}

debug('READY to output JSON format');

#
# Output in JSON format
#
my ($index, $data, $macro, $value) = ();
print '{"data":[';
my $this_first_etirashion = 1;
while (($index, $data) = each %json) {
    if ($this_first_etirashion == 1) {
        $this_first_etirashion = 0;
    } else {
        print ',';
    }
    print "{",'"{#MARKER_INDEX}":"', $index, '"';
    while (($macro, $value) = each %$data) {
        print ",",'"{#', $macro, '}":"', $value, '"';
    }
    print "}";
}
print "]}\n";

debug('{"data":[');
while (($index, $data) = each %json) {
    debug("{".'"{#MARKER_INDEX}":"'.$index.'"');
    while (($macro, $value) = each %$data) {
        debug(",".'"{#'.$macro.'}":"'.$value.'"');
    }
    debug("},");
}
debug("]}");

debug('FINISH');

#
# Logging to STDERR and exit
#
sub error {
    printf STDERR "%6u:%s.000 $ME $ARGV[0]:$ARGV[1] %s failed: %s\n", $$, strftime("%Y%m%d:%H%M%S", localtime()), @_;
    exit 1;
}

sub debug {
    printf STDERR "%6u:%s.000 $ME $ARGV[0]:$ARGV[1] %s\n", $$, strftime("%Y%m%d:%H%M%S", localtime()), @_ if $DEBUG;
}

