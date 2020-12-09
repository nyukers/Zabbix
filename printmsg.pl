#!/usr/bin/perl 
#File name: prnmsg.pl 

use IO::Socket; 
$iphost = $ARGV[0]; 
$textprn = $ARGV[1]; 
my $mysock = new IO::Socket::INET ( 
PeerAddr => $iphost, 
PeerPort => '9100', 
Proto => 'tcp',
) or die ('NETWORK ERROR: Could not create socket!');
print $mysock $textprn; 
close($mysock);
