#!/usr/bin/env bash
# Description: PPTP Centos7
# Edit by https://www.cnblogs.com/coveredwithdust/p/7967036.html
# Copyright (C) 2020 feeday <0xf197@gmail.com>

yum install -y ppp
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum repolist
yum -y update
yum install -y pptpd nmap
yum install net-tools.x86_64 


serverip=$(ifconfig -a |grep -w "inet"| grep -v "127.0.0.1" |awk '{print $2;}')
printf "(Default server IP: \e[33m$serverip\e[0m):"
read serveriptmp
if [[ -n "$serveriptmp" ]]; then
    serverip=$serveriptmp
fi


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

username="feeday.io"
echo "Please input VPN username:"
printf "(Default VPN username: \e[33feeday.io\e[0m): "
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
printf "Default password is \e[33m$password\e[0m, let it blank to use default password: "
read passwordtmp
if [[ -n "$passwordtmp" ]]; then
    password=$passwordtmp
fi

clear

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

touch /usr/lib/firewalld/services/pptpd.xml
cat >>/usr/lib/firewalld/services/pptpd.xml<<EOF
<?xml version="1.0" encoding="utf-8"?>

<service>

       <short>pptpd</short>

       <description>PPTP</description>

       <port protocol="tcp" port="1723"/>

</service>           *
EOF

systemctl start firewalld.service
firewall-cmd --permanent --zone=public --add-service=pptpd
firewall-cmd --add-masquerade

firewall-cmd --permanent --zone=public --add-port=47/tcp
firewall-cmd --permanent --zone=public --add-port=1723/tcp

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p gre -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p gre -j ACCEPT

firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i ppp+ -o eth0 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i eth0 -o ppp+ -j ACCEPT
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o eth0 -j MASQUERADE -s 192.168.0.0/24

firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i ppp+ -o enp0s3 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i enp0s3 -o ppp+ -j ACCEPT
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o enp0s3 -j MASQUERADE -s 192.168.0.0/24

firewall-cmd --reload
systemctl restart pptpd

nmap localhsot

printf"
user/password IP:
ServerIP: $serverip
username: $username
password: $password
"
