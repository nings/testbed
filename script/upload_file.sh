#!/bin/bash

. node.conf

USAGE() {
    echo USAGE:
    echo "$0 <localName> <remoteName (not path)> <number of nodes>"
    echo "   copy file localName to .Haggle directory on nodes."
    exit 1
}

if [ $# -lt 3 ];then 
    USAGE
fi

cd $(dirname $0)
localName=$1
remoteName=$2
node_count=$3

for((i = 0; $i < $node_count; i++)); do
	node_name="node-"$i
	# Create .Haggle on the node.
	ssh $NODE_USERNAME@$node_name mkdir .Haggle
	# Copy file to node.
	echo "scp $localName $NODE_USERNAME@$node_name:.Haggle/$remoteName"

	if ! scp $localName $NODE_USERNAME@$node_name:.Haggle/$remoteName; then
		echo "Could not copy file $localName to $node_name:.Haggle/$remoteName"
		exit 1
	fi

	if ! ssh $NODE_USERNAME@$node_name " cp .Haggle/$remoteName .Haggle/$node_name"; then
		echo "Could not copy file .Haggle/$remoteName .Haggle/$node_name"
		exit 1
	fi
done


