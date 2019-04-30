#!/bin/bash
# 安装Shdowsocks服务端


METHOD='rc4-md5'             # 加密方式
PASSWORD='p@ssw0rd'          # 密码
PORT='12345'                 # 监听端口



function start() {
    ssserver -s 0.0.0.0 -p $PORT -m $METHOD -k $PASSWORD -d start
    if [ $? -ne 0 ];then
        echo 'error: failed to start the shadowsocks services' 1>&2
        exit 1
    fi
    echo "started ok. port: $PORT method: $METHOD password: $PASSWORD"
}


function stop() {
    ssserver -s 0.0.0.0 -p $PORT -m $METHOD -k $PASSWORD -d stop
    if [ $? -ne 0 ];then
        echo 'error: failed to stop the shadowsock service.' 1>&2
        exit 1
    fi
    echo "stopped ok."
}

function install() {
    if [ $UID -ne 0 ];then
        echo "error: the script must be run with root." 1>&2
        exit 1
    fi

    yum install -y epel-release &&  yum install -y python2-pip
    if [ $? -ne 0 ];then
        echo "error: faild to install dependices" 1>&2
        exit 1
    fi

    pip install shadowsocks
    if [ $? -ne 0 ];then
        echo "error: failed to install shadowsocks" 1>&2
        exit 1
    fi
}

function main() {
    case $1 in
        'start')
            start
            ;;
        'stop')
            stop
            ;;
        'install')
            install && start
            ;;
        '-h|--help')
            echo 'Usage: $0 {start|stop|install|-h|--help}'
            ;;
        *)
            install && start
            ;;
    esac
}

main
