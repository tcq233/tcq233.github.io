#!/usr/bin/env bash
# Description: CentOS 7 Configure
# System Download URL  https://mirrors.aliyun.com/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso
# Copyright (C) 2022 TCQ233 <0xf197@gmail.com>

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
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  #开放80端口(HTTP)
iptables -A INPUT -p tcp --dport 443 -j REJECT  #关闭443端口(HTTPS)
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT   #开放25565端口(MC)
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

#安装 网络工具
function nt(){
	yum -y install wget curl-devel expat-devel gettext-devel openssl-devel zlib-devel net-tools openssh-server iptables nmap iptables-services git-core
	cd /etc
	touch gitconfig
	gpt 
	git config --list
	git --version
	ip add	
}

#Git用户配置文件
function gpt(){
cat > gitconfig  <<END
[http]
    postBuffer = 2M
[user]
    name = puck
    email = 0xf197@gmail.com
END
}

#安装py3
function py3(){
	yum -y groupinstall "Development tools"
	yum -y install wget zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
	yum install libffi-devel -y
	cd /home
	wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
	tar -xvJf  Python-3.7.0.tar.xz
	mkdir /usr/local/python3 #创建编译安装目录
	cd Python-3.7.0
	./configure --prefix=/usr/local/python3
	make && make install
	cd /usr/bin/
	mv python python.bak
	ln -s /usr/local/python3/bin/python3 /usr/bin/python
	ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
	
	cd /home
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	sudo python get-pip.py
	PATH=$PATH:/usr/local/python3/bin
	cd /home
	wget https://github.com/soimort/you-get/archive/master.zip
	unzip -o master.zip
	mv you-get-master xz
	python -V
	pip3 -V

}

#安装Nginx
function nx(){
	cd /home #cd /usr/local/src
	yum -y install wget unzip zip
	yum -y install gcc gcc-c++ autoconf automake make
	yum -y install gcc openssl openssl-devel pcre-devel zlib zlib-devel
	wget http://nginx.org/download/nginx-1.16.1.tar.gz #下载软件包
	tar -zxvf nginx-1.16.1.tar.gz #解压软件包
	cd nginx-1.16.1
	./configure --prefix=/usr/local/nginx #编译
	make && make install          #安装
	/usr/local/nginx/sbin/nginx #启动nginx 没有保持安装成功
	/usr/local/nginx/sbin/nginx -s stop
	/usr/local/nginx/sbin/nginx -s reload
     /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
     /usr/local/nginx/sbin/nginx -t #测试配置文件是否正常
	ln -s /usr/local/nginx/sbin/nginx  /usr/bin/nginx #创建nginx的软连接
	cd /home
	rm -rf nginx-1.16.1/
	cd /usr/local/nginx/conf/ #配置文件 编辑 vi nginx.conf
	nginx -t #检查配置文件   /usr/local/nginx/html

}
echo "------------------------------------------------------------"
echo 'CentOS 7 Configure By TCQ233:'
echo "1) Install Software More" #安装常用软件
echo "2) Test Serve Host" #测试服务器
echo "3) iPtables Port" #配置网络防火墙
echo "4) AppNode Web" ##安装服务器管理软件
echo "5) Minecraft" ##安装我的世界服务器
echo "6) Poweroff" #关机
echo "q) Exit!"
echo "------------------------------------------------------------"
read -p ":" cof

case $cof in      
	1) 
		echo "------------------------------------------------------------"
		echo 'Software Install By Feeday:'
		echo "1) Net-Tools" #安装常用网络工具
		echo "2) Python3" #安装Python3			
		echo "3) Nginx" #安装 Nginx
		echo "q) Exit!"
		echo "------------------------------------------------------------"
		read -p ":" ins
		case $ins in    
			1)
				nt
			;;
			2)
				py3
			;;
			3)
				nx
			;;															
			q)
				exit
			;;  
			*)
			echo 'Input Error'
				exit
			;;  				                           
           esac    
	;;    
	2)
		curl -Lso- https://tcq233.github.io/sh/host.sh | bash
	;;
	3)
		ips
	;;	
	4) 
		INSTALL_AGENT=1 INIT_SWAPFILE=1 bash -c "$(curl -sS http://dl.appnode.com/install.sh)"
   	;;	 
	5)
		bash -c "$(curl -sS https://tcq233.github.io/sh/mcs.sh)"
	;;
	6)
		poweroff
	;; 	
   	q)
		exit
	;;  
	*)
		echo 'Input Error'
		exit
	;; 	
esac   
