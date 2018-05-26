#!/bin/bash
options="-d"
starts="start"
stops="stop"

if [[ $1 == $options ]] && [[ $2 == $starts ]]
then
        /root/shadowsocksr/shadowsocks/local.py -c /etc/shadowsocks/example.json -d start
elif [[ $1 == $options ]] && [[ $2 == $stops ]]
then
        /root/shadowsocksr/shadowsocks/local.py -c /etc/shadowsocks/example.json -d stop
else
    echo -e "\033[36m Use -d to [start]|[stop] The SS | SSR \033[0m";
fi
