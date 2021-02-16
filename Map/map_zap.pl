#!/usr/bin/perl
# Topology Discovery, lldp2dot for FTTB by SERGIUS, v2.6.1 beta
# Zabbix and stuff by flea
use lib "./libs";

# use strict;
# use warnings;
use POSIX;
use Net::SNMP;
use SNMP_Session;
use SNMP_util;
use Net::Ping;
use iptools;
use zapi;
use threads;
use threads::shared;

my $ping=Net::Ping->new();
my %lldpmapout = ();
my $mgmtvlans;

################################
my $snmpcommunity = "public";
my $map_name = "automap_test";
my $filename = "mapneato";
$zapi::height = 1200;
$zapi::width = 1600;
$zapi::zab_url="http://127.0.0.1/zabbix/",
$zapi::zab_user="bot",#с правами на создание карт и манипуляции с хостами
$zapi::zab_pass="passwd",
my $offset = 100; #Отступ от краев
##################################
my %edges = ();
my %edges2 = ();
my %database = ();
my %dev_mac = ();
my %snmplldpnei_hash = ();
my $i;
my $edgesid = 0;
my $edgesid2 = 0;


my $argc = scalar(@ARGV);
print "Для работы скрипта важно чтобы работал LLDP протокол на устройствах (свитчи\телефоны и т д)";
if($argc < 1){
	print "\nperl <this_script>.pl \"ZabbixGroupSwitch1\" \"ZabbixGroupSwitch2\" ...\n";
	print "Если что, для авторизации в Заббиксе надо прописать логин\пароль в libs/zapi.pm\n";
	exit 0;
}
zapi::InitZabApiHandle();

	print "\nGet hosts from zabbix...\n";
	my %hosts = zapi::GetHostAndAddressByGroup(@ARGV);
#	print Dumper(%hosts);
	foreach $iphost (keys %hosts)
		{
		my $snmpsession;
		my $snmperror;
		my $snmptemp;
		my $snmpsysobject;
		my $snmplocalmac;
		my $snmplocation;
		my $snmpsysname;
		my $snmpvid;
		my %snmptemp = ();	
		my $request;
		my $id;
		my $sysobject;
		my $localmac;
		my $syslocation;
		my $sysname;
		my %snmpvlans = ();
		my $vlanid;
		my $snmploopback;
		my $fw;

		$syslocation = "";
		$localmac = "";
		$uptime = "";
		$sysname = "";
		my $firmware = "";
		$sysobject = "";
		$network = "";
		$vlanid = "";
		my $serial = "";
		
		#print "get sysObjct.0 from $iphost...\n";

		my ($snmpsession, $snmperror) = Net::SNMP -> session(
		-timeout => 1,
		-retries => 1,
		-hostname => $iphost,
		-community => $snmpcommunity,
		-translate => [-timeticks => 0x0],
		-version => 2
		);

		#sysObject.0
		my $snmptemp = $snmpsession->get_request('.1.3.6.1.2.1.1.2.0');

		if (ref($snmptemp))
			{
			my %snmpsysobjectid = %{$snmptemp};

			foreach my $values (values %snmpsysobjectid)
				{$sysobjectid = $values;}
			#default
			$id = 0;
			# 1-99 tkd
			if($sysobjectid eq ".1.3.6.1.4.1.6486.800.1.1.2.2.4.1.1")
				{$id = 1;$sysobject = "Alcatel-Lucent OmniStack LS 6224";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.5")
				{$id = 2;$sysobject = "D-Link DES-3200-26";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.63.6")
				{$id = 3;$sysobject = "D-Link DES-3028";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.64.1")
				{$id = 4;$sysobject = "D-Link DES-3526";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.1")
				{$id = 5;$sysobject = "D-Link DES-3200-10";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.64.2")
				{$id = 6;$sysobject = "D-Link DES-3550";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.105.3")
				{$id = 7;$sysobject = "D-Link DES-3552";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.3")
				{$id = 8;$sysobject = "D-Link DES-3200-28";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.5.1")
				{$id = 9;$sysobject = "D-Link DES-3200-28-C1";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.2")
				{$id = 10;$sysobject = "D-Link DES-3200-18";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.4")
				{$id = 11;$sysobject = "D-Link DES-3200-28F";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.9.1")
				{$id = 12;$sysobject = "D-Link DES-3200-52";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.116.2")
				{$id = 13;$sysobject = "D-Link DES-1228/ME";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.75.7")
                                {$id = 14;$sysobject = "D-Link DES-1210-52";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.116.1")
				{$id = 15;$sysobject = "D-Link DES-1228/ME(old)";}



			# 100-999 agg
			if($sysobjectid eq ".1.3.6.1.4.1.6486.800.1.1.2.1.7.1.10")
				{$id = 100;$sysobject = "Alcatel-Lucent OmniSwitch 6850-U24X";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.70.8")
				{$id = 101;$sysobject = "D-Link DGS-3627G";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.101.1")
				{$id = 102;$sysobject = "D-Link DGS-3200-10";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.70.9")
				{$id = 103;$sysobject = "D-Link DGS-3612g";}

			if($sysobjectid eq ".1.3.6.1.4.1.207.1.4.149")
				{$id = 104;$sysobject = "Allied Telesis AT-9000/28SP";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.117.1.3")
				{$id = 105;$sysobject = "D-Link DGS-3120-24SC";}

			if($sysobjectid eq ".1.3.6.1.4.1.14988.1")
				{$id = 201;$sysobject = "Mikrotik";}
                        
			# 1000-9999 ups
			if($sysobjectid eq ".1.3.6.1.4.1.2254.2.4")
				{$id = 1000;$sysobject = "Delta GES102R202035";}

			if($sysobjectid eq ".1.3.6.1.4.1.935")
				{$id = 1001;$sysobject = "EngPower EP901RH";}

			# 10000-99999 core
			if($sysobjectid eq ".1.3.6.1.4.1.9.1.402")
				{$id = 10000;$sysobject = "Cisco 7606 Chassis";}
			}
			else
			{
			$id = "-1";
			print "fault, reason: wrong SNMP community or forbitten SNMP protocol ";
			}
		if($id eq 0){print "unknow net device $sysobjectid";}
		undef $snmptemp;
		if ($id >= 0)
			{
			#get MAC-adress
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.17.1.1.0");
			$localmac = $snmptemp -> {".1.3.6.1.2.1.17.1.1.0"};

			#get sysLocation.0
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.1.6.0");
			$syslocation = $snmptemp -> {".1.3.6.1.2.1.1.6.0"};
			#get sysName.0
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.1.5.0");
			$sysname = $snmptemp -> {".1.3.6.1.2.1.1.5.0"};

			# Take Loopback0 for aggregator
			if($id >= 100 && $id <= 999)
				{
				$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.14.1.1.0");
				$snmploopback = $snmptemp -> {".1.3.6.1.2.1.14.1.1.0"};
				#$iphost = $snmploopback;
				}

			#LLDP nei
				%snmplldpnei_hash = %{$snmpsession -> get_table(".1.0.8802.1.1.2.1.4.1.1.5")};
				my $snmpport;
				foreach $lldpneioid (keys %snmplldpnei_hash)
					{
					$lldpneioid =~ m/(\d{1,})(?=\.(\d{1,})$)/;
					if($id >=0 && $id <= 999)
						{
						$getport = ".1.3.6.1.2.1.31.1.1.1.1."."$&";
						$snmptemp = $snmpsession -> get_request("$getport");
						$portname = $snmptemp -> {"$getport"};
						$edges{$edgesid} = {
						'edgefrom'=>$localmac,
						'edgeto'=>$snmplldpnei_hash{$lldpneioid},
						'port'=>$portname,
						};
						$edgesid = $edgesid + 1;
						$lldpnei.= $portname."->".$snmplldpnei_hash{$lldpneioid}.",";
						}
					}
				if(defined($lldpnei))
					{
					chop $lldpnei;
					}



			# take firmware for D-Link DES-3200-26 ...
			if ($id == 2 || $id == 5 || $id == 9 || $id == 10 || $id == 11 )
				{
				$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.47.1.1.1.1.9.1");
				$fw = $snmptemp -> {".1.3.6.1.2.1.47.1.1.1.1.9.1"};
				}

			# take firmware for D-Link DES-3526 ...
			if ($id == 4)
				{
				$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.16.19.2.0");
				$fw = $snmptemp -> {".1.3.6.1.2.1.16.19.2.0"};
				}
			}

		if(!defined($fw))
			{
			$fw = "";
			}

		if($id >=0 )
			{
			#print "$iphost;";
			#print "$localmac;";
			#print "$syslocation;";
			#print "$vlanid;";
			#print "$sysname;";
			#print "$id;";
			#print "$sysobject;";
			#print "$fw;";

			if(!defined($lldpnei))
				{
				$lldpnei = "";
				}

			#print "$lldpnei\n\n";
			$dev_mac{mac}{$localmac}={
				'zab_hostid'=>$hosts{$iphost}{hostid},
				'ip' => $iphost,
				'sysname' => $sysname,
				'model' => $sysobject,
				'zabname' => $hosts{$iphost}{zab_name},
				'syslocation' => $syslocation,
			};
			$database{$iphost}={
			'localmac'=>$localmac,
			'syslocation'=>$syslocation,
			'vlanid'=>$vlanid,
			'sysname'=>$sysname,
			'id'=>$id,
			'zab_hostid'=>$hosts{$iphost}{hostid},
			'sysobject'=>$sysobject,
			'lldpnei'=>$lldpnei,
			'fw'=>$fw,
			};
			#print Dumper($database{$iphost});
			}

		undef $fw;
		undef $localmac;
		undef $syslocation;
		undef $vlanid;
		undef $sysname;
		undef $id;
		undef $sysobject;
		undef $lldpnei;
		}
	%hosts = (); 
#print Dumper(%database);
my $edgefrom;
my $edgefrom2;
my $edgeto;
my $edgeto2;
my $edge;
my $edge2;
my $port;
my $port2;

foreach $edge6(keys %edges)
	{
	$edgefrom6 = $edges{$edge6}{edgefrom};
	$edgeto6 = $edges{$edge6}{edgeto};
	$port6 = $edges{$edge6}{port};
	#print "$edge6 => $edgefrom6--$edgeto6;$port6\n";
	}

# delete full edges dublicate
foreach $edge3(keys %edges)
	{
	$edgefrom3 = $edges{$edge3}{edgefrom};
	$edgeto3 = $edges{$edge3}{edgeto};
	$port3 = $edges{$edge3}{port};
	if(defined($edgefrom3) & defined($edgeto3) & defined($port3))
		{
		foreach $edge4(keys %edges)
			{
			$edgefrom4 = $edges{$edge4}{edgefrom};
			$edgeto4 = $edges{$edge4}{edgeto};
			$port4 = $edges{$edge4}{port};
			if(defined($edgefrom4) & defined($edgeto4) & defined($port4))
				{			
				if($edgefrom3 eq $edgefrom4 & $edgeto3 eq $edgeto4 & $port3 eq $port4 & $edge3 ne $edge4)
					{
					delete $edges{$edge4};
					}
				}
			}
		}
	}

# combine edges and ports and delete dublicate
my %links = ();
foreach $edge(keys %edges)
	{
	my $port2;
	$edgefrom = $edges{$edge}{edgefrom};
	$edgeto = $edges{$edge}{edgeto};
	$port = $edges{$edge}{port};
	foreach $edge2(keys %edges)
		{
		$edgefrom2 = $edges{$edge2}{edgefrom};
		$edgeto2 = $edges{$edge2}{edgeto};
		if(defined($edgefrom))
			{
			if(defined($edgeto2))
				{
				if($edgefrom eq $edgeto2)
					{
					if($edgeto eq $edgefrom2)
						{
						$port2 = $edges{$edge2}{port};
						delete $edges{$edge2};
						}
					}
				}
			}
		}
	if (defined($edgefrom) & defined($edgeto))
		{
		if(defined($edge) & defined($edgefrom) & defined($edgeto) & defined($port) & defined($port2))
			{
	#		print "$edge => $edgefrom--$edgeto;$port;$port2\n";
			}
		if(!defined($port2))
			{
			$port2 = "";
			}
	
		$dev_mac{link}{$edgefrom}{$edgeto}= { portfrom => $port, portto => $port2,};
	
		$lldpmap.= "\"$edgefrom\" -- \"$edgeto\" [color=\"DimGray\",taillabel=\" $port\", headlabel=\"$port2\", labeldistance=\"2\", len=\"4\" ]\;\n";
		}
	}
foreach $iphost(keys %database)
	{
	$fw = $database{$iphost}{fw};
	$syslocation = $database{$iphost}{syslocation};
	$vlanid = $database{$iphost}{vlanid};
	$sysname = $database{$iphost}{sysname};
	$sysobject = $database{$iphost}{sysobject};
	$id = $database{$iphost}{id};	
	$localmac = $database{$iphost}{localmac};
	my @portmac = ();
#        print "\n\n$iphost\n"; 
	if($id >= 0 && $id <= 9999)
		{
		$label.="\"$database{$iphost}{localmac}\" [ label=\"IP:$iphost\\nModel:$sysobject\\nName:$sysname\\n$syslocation\", fillcolor=\"Gainsboro\", shape=\"$shape\", rankstep=\"10\" ]\;\n";
		}
	}


#print Dumper(%dev_mac);

open(lldp2dot,">mapdot.gv");
print lldp2dot "graph lldp2dot {\n\toverlap=scale;\n\tsplines=true;\n";
print lldp2dot "node [ shape=\"box\", fixedsize=\"false\", style=\"filled\", fillcolor=\"white\" ];\n";
my $lab = join(",",@ARGV);
print lldp2dot "graph [ fontname=\"Helvetica-Oblique\", fontsize=\"100\", label=\"$lab\", size=\"4,5\" ];\n";
print lldp2dot "edge [color=red];\n";
print lldp2dot $label;
print lldp2dot $lldpmap;
print lldp2dot "}";
close(lldp2dot);

# pdf

# print "dot ==> generation PDF...\n";
# `dot -Tpdf -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o mapdot.pdf`;

print "\nneato ==> generation PDF...\n";
`neato -Tpdf -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o $filename.pdf`;

# print "fdp ==> generation PDF...\n";
# `fdp -Tpdf -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o mapfdp.pdf`;

# svg

# print "dot ==> generation SVG...\n";
# `dot -Tsvg -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o mapdot.svg`;

 print "\nneato ==> generation SVG...\n";
 `neato -Tsvg -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=50 mapdot.gv -o $filename.svg`;

# print "fdp ==> generation SVG...\n";
# `fdp -Tsvg -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=50 mapdot.gv -o mapfdp.svg`;

print "Get Coord from SVG for zabbix\n";
CheatFromSVG();
print "Past in zabbix new map as '$map_name'\n";
zapi::DrawMap($map_name,%dev_mac);


sub CheatFromSVG {

open( FH, "$filename.svg" ) || die "couldn't open\n";

while ( <FH> ) {
    $data .= $_;
}


#print Dumper(%db);
my @pos = $data =~ m|node"><title>(?<mac>[0-9a-fx]+)<\/title>\s*<[^>]+cx="(?<x>.[\-0-9\.]+)"\s*cy="(?<y>[\-0-9\.]+)"|ig;
my ($minx,$miny,$maxx,$maxy,$x,$y,$dx,$dy) = (1000,1000,-1000,-1000,0,0,0,0);
for (my $i=0; $i < @pos; $i+=3) {
   $x = $pos[$i+1];
   $y = $pos[$i+2];

   $dev_mac{mac}{$pos[$i]}{x} = $x;
   $dev_mac{mac}{$pos[$i]}{y} = $y;

   if($x < $minx){$minx = $x;}
   if($y < $miny){$miny = $y;}
   if($x > $maxx){$maxx = $x;}
   if($y > $maxy){$maxy = $y;}

}
 $dx = $maxx - $minx;
 $dy = $maxy - $miny;
 my $coef = 1.0;
 if($dy > ($zapi::height-$offset*2)){
   $coef = ($zapi::height-$offset*2)/$dy;
 }
 #print "\n======($maxx,$maxy)=($minx,$miny)=>($dx,$dy,$coef)======================\n";
 my $ax=$minx;
 my $ay=$miny;
 #if($maxx<0){$ax=-$minx;}
 #if(abs($miny)>abs($maxy)){$ay=$miny;}
 for my $p (keys ($dev_mac{mac})){
   $x = $dev_mac{mac}{$p}{x};
   $dev_mac{mac}{$p}{x} = floor(($x - $ax) * $coef) + $offset;
   $y = $dev_mac{mac}{$p}{y};
   $dev_mac{mac}{$p}{y} = floor(($y - $ay) * $coef) + $offset;
  #printf("mac %s: x %f,nx %f|y %f,ny %f\n",$p,$x,$dev_mac{mac}{$p}{x},$y,$dev_mac{mac}{$p}{y});
 }
 $zapi::width = floor(($maxx-$ax)* $coef + $offset * 2);
 $zapi::height = floor(($maxy-$ay)* $coef + $offset * 2);
#  print Dumper($zapi::width); 
##print Dumper($dev_mac{mac});
 
#  return %dev_mac;
}

