#!/bin/bash

if [ $# -lt 1 ]; then
    echo -en "\n"

    echo "Iptables redirect script to support global proxy on ss for linux ... "
    echo -en "\n"
    echo "Usage : ${0} action [options]"
    echo "Example:"
    echo -en "\n"
    echo "${0} start server_ip To start global proxy"
    echo "${0} stop To stop global proxy"
    echo -en "\n"
else
    if [ "$1" == "stop" ]; then
        echo "stoping the Iptables redirect script ..."
        sudo ufw disable
        sudo iptables -t nat -F
        sudo iptables -F
        sudo iptables -X
        sudo ip6tables -F
        sudo ip6tables -X
        sudo ufw enable

    fi

    if [ "$1" == "start" ]; then
        # Create new chain
        iptables -t nat -N REDSOCKS
        # Ignore LANs and some other reserved addresses.
        iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
        iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
        iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
        iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
        iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
        iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
        iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
        iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
        # Anything else should be redirected to port 12345
        iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345 
        iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDSOCKS
        iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDSOCKS
    fi
fi