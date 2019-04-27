#!/bin/bash

if [ $UID -ne 0 ];then
    echo "error: the script must be run with root."
    exit 1
fi

yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine

yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
if [ $? -ne 0 ];then 
    echo "error: failed to install the dependices." 
    exit 1
fi 

yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo 
if [ $? -ne 0 ];then
    echo "error: failed to add repository."
    exit 1
fi
yum install -y docker-ce 
if [ $? -ne 0 ];then
    echo "error: failed to install docker-ce."
    exit 1
fi 

cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ]
}
EOF

if ! egrep "^net.bridge.bridge-nf-call-ip6tables = 1" /etc/sysctl.conf &>/dev/null;then
    echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
fi 

if ! egrep "^net.bridge.bridge-nf-call-iptables = 1" /etc/sysctl.conf &>/dev/null;then
    echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
fi
sysctl -p

systemctl restart docker && systemctl enable docker 
if [ $? -ne 0 ];then
    echo "error: failed to started docker-ce"
    exit 1
fi 

docker run hello-world
