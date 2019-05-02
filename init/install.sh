#!/bin/bash

if [ $? -ne 0 ]
then
    echo "error: the script must be run as root." 1>&2
    exit 1
fi


yum install -y epel-release && \
    yum install -y vim git gcc make iptables-service net-tools lrzsz
if [ $? -ne 0 ]
then
    echo "error: failed install the common softs." 1>&2
    exit 1
fi

systemctl stop postfix && systemctl disable postfix
systemctl stop chronyd && systemctl disable chronyd
systemctl stop firewalld && systemctl disable firewalld

iptables -P INPUT ACCEPT && iptables -P OUTPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -F && service iptables save

sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

cat > /etc/security/limits.d/all-nofile.conf << EOF
* hard nofile 65536
* soft nofile 65536
EOF

cat > ~/.vimrc << EOF
set nu
set ai
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
EOF

yes | cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
