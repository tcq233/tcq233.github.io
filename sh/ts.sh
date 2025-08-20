#!/bin/bash
pkg update
apt-get update && apt-get upgrade
pkg install nano vim unzip unrar nmap curl wget git tree -y
pkg install tsu -y &>/dev/null
pkg install root-repo -y &>/dev/null
pkg install p7zip -y &>/dev/null
pkg install openssh
termux-setup-storage
whoami
ip -4 a show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
echo "passwd"
echo "sshd"
