#!/usr/bin/env bash
# Description: Minecraft Service Configuration
# Service Download URL  https://www.minecraft.net/en-us/download/server/
# Copyright (C) 2020 feeday <0xf197@gmail.com>

#配置网络防火墙
function ips(){
systemctl stop firewalld     #停止firewall防火墙
systemctl disable firewalld  #禁止firewall开机启动
systemctl mask firewalld     #禁用firewalld服务

yum install  -y wget iptables nmap iptables-services   #安装iptables防火墙和 nmap
systemctl start iptables         #启动防火墙

#配置文件目录 /etc/sysconfig/iptables

iptables -P INPUT ACCEPT   #先允许所有,不然有可能会杯具

iptables -F      #清空所有的防火墙规则
iptables -X      #清空所有自定义规则
iptables -Z      #所有计数器归0

iptables -A INPUT -p tcp --dport 22 -j ACCEPT   #开放22端口
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT   #开放25565端口(minecraft)
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT  #允许ping

iptables -P INPUT DROP  #其他入站一律丢弃

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT #允许由服务器本身请求的数据通过
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -P OUTPUT ACCEPT  #所有出站一律绿灯
iptables -P FORWARD DROP   #所有转发一律丢弃

service iptables save                #保存上述规则
systemctl restart iptables.service   #重启服务
systemctl enable iptables            #设置开机启动

systemctl start iptables.service    #启动服务
systemctl status iptables.service   #查看服务状态
iptables -L -n #查看防火墙规则
nmap localhost #查看开放的端口
}


#我的世界修复文件
function et(){
cat > eula.txt <<END
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
eula=ture
eula=TRUE
eula=true
eula=True
EULA=TRUE
EULA=true
EULA=True
eula =true
eula= true
eula = true
END
}

function mc(){
	yum install wget
	sudo yum install java-1.8.0-openjdk
	java -version
	mkdir minecraft
	cd minecraft
	touch eula.txt
	et
	wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1291/forge-1.7.10-10.13.2.1291-installer.jar
	wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1291/forge-1.7.10-10.13.2.1291-universal.jar
	java -jar forge-1.7.10-10.13.2.1291-installer.jar nogui --installServer #安装forge
	java -jar minecraft_server.1.7.10.jar nogui
}


echo "------------------------------------------------------------"
echo 'Minecraft Server By Feeday:'
echo "1) Server Management APPNode" 
echo "2) Test Host Network Server " 
echo "3) MC-Service-Install" 
echo "4) MC-Service-Start" 
echo "5) MC-Forge-Start" 
echo "q) Exit!"
echo "------------------------------------------------------------"
read -p ":" cof

case $cof in      
	1)   
		ips
		INSTALL_AGENT=1 INIT_SWAPFILE=1 bash -c "$(curl -sS http://dl.appnode.com/install.sh)"
	;;
	2)   
		curl -Lso- http://feeday.github.io/sh/host.sh | bash
	;;	
	3)   
		mc
	;;
	4)
		cd minecraft
		java -jar minecraft_server.1.7.10.jar nogui 
	;;	
	5) 
		cd minecraft
		java -jar forge-1.7.10-10.13.2.1291-universal.jar nogui 
   	;;	 
   	q)
		exit
	;;  
	*)
		echo 'Input Error'
		exit
	;; 	
esac   
