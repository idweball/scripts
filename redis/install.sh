#!/bin/bash

function errMsg() {
    echo "$1" 1>&2
}

if [ $UID -ne 0 ];then
    errMsg "error: the script must be run with root."
    exit 1
fi

if [ -d "/usr/local/redis" ];then
    errMsg "error: /usr/local/redis is already exists."
    exit 1
fi

if [ -d "/data/redis" ];then
    errMsg "error: /data/redis is already exists."
    exit 1
fi

yum install -y gcc make expect
if [ $? -ne 0 ];then
    errMsg "error: failed to install the dependices."
    exit 1
fi

workspace=`cd $(dirname $0);pwd`

groupadd redis
useradd -g redis redis -s /sbin/nologin -M

mkdir -p /usr/local/redis/{etc,bin,var}
mkdir -p /data/redis
mkdir -p /data/logs/redis

if [ -d "redis-5.0.3" ];then
    rm -rf redis-5.0.3
fi

tar -zxvf redis-5.0.3.tar.gz && \
cd redis-5.0.3 && \
make && \
yes | cp redis.conf    /usr/local/redis/etc && \
yes | cp sentinel.conf /usr/local/redis/etc && \
yes | cp src/redis-*   /usr/local/redis/bin && \
rm -rf /usr/local/redis/bin/*.o && \
rm -rf /usr/local/redis/bin*.c
if [ $? -ne 0 ];then
    errMsg "error: failed to install redis-server"
    exit 1
fi

cd $workspace

yes | cp redis.logrotate /etc/logrotate.d/redis
yes | cp redis.shutdown  /usr/local/redis/bin/redis-shutdown
yes | cp redis.service   /usr/lib/systemd/system/redis.service
yes | cp redis.conf      /usr/local/redis/etc/redis.conf
yes | cp redis-env.sh    /etc/profile.d/redis-env.sh

chown -R redis:redis     /data/redis
chown -R redis:redis     /data/logs/redis
chown -R redis:redis     /usr/local/redis

systemctl daemon-reload && systemctl restart redis && systemctl enable redis
if [ $? -ne 0 ];then
    errMsg "error: failed to start the redis service."
    exit 1
fi

echo "success"
