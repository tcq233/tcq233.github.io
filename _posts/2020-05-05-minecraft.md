---
layout:     post
title:      Minecraft
date:       2020-05-05
author:     Feeday
catalog: true
tags:
    - Game
---
## 简介

我的世界是一款沙盒式建造游戏。

## 游戏模式切换

```
第一步 Esc ↓
                对局域网开放
                                 ↓创造
                                        ↓作弊开
                                                  ↓按T
                                                       ↓输入指令 gamemode 1完
1.14.2版本中 F3+N 快速切换游戏模式
```

## 操作快捷键

```
ESC：按下后打开游戏菜单并释放鼠标指针。单人模式中同时暂停游戏。
F1：按下后开启或关闭HUD
F2：按下后保存游戏当前截图到 \.minecraft\screenshots （Windows）
F3：按住时出现调试屏幕，并显示游戏版本。帧率(FPS)、可用内存和性能图表信息。
F5：在第一人称视角与第三人称视角之间切换。
鼠标左键：攻击
鼠标右击：使用物品
鼠标中键：选择方块
空格：跳跃
W：前进
A：向左
S：后退
D：向右
E：道具栏
Q：丢弃
T：聊天
Tab：玩家列表
```

## 游戏常用指令
```
/gamemode adventure      ## 游戏改成冒险模式
/gamemode creatibe       ## 游戏改成创造模式
/gamemode spectator      ## 游戏改成旁观模式
/gamemode survival       ## 游戏改成生存模式
 
/setworldspawn        ## 设置世界出生点
/spawnpoint           ## 为玩家设置出生点
/setspawn             ## 將当前位置设置为新玩家的预设出生的
/tp NPC1 NPC2         ## tp [传送目标]  [传送位置]
/tp NPC1 10 10 10     ## tp [传送目标]  [x,y,z] 世界坐标 
 
/op player1 # 把player1设为op，然后player1就能输入作弊码了。
/deop player1  # 取消 player1 作弊码。
/gm [0/1/2] [player2] # 给别人生存模式/创造模式/冒险模式。
/ban player2 # 封禁 player2。

/weather clear         ## 改变天气为晴天
/weather rain          ## 改变天气为雨天
/weather thunder       ## 改变天气为雷雨天
/weather rain 600      ## 下十分钟的雨 600=10分钟
/time set day         ## 设置成白天
/time set noon        ## 设置成中午
/time set night       ## 设置成晚上
/time set midnight    ## 设置成午夜
```
## 我的世界游戏服务器要求

> 服务器最低要求：CPU：双核或更好。内存： 2 GB （20-40 用户量)，3 GB（30-60 用户量），8 GB（60+ 用户量）。

## 服务器一键配置脚本

> 服务器一键安装的版本是 1.7.10 如果安装其他版本 vi 修改 mcs.sh 脚本 71 行 和 72 行 找到对应的服务端 jar 文件

```
curl https://feeday.github.io/sh/mcs.sh -O ## 下载配置脚本
bash mcs.sh    #执行脚本  

## 1、安装服务器管理应用 
## 2、下载安装服务器端 
## 3、启动原版服务器
## 4、启动模组服务器
```

## 配置服务器配置代码

```
yum install wget  #安装软件

sudo yum install java-1.8.0-openjdk  #安装Java

java -version  #查看Java版本

mkdir /etc/minecraft  #创建游戏服务器目录文件夹

cd /etc/minecraft  #切换到游戏目录

wget https://launcher.mojang.com/v1/objects/3dc3d84a581f14691199cf6831b71ed1296a9fdf/server.jar  #下载游戏服务器端
wget https://launcher.mojang.com/mc/game/1.7.10-pre3/server/b9fdcbd17407d9eaeedcf4ff79b3121ee40133db/server.jar #1.7.10 服务器

wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1291/forge-1.7.10-10.13.2.1291-installer.jar
wget http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.7.10-10.13.2.1291/forge-1.7.10-10.13.2.1291-universal.jar

java -jar forge-1.7.10-10.13.2.1291-installer.jar nogui --installServer #安装forge
java -jar forge-1.7.10-10.13.2.1291-universal.jar nogui  #启动forge

java -Xmx1024M -Xms1024M -jar minecraft_server.1.14.4.jar nogui  #启动游戏服务端 

/stop 停止游戏服务端

#-Xms:初始启动分配的内存（-Xms512m）
#-Xmx:最大分配的内存（-Xmx1024m）
#nogui:用于以基于文本的界面来显示，可减少内存使用。如果使用图形化界面，那么移除nogui选项。
```

## 服务器配置文件

> server.propertices是mc服务端配置文件，可设置游戏难度、世界类型、游戏模式、允许玩家数量、世界大小、黑白名单等等。如果客户端连接报错，说明你不是正版用户端。配置文件常见配置说明：

````
#Minecraft server properties
#Fri Jan 05 22:45:30 CST 2018
generator-settings=
op-permission-level=4
allow-nether=true  #是否开启地狱
level-name=world #存档名称，也就是读取的存档文件夹的名称，默认为world
enable-query=false
allow-flight=false
announce-player-achievements=true
server-port=25565 #端口，客户端连接的话要指定这个端口，服务器防火墙要开放这个端口。可以不指定，默认为：25565
level-type=DEFAULT
enable-rcon=false #是否开启rcon监听
force-gamemode=false  #force游戏模式
level-seed= #地图种子
server-ip=
max-build-height=256
spawn-npcs=true #是否有主城NPC
white-list=false  #是否开启白名单（开启后在白名单内的玩家才能进入服务器，否则进入不了。不要随便开）
spawn-animals=true  #主城是否有动物
snooper-enabled=true
hardcore=false #我的世界极限模式是否开启 
online-mode=false #是否连接正版服务器校验 false 不用验证 默认 true 需要验证
resource-pack=
pvp=true #是否开启服务器PVP
difficulty=1
enable-command-block=false
player-idle-timeout=0
gamemode=0 #玩家默认进入游戏的游戏模式 1创造 0生存 2冒险模式3旁观者
max-players=20 #服务器最大玩家数（超过后玩家无法进入）
spawn-monsters=true  #主城是否刷新怪物
view-distance=10
generate-structures=true
motd=A Minecraft Server  #MOTD指的是在玩家添加服务器后下面会显示这里面的内容
````
