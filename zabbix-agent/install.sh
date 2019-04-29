#!/bin/bash
# 安装Zabbix-agent 3.1LTS版本

if [ $? -ne 0 ];then
    echo "error: the script must be run with root" 1>&2
    exit 1
fi

ZBX_SERVER="$1"

if [ -z "$ZBX_SERVER" ];then
    ZBX_SERVER="127.0.0.1"
fi

rpm -Uvh https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
if [ $? -ne 0 ];then
    echo "error: failed to add the repository of zabbix-agent." 1>&2
    exit 1
fi 

yum clean all && yum install -y zabbix-agent
if [ $? -ne 0 ];then
    echo "error: failed to install the zabbix-agent" 1>&2
    exit 1
fi

sed -i 's@^Server=.*@Server="${ZBX_SERVER}"@' /etc/zabbix/zabbix_agentd.conf
sed -i 's@^ServerActive=.*@ServerActive="${ZBX_SERVER}"@' /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent && systemctl enable zabbix-agent 
if [ $? -ne 0 ];then
    echo "error: failed to started zabbix-agentd" 1>&2
    exit 1
fi 

echo "success"