#!/usr/bin/perl 
#File name: lcdmsg.pl 

use IO::Socket; 
$iphost = $ARGV[0]; 
$lcdprn = $ARGV[1]; 
my $mysock = new IO::Socket::INET ( 
PeerAddr => $iphost, 
PeerPort => '9100', 
Proto => 'tcp',
) or die ('NETWORK ERROR: Could not create socket! $!\n'); 
print $mysock "\@PJL RDYMSG DISPLAY = \"$lcdprn\"\n"; 
close($mysock);
