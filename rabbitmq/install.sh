#!/bin/bash

if [ $UID -ne 0 ]
then
    echo "error: the script must be run with root." 1>&2
    exit 1
fi

WORKSPACE=`cd $(dirname $0);pwd`

RABBIT_HOME="/usr/local/rabbitmq"
ERLANG_HOME="/usr/local/erlang"

if [ -d "$RABBIT_HOME" ]
then
    echo "error: $RABBIT_HOME is already exists." 1>&2
    exit 1
fi 

Erlang() {
    cd $WORKSPACE
    
    if [ -d "opt_src_21.3" ]
    then 
        rm -rf opt_src_21
    fi

    yum install -y openssl-devel && \
    tar -zxvf opt_src_21.tar.gz && \
    cd opt_src_21 && 
    ./configure --prefix=$ERLANG_HOME --with-ssl && \
    make && \
    make install

    if [ $? -ne 0 ]
    then 
        return 1
    fi

    echo -e "export ERLANG_HOME=$ERLANG_HOME" > /etc/profile.d/erlang-env.sh 
    echo "export PATH=$ERLANG_HOME/bin:$PATH" >> /etc/profile.d/erlang-env.sh

    return 0
}

if [ ! -d "$ERLANG_HOME" ]
then 
    Erlang
    if [ $? -ne 0 ]
    then 
        echo "error: failed to install erlang." 1>&2
        exit 1
    fi 
fi

PATH=$ERLANG_HOME/bin:$PATH

cd $WORKSPACE

if [ -d "rabbitmq_server-3.7.14" ]
then 
    rm -rf rabbitmq_server-3.7.14
fi 

tar -xvf rabbitmq-server-generic-unix-3.7.14.tar.xz && \
mv rabbitmq_server-3.7.14 $RABBIT_HOME

echo -e "export RABBITMQ_HOME=$RABBIT_HOME" > /etc/profile.d/rabbitmq-env.sh 
echo "export PATH=$RABBITMQ_HOME/sbin:$PATH" > /etc/profile.d/rabbitmq-env.sh 

echo "please execute command: source /etc/profile.d/rabbitmq-env.sh"
echo "done!"