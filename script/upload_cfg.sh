#!/bin/bash

. node.conf

USAGE() {
    echo USAGE:
    echo "$0 <configfile> <number of nodes>"
    exit 1
}

if [ $# -lt 2 ];then 
    USAGE
fi

cd $(dirname $0)
configfile=$1
node_count=$2

for((i = 0; $i < $node_count; i++)); do
	node_name="node-"$i
	# Create .Haggle on the node.
	ssh $NODE_USERNAME@$node_name mkdir .Haggle
	# Copy configuration file to node.
	if ! scp $configfile $NODE_USERNAME@$node_name:.Haggle/config.xml; then
		echo "Could not copy configuration file to $node_name"
		exit 1
	fi
done


