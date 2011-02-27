#!/bin/bash

. node.conf

USAGE() {
    echo USAGE:
    echo "$0 <number of nodes>"
    exit 1
}

if [ $# -lt 1 ];then 
    USAGE
fi

cd $(dirname $0)
nodeCount=$1

# Remove logs from each node.
for((i = 0; $i < $nodeCount; i++)); do
        node_name="node-"$i
	ssh $NODE_USERNAME@$node_name rm screenlog.0
        if ! ssh $NODE_USERNAME@$node_name rm .Haggle/*; then
                echo "Could not remove logs on $node_name"
                exit 1
        fi
done

