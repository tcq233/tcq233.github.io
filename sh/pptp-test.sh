#!/usr/bin/env bash
# Description: PPTP CentOS7
# Edit by https://www.cnblogs.com/coveredwithdust/p/7967036.html
# Edit by https://blog.shuspieler.com/756/
# Copyright (C) 2020 feeday <0xf197@gmail.com>

function ups(){
rm -f /etc/ppp/ip-up
cat >>/etc/ppp/ip-up<<EOF
#!/bin/bash
# This file should not be modified -- make local changes to
# /etc/ppp/ip-up.local instead
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH
LOGDEVICE=$6
REALDEVICE=$1
[ -f /etc/sysconfig/network-scripts/ifcfg-${LOGDEVICE} ] && /etc/sysconfig/network-scripts/ifup-post --realdevice ${REALDEVICE} ifcfg-${LOGDEVICE}
/etc/ppp/ip-up.ipv6to4 ${LOGDEVICE}
[ -x /etc/ppp/ip-up.local ] && /etc/ppp/ip-up.local "$@"
echo "****************************************************" >> /var/log/VPN-${1}.log
echo "username: $PEERNAME" >> /var/log/VPN-${1}.log
echo "clientIP: $6" >> /var/log/VPN-${1}.log
echo "device: $1" >> /var/log/VPN-${1}.log
echo "vpnIP: $4" >> /var/log/VPN-${1}.log
echo "assignIP: $5" >> /var/log/VPN-${1}.log
echo "logintime: `date -d today +%F_%T`" >> /var/log/VPN-${1}.log
EOF
}

function downs(){
rm -f /etc/ppp/ip-down
cat >>/etc/ppp/ip-down<<EOF
#!/bin/bash
# This file should not be modified -- make local changes to
# /etc/ppp/ip-down.local instead
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH
LOGDEVICE=$6
REALDEVICE=$1
/etc/ppp/ip-down.ipv6to4 ${LOGDEVICE}
[ -x /etc/ppp/ip-down.local ] && /etc/ppp/ip-down.local "$@"
/etc/sysconfig/network-scripts/ifdown-post --realdevice ${REALDEVICE} \
    ifcfg-${LOGDEVICE}
echo "downtime: `date -d today +%F_%T`" >> /var/log/VPN-${1}.log
echo "bytes sent: $BYTES_SENT B" >> /var/log/VPN-${1}.log
echo "bytes received: $BYTES_RCVD B" >> /var/log/VPN-${1}.log
sum_bytes=$(($BYTES_SENT+$BYTES_RCVD))
sum=`echo "scale=2;$sum_bytes/1024/1024"|bc`
echo "bytes sum: $sum MB" >> /var/log/VPN-${1}.log
ave=`echo "scale=2;$sum_bytes/1024/$CONNECT_TIME"|bc`
echo "average speed: $ave KB/s" >> /var/log/VPN-${1}.log
echo "connect time: $CONNECT_TIME S" >> /var/log/VPN-${1}.log
echo "****************************************************" >> /var/log/VPN-${1}.log
EOF
}

function pptp(){
cd /home
yum install -y ppp 
yum install net-tools.x86_64 nmap wget
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum repolist
yum -y update
yum install -y pptpd 
yum install bc
rm -f epel-release-latest-7.noarch.rpm

serverip=$(ifconfig -a |grep -w "inet"| grep -v "127.0.0.1" |awk '{print $2;}')
printf "(Default server IP: \e[33m$serverip\e[0m):"
read serveriptmp
if [[ -n "$serveriptmp" ]]; then
    serverip=$serveriptmp
fi

rm -f /etc/pptpd.conf
cat >>/etc/pptpd.conf<<EOF
#ppp /usr/sbin/pppd
option /etc/ppp/options.pptpd
#debug
# stimeout 10
#noipparam
logwtmp
#vrf test
#bcrelay eth1
#delegate
#connections 100
localip 192.168.0.1
remoteip 192.168.0.214,192.168.0.245
EOF

rm -f /etc/ppp/options.pptpd
cat >>/etc/ppp/options.pptpd<<EOF
# Authentication
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
ms-dns 8.8.4.4
ms-dns 8.8.8.8
proxyarp
lock
nobsdcomp 
novj
novjccomp
nologfd
logfile /var/log/pptpd.log
EOF

username="feeday.io"
echo "Please input VPN username:"
printf "(Default VPN username: \e[33m$username\e[0m):"
read usernametmp
if [[ -n "$usernametmp" ]]; then
    username=$usernametmp
fi

randstr() {
    index=0
    str=""
    for i in {a..z}; do arr[index]=$i; index=$(expr ${index} + 1); done
    for i in {A..Z}; do arr[index]=$i; index=$(expr ${index} + 1); done
    for i in {0..9}; do arr[index]=$i; index=$(expr ${index} + 1); done
    for i in {1..10}; do str="$str${arr[$RANDOM%$index]}"; done
    echo $str
}

password=$(randstr)
printf "Please input \e[33m$username\e[0m's password:\n"
printf "(Default password is \e[33m$password\e[0m): "
read passwordtmp
if [[ -n "$passwordtmp" ]]; then
    password=$passwordtmp
fi

rm -f /etc/ppp/chap-secrets
cat >>/etc/ppp/chap-secrets<<EOF
# Secrets for authentication using CHAP
# client     server     secret               IP addresses
$username          pptpd     $password               *              *
EOF

rm -f /etc/sysctl.conf
cat >>/etc/sysctl.conf<<EOF
net.ipv4.ip_forward=1
EOF

sysctl -p

rm -f /usr/lib/firewalld/services/pptpd.xml
touch /usr/lib/firewalld/services/pptpd.xml
cat >>/usr/lib/firewalld/services/pptpd.xml<<EOF
<?xml version="1.0" encoding="utf-8"?>

<service>

       <short>pptpd</short>

       <description>PPTP</description>

       <port protocol="tcp" port="1723"/>

</service>
EOF

systemctl start firewalld.service
firewall-cmd --permanent --zone=public --add-service=pptpd
firewall-cmd --add-masquerade

firewall-cmd --permanent --zone=public --add-port=47/tcp
firewall-cmd --permanent --zone=public --add-port=1723/tcp

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p gre -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p gre -j ACCEPT

ethlist=$(ifconfig | grep ": flags" | cut -d ":" -f1)
eth=$(printf "$ethlist\n" | head -n 1)
if [[ $(printf "$ethlist\n" | wc -l) -gt 2 ]]; then
    echo ======================================
    echo "Network Interface list:"
    printf "\e[33m$ethlist\e[0m\n"
    echo ======================================
    echo "Which network interface you want to listen for ocserv?"
    printf "Default network interface is \e[33m$eth\e[0m, let it blank to use default network interface: "
    read ethtmp
    if [ -n "$ethtmp" ]; then
        eth=$ethtmp
    fi
fi

firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i ppp+ -o $eth -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i $eth -o ppp+ -j ACCEPT
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o $eth -j MASQUERADE -s 192.168.0.0/24

mkdir /var/log/pptpdlog
#rm -f /etc/ppp/ip-up
#rm -f /etc/ppp/ip-down
#cd /etc/ppp/
#curl http://feeday.github.io/sh/ip-up -O
#curl http://feeday.github.io/sh/ip-down -O

firewall-cmd --reload
systemctl restart pptpd

printf "
IP user/password :
ServerIP: \e[33m$serverip\e[0m
username: \e[33m$username\e[0m
password: \e[33m$password\e[0m
"
nmap localhost
}
echo "PPTP: modprobe ppp-compress-18 && echo ok"
echo "------------------------------------------------------------"
echo 'PPTP Server By Feeday:'
echo "1) Test Host Network Server " 
echo "2) PPTP-Install" 
echo "3) PPTP-INFO" 
echo "4) Restart" 
echo "q) Exit!"
echo "------------------------------------------------------------"
read -p ":" cof

case $cof in      
	1)   
		curl -Lso- http://feeday.github.io/sh/host.sh | bash
	;;	
	2)   
		pptp
	;;
	3)
		cat /var/log/VPN-ppp0.log
	;;	
	4) 
		systemctl restart pptpd
                nmap localhost
        ;;	 
        q)
		exit
	;;  
	*)
		echo 'Input Error'
		exit
	;; 	
esac   
