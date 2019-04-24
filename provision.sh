#!/bin/bash

echo params= $0 $1 $2
#addr=192.168.1.96

if [ "$1" == "" ]
then
  echo addr not set exiting
  exit
else
  addr=$1
fi

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}
function gr_reboot {
 echo -e "\nsend reboot"
result=$(wget -qO- http://$addr/cgi-bin/api-sys_operation --keep-session-cookies --save-cookies cookies.txt --post-data="request=REBOOT&sid=$sid" )

echo -e "result: $result\n"
}

function gr_login {
val=admin
#val=123456
echo -e "login:"
wget -O- http://$addr/cgi-bin/dologin  --keep-session-cookies --save-cookies cookies.txt --header="Referer: http://$addr/" --post-data="username=admin&password=$val" >login.txt
#&2>/dev/null

#cat st1
sid=$(cat login.txt| awk '{print $7}'|sed 's/[",]//g')
echo -e sid=$sid
}

function gr_info {
echo -e "get info:"
result=$(wget -qO- http://$addr/cgi-bin/api.values.get --load-cookies cookies.txt --post-data="request=vendor_fullname:P35:P47:P64:PAccountRegistered1:P64:P146&sid=$sid" )

echo -e "result: $result\n"
}

#avoid non urlencoded string val
function gr_set {
echo -e "setting $param:$val"
result=$(wget -qO- http://$addr/cgi-bin/api.values.post --load-cookies cookies.txt --post-data="sid=$sid&$param=$val" )

echo -e "result: $result\n"
}

function gr_change_password {
echo -e "setting $param:$val"
result=$(wget -qO- http://$addr/cgi-bin/api-change_password --load-cookies cookies.txt --header="Referer: http://$addr/" --post-data="sid=$sid&olduser=&P196=&:confirmUserPwd=&oldadmin=admin&P2=$val&:confirmAdminPwd=$val" )

echo -e "result: $result\n"
}

gr_login
if [ "$sid" == "" ]
then
  echo auth fail
  exit
fi

gr_info

if [ "$2" == "" ]
then
  echo param 2 not set exiting
  exit
else

# Account 1:
# Account Active. 0 - No, 1 - Yes. Default value is 0
# Number: 0, 1
param=P271 
val=1
gr_set

echo Account Name
param=P270 
val=$2
gr_set

echo SIP Server
param=P47 
val=192.168.1.1
gr_set

echo SIP User ID
param=P35 
val=$2
gr_set

echo SIP Authenticate ID
param=P36 
val=$2
gr_set

if [ "$3" == "" ]
then
  echo param 3 not set, no SIP pass
else
    echo SIP Authenticate Password
    param=P34 
    val=$3
    gr_set
fi

echo "Name (Display Name, e.g., John Doe)"
param=P3 
val=$2
gr_set

echo Host name, DHCP option
param=P146
val=Grandstream-$2
gr_set

echo Time Zone
param=P64
val=MSK-3
gr_set

echo Time Display Format. 0 - 12 Hour, 1 - 24 Hour
param=P122
val=1
gr_set

echo Date Display Format
param=P102
val=2
gr_set

echo Download Firmware File
# Firmware Upgrade Via. 0 - TFTP Upgrade,  1 - HTTP Upgrade, 2 - HTTPS Upgrade. Default is 1
param=P6767
val=1
gr_set

echo Firmware Server Path
param=P192
val=192.168.1.1/grandstream
gr_set

echo NTP Server
param=P30
val=192.168.1.1
gr_set

echo Display Language.
param=P1362
val=ru
gr_set

echo admin Password
param=admin
val=admin
gr_change_password

fi

if [ "$3" == "reboot" ]
then
 gr_reboot
fi

if [ "$4" == "reboot" ]
then
 gr_reboot
fi
