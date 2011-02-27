#!/bin/sh

USAGE() {
    echo USAGE:
    echo "$0 <nodename> <nodename>"
    exit 1
}

if [ $# -lt 2 ];then 
    USAGE
fi

if [ -e node_list ]; then
	sudo xm list > node_list
fi

NODE_A=$(grep -w $1 node_list | awk -F' ' '{print $2}')
NODE_B=$(grep -w $2 node_list | awk -F' ' '{print $2}')

if [ $NODE_A != "" ] && [ $NODE_B != "" ]; then
	sudo iptables -D FORWARD -m physdev --physdev-in vif$NODE_A.0 --physdev-out vif$NODE_B.0 -j ACCEPT
	sudo iptables -D FORWARD -m physdev --physdev-in vif$NODE_B.0 --physdev-out vif$NODE_A.0 -j ACCEPT
else
	exit 1;
fi
