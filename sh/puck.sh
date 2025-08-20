#!/usr/bin/env bash
# Description: CentOS 7 Configure
# System Download URL  https://mirrors.aliyun.com/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso
# Copyright (C) 2024 Puck

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
iptables -A INPUT -p tcp --dport 8888 -j ACCEPT   #开放8888端口
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

#安装p3
function p3(){
	yum install -y wget epel-release xz gcc zlib zlib-devel openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel
	if [[ ! -s /usr/bin/python3 ]]; then
        wget http://file.aionlife.xyz/source/download?id=5b9e7227dc72d90ebb47023a -O Python-3.6.4.tar.xz  #https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tar.xz(这个地址国内下载比较慢，所以这里换成另一个地址)
        tar -Jxvf Python-3.6.4.tar.xz
        cd Python-3.6.4
        ./configure --prefix=/usr/python3.6
        make&&make install
        ln -s /usr/python3.6/bin/python3 /usr/bin/python3
        mkdir ~/.pip
        echo -e "[global]\nindex-url = http://mirrors.aliyun.com/pypi/simple/\n[install]\ntrusted-host = mirrors.aliyun.com" > ~/.pip/pip.conf
        ln -s /usr/python3.6/bin/pip3 /usr/bin/pip3  
	fi
	pip3 install --upgrade pip
	python3 -V
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
	echo nginx 配置文件目录 /usr/local/nginx/html

}
#安装jupyter
function jr(){
	cd /home 
	python -m venv tutorial-env
	source tutorial-env/bin/activate
	python -m pip install novas
	pip install --upgrade pip 
	pip3 install jupyter
	jupyter notebook --port 8888 --allow-root
}
#安装jupyter
function jr2(){
	wget https://pypi.python.org/packages/45/29/8814bf414e7cd1031e1a3c8a4169218376e284ea2553cc0822a6ea1c2d78/setuptools-36.6.0.zip#md5=74663b15117d9a2cc5295d76011e6fd1
	unzip setuptools-36.6.0.zip 
	cd setuptools-36.6.0
	python setup.py install
	wget https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-9.0.1.tar.gz#md5=35f01da33009719497f01a4ba69d63c9
	tar -zxvf pip-9.0.1.tar.gz
	cd pip-9.0.1
	python setup.py install
	pip install --upgrade pip 
	pip install jupyter notebook
	jupyter notebook --port 9999 --allow-root
}
echo "------------------------------------------------------------"
echo 'CentOS 7 Configure By Puck:'
echo "1) Install Software More" #安装常用软件
echo "2) Test Serve Host Puck" #测试服务器
echo "3) iptables port" #配置网络防火墙
echo "4) AppNode web" #Web管理软件
echo "5) Minecraft" ##安装我的世界服务器
echo "6) Port nmap" #端口
echo "7) Poweroff" #关机
echo "8) Fooocus" #画图
echo "q) Exit!"
echo "------------------------------------------------------------"
read -p ":" cof

case $cof in      
	1) 
		echo "------------------------------------------------------------"
		echo 'Software Install By TCQ233:'
		echo "1) PHP74 MySQL56" #安装 php74 mysql56
		echo "2) Python3" #安装Python3			
		echo "3) jupyter" #安装常用网络工具
		echo "4) Nginx" #安装 nginx 
  		echo "5) BTCN-5" #安装 nginx 
  		echo "6) termux" #安装 nginx 
		echo "q) Exit!"
		echo "------------------------------------------------------------"
		read -p ":" ins
		case $ins in    
			1)
				INSTALL_AGENT=1 INSTALL_APPS=sitemgr INIT_SWAPFILE=1 INSTALL_PKGS='nginx-stable,php74,mysql56' bash -c "$(curl -sS http://dl.appnode.com/install.sh)"

			;;
			2)
				p3
			;;
			3)
				jr2 	
			;;
			4)
			        nx
			;;
   			5)
			        if [ -f /usr/bin/curl ];then curl -sSO https://download.bt.cn/install/install_panel.sh;else wget -O install_panel.sh https://download.bt.cn/install/install_panel.sh;fi;bash install_panel.sh ed8484bec
			;;
      			6)
			        curl -Lso- https://datxy.com/sh/ts.sh | bash
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
		curl -Lso- https://datxy.com/sh/host.sh | bash
	;;
	3)
		ips 
	;;	
	4) 
		INSTALL_AGENT=1 INIT_SWAPFILE=1 bash -c "$(curl -sS http://dl.appnode.com/install.sh)"
   	;;	 
	5)
		bash -c "$(curl -sS https://datxy.com/sh/mcs.sh)" 
	;;
	6)
		yum install nmap
		nmap localhost
	;; 
	7)
		poweroff
	;; 
 	8)
		sudo apt update
		sudo apt install git
		sudo yum install git
		pip install pygit2==1.12.2
  		git clone https://github.com/lllyasviel/Fooocus.git
    		cd Fooocus
		python entry_with_update.py --share --always-high-vram
	;; 
   	q)
		exit
	;;  
	*)
		echo 'Input Error'
		exit
	;; 	
esac   
