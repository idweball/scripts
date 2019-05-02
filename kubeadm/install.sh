#!/bin/bash

if [ $? -ne 0 ];then
    echo "error: the script must be run with root."
    exit 1
fi


cat > /etc/yum.repos.d/k8s.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
enabled=1
EOF

yum install -y kubelet kubeadm kubectl
if [ $? -ne 0 ];then
    echo "error: failed to install kubadm"
    exit 1
fi
