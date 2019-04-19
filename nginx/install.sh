#!/bin/bash


function errMsg() {
    echo "$1" 1>&2
}

if [ $UID -ne 0 ];then
    errMsg "error: the script must be run with root."
    exit 1
fi

if [ -d "/usr/local/nginx" ];then
    errMsg "error: /usr/local/nginx is already exists."
    exit 1
fi

workspace=`cd $(dirname $0);pwd`

groupadd www
useradd -g www www -s /sbin/nologin -M

yum install -y gcc make openssl-devel pcre-devel 
if [ $? -ne 0 ];then
    echo "error: failed to install the dependices."
    exit 1
fi

if [ -d "nginx-1.14.2" ];then
    rm -rf nginx-1.14.2
fi

tar -zxvf nginx-1.14.2.tar.gz && \
cd nginx-1.14.2 && \
./configure --prefix=/usr/local/nginx \
    --user=www \
    --group=www \
    --with-http_ssl_module \
    --with-http_stub_status_module && \
make && \
make install

if [ $? -ne 0 ];then
    errMsg "error: failed to install nginx"
    exit 1
fi

cd $workspace

mkdir -p /usr/local/nginx/vhost
mkdir -p /data/wwwroot/default
mkdir -p /data/logs/wwwlog

yes | cp index.html.default /data/wwwroot/default/index.html
yes | cp nginx.conf /usr/local/nginx/conf/nginx.conf
yes | cp nginx.logrotate /etc/logrotate.d/nginx
yes | cp nginx.service /usr/lib/systemd/system/nginx.service
yes | cp nginx-env.sh /etc/profile.d/nginx-env.sh

systemctl daemon-reload && systemctl restart nginx && systemctl enable nginx
if [ $? -ne 0 ];then
    errMsg "error: failed to start nginx."
    exit 1
fi

echo "success"
