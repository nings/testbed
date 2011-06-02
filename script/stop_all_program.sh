#!/bin/sh

. node.conf

USAGE() {
    echo USAGE:
    echo "$0 <number of nodes> <application>"
    exit 1
}

if [ $# -lt 2 ];then 
    USAGE
fi

cd $(dirname $0)
nodeCount=$1
application=$2

# Remove logs from each node.
for((i = 0; $i < $nodeCount; i++)); do
	node_name=node-$i
	echo $node_name
#	ssh $NODE_USERNAME@$node_name "ps ax | grep SCREEN | grep haggle | awk '{print \$1}' | xargs kill"
	ssh $NODE_USERNAME@$node_name "ps ax | grep SCREEN | grep $application | awk '{print \$1}' | xargs kill"
done





