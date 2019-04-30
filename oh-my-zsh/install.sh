#!/bin/bash

if [ $UID -ne 0 ];then
    echo "error: the script must be run with root." 1>&2
    exit 1
fi

yum install -y zsh curl && \
chsh -s /bin/zsh && \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
