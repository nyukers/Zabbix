use strict;
use warnings;

#use Data::Dumper;
#use Socket;
use FindBin qw($RealBin);
use lib "$RealBin/../lib";

use Net::Zabbix;

package zapi;
{
use Socket;
use Data::Dumper;
##
##%hosts_with_ip = GetHostAndAddressByGroup("Zabbix Group1","Zabbix Group2",...)
##
	our $width=1920;
	our $height=1080;
        our $zab_url="http://127.0.0.1/zabbix/",
        our $zab_user="bot",
        our $zab_pass="password",

my $z;

sub InitZabApiHandle{
	$z = Net::Zabbix->new(
                url =>$zab_url,
                username =>$zab_user,
                password =>$zab_pass,
                verify_ssl => 0,
                debug => 0,
                trace => 0,
                );


}
###Возвращает ID иконки
sub GetIcon{
 	my($z,$icon) = @_;
	my $req = $z->raw_request(
		"image","getObjects",{
    			'name' => $icon,
			}
  		);
	my $id = -1;
	for my $i (@{$req->{result}}) {
  		$id = $i->{imageid};
	}

	return $id;
}


sub ClearMap{
	my $mapname = $_[0];
	my $req = $z->get("map", {
                output => "sysmapid",
                filter => { name =>  $mapname  },
                }
        );
	
	my @i = (@{$req->{result}});
	if($i[0]->{sysmapid}){
		my @id = [ $i[0]->{sysmapid} ];
	
		$z->raw_request(
        	        "map","delete", (@id) );
	};

}
sub NeedRename{
	my $cnt = scalar(@_);
	if($cnt){
		my $id = $_[0]->{zab_hostid};
		my $sysname = $_[0]->{sysname};
		my $ip = $_[0]->{ip};
		my $zabname = $_[0]->{zabname};
		my $locate = $_[0]->{syslocate};
#		print Dumper(@_);
		if(($ip eq $zabname || $zabname eq "") && $sysname){
			#print "Rename $ip to $sysname\n";
			my $req = $z->update("host", {
					hostid=>$id,
					name=>$sysname
                		}
	        		);
			print "\n~Rename from $zabname to $sysname\n";
			$zabname = $sysname;
		}
		return $zabname;
	}
	return undef;
}
sub DrawMap{
	my ($mapname,%db) = @_;
	my $iconSW         = "Switch_(64)";
##########Init map#############
	ClearMap($mapname);
	#print Dumper($mapid);
#############################
	my $iSW = GetIcon($z,$iconSW);

#	print Dumper(%db);
	my @elems = ();
	my @links = ();
	my $i = 0;
	
	foreach my $mac(keys ($db{mac})){
	  #print Dumper($db{mac}{$mac});
	  $i++;
	  $db{i}{$mac}=$i;
	  my $model = $db{mac}{$mac}{model}; 
	  $db{mac}{$mac}{name_on_map} = NeedRename($db{mac}{$mac});
	  print "=>$db{mac}{$mac}{sysname},$model,  $db{mac}{$mac}{x} x $db{mac}{$mac}{y} \n";
	  my $e = {label=>"$model\n{HOST.NAME}",x => $db{mac}{$mac}{x}, y=> $db{mac}{$mac}{y},elementid => $db{mac}{$mac}{zab_hostid},elementtype=>0,iconid_off=>$iSW,selementid=>$i };
	  push @elems,$e;
	}
##	print Dumper(@elems);
	foreach my $link(keys ($db{link})){
	  foreach my $o (keys $db{link}{$link}){ 
		my $f = $db{link}{$link}{$o};
		#print Dumper($f);
		my $d_from = $db{i}{$link};
		#print Dumper( $db{i}{$link});
		my $d_to = $db{i}{$o};
		my $p_from =$f->{portfrom};
		my $p_to = $f->{portto};
		my $l_from = $db{mac}{$link}->{name_on_map};
		my $l_to = $db{mac}{$o}->{name_on_map};
          	if($d_from && $d_to){
			my $label = sprintf("%s(%s)\n%s(%s)",$l_from,$p_from,$l_to,$p_to);
			my $e = {selementid1 => $d_from,selementid2 => $d_to,label => $label };
          		push @links,$e;
		}
	  }
        }

        my $req = $z->create("map", {

             width => $width ,
             height => $height ,

             label_format => 1,
	     label_type_host => 0,
	     label_type_image => 0,
		
             name =>  $mapname ,
		selements => [@elems],
    		links => [@links],
           }
           );

	#print Dumper(@links);
}

sub GetHostAndAddressByGroup{
        my %host = ();
        my $groups = ();

        @$groups = @_;
        my $gr = $z->get("hostgroup", {
                output => "extend",
                filter => { name =>  $groups  },
                }
        );

        for my $h (@{$gr->{result}}) {
                my $grid =  $h->{groupid};
                my $entry =  $z->get("host", {
                                output => "extend",
                                groupids=> $grid,
                                selectInterfaces => Net::Zabbix::OUTPUT_EXTEND
                                }
                        );
                for my $e (@{$entry->{result}}) {
                        #print Dumper($hostname);
                        my $smtp = $e->{snmp_available};
			my $hostname = $e->{name};

                        if($smtp == '1'){
                                my $id = $e->{hostid};
                                my $if = $e->{interfaces};
                                foreach my $i (@$if){
                                        if ($i->{main} eq '1' && $i->{type} eq Net::Zabbix::HOST_INTERFACE_TYPE_SNMP) {
                                                my $iphost;
						if($i->{useip} eq '1' ){
                                                        $iphost = $i->{ip};
                                                        $host{$iphost}{hostid}=$id;
                                                }else{
							$iphost=inet_ntoa(inet_aton($i->{dns}));
                                                        $host{$iphost}{hostid}=$id;
                                                }
						$host{$iphost}{zab_name} = $hostname;

                                        }
                                }
                        }
                }

        }
        return %host;
}


1;





}





1;
