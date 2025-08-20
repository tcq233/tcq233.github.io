#!/usr/bin/env bash
# Description: Minecraft Service Configuration
# Service Download URL  https://www.minecraft.net/en-us/download/server/
# Copyright (C) 2024 Puck

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
	yum -y install wget
	yum install -y unzip zip
	sudo yum install java-1.8.0-openjdk
	java -version
	mkdir minecraft
	cd minecraft
	touch eula.txt
	et
   	wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1291/forge-1.7.10-10.13.2.1291-installer.jar --no-check-certificate #加上 --no-check-certificate (不检查证书)选项。
	wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1291/forge-1.7.10-10.13.2.1291-universal.jar  --no-check-certificate
	java -jar forge-1.7.10-10.13.2.1291-installer.jar nogui --installServer #安装forge
	java -jar minecraft_server.1.7.10.jar nogui
}


echo "------------------------------------------------------------"
echo 'Minecraft Server By TCQ233:'
echo "1) MC-Service-Install" 
echo "2) MC-Service-Start" 
echo "3) MC-Forge-Start" 
echo "4) MC-More" 
echo "q) Exit!"
echo "------------------------------------------------------------"
read -p ":" cof

case $cof in      
	1)   
		mc
	;;
	2)
		cd minecraft
		java -jar minecraft_server.1.7.10.jar nogui 
	;;	
	3) 
		cd minecraft
		java -jar forge-1.7.10-10.13.2.1291-universal.jar nogui 
   	;;
	4) 
		echo Mode down https://feeday.lanzouq.com/i5HkJ062sr7g 
		echo Save down https://feeday.lanzouq.com/iUZA1062teuh
		echo Java down https://www.java.com/en/download/
   	;;     	  		 
   	q)
		exit
	;;  
	*)
		echo 'Input Error'
		exit
	;; 	
esac   
