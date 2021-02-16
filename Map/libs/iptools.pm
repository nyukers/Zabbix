package iptools;
require Exporter;
@ISA=qw(Exporter);

$EXPORT[0]=qw(IPtodec);	#convert IP to decimal
$EXPORT[1]=qw(IPtodecex);	#convert IP to decimal
$EXPORT[2]=qw(dectoIP);	#convert decimal to IP
$EXPORT[3]=qw(chmask);	#check mask
$EXPORT[4]=qw(chIP);		#check IP

####################################################################
sub IPtodec  #return IPdecimal if OK, -1 if IP bad, arguments (ipaddress)
{

my $mIP=$_[0];
my @atemp;
my $IPdecimal;

 #split IP to array
 @atemp=split ('[.]',$mIP);
 
 #check IP
 if (chIP($mIP)== -1) {return -1;}
 
 
 #convert
 $IPdecimal= $atemp[0]*16777216+$atemp[1]*65536+$atemp[2]*256+$atemp[3];

return $IPdecimal;
}

##################################################################
sub IPtodecex #return IPdecimal and IP count is OK, -1 if IP bad, -2 if mask bad, arguments (ipaddress,mask)
{

my $mIP=$_[0];
my $mMask=$_[1];
my @atemp;
my $maskdec;
my $IPdecimal;

 #solit IP to array
 @atemp=split ('[.]',$mIP);
 
 #check IP
 if(chIP($mIP)== -1){return -1;}
 
 #convert IP to dec
 $IPdecimal= $atemp[0]*16777216+$atemp[1]*65536+$atemp[2]*256+$atemp[3];
 
 #convert Mask to decimal
 @atemp=split '[.]',$mMask;
 
 #check mask
 if(chmask($mMask)== -1){return -2;}
 #convert mask to dec
 $maskdec = $atemp[0]*16777216+$atemp[1]*65536+$atemp[2]*256+$atemp[3];
 foreach(@atemp){$_=255-$_;}
 $IPcount=$atemp[0]*16777216+$atemp[1]*65536+$atemp[2]*256+$atemp[3]+1;
 $IPdecimal=int($IPdecimal/$IPcount)*$IPcount;


return ($IPdecimal,$IPcount);
}

##############################################################
sub dectoIP       #return IP string if OK, -1 if not OK, arguments(ipaddress in decimal)
{
my $IPdecimal=$_[0];
my $temp;
my $IPhost;
if($IPdecimal>4294967295){return -1;}

     # convert IP decimal to oct
     $IPhost=int($IPdecimal/16777216);
     $temp=$IPdecimal%16777216;
     $IPhost=$IPhost.".".int($temp/65536);
     $temp=$IPdecimal%65536;
     $IPhost=$IPhost.".".int($temp/256);
     $IPhost=$IPhost.".".$temp%256;    	

return $IPhost;
}
##########################################################
sub chmask  #return 0 if OK, 1 if 255.255.255.255, -1 if invalid,arguments(mask)
{
my $mask=$_[0];
my @atemp;
  #split mask to array
  @atemp=split ('[.]',$mask);
  #check mask
  foreach(@atemp)
       {
          if(($_ >255) or ($_ <0)){ return -1; }
       }
  
  if($mask eq "255.255.255.255"){return 1;}
           
  return 0;
}

###########################################################
sub chIP   #return 0 if OK, -1 if invalid,arguments(ipaddress)
{
 my @atemp;
 my $IP=$_[0];
  #split IP to array
  @atemp=split ('[.]',$IP);
  #check IP
  foreach(@atemp)
       {
          if(($_ >255) or ($_ <0)){ return -1; }
       }
return 0;
}