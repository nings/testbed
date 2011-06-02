#!/bin/bash

USAGE() {
    echo USAGE:
    echo "$0 <number of nodes>"
    exit 1
}

if [ $# -lt 1 ];then 
    USAGE
fi

cd $(dirname $0)
# Node number starts with zero.
let node_count=$1-1

while [ $node_count -gt 100 ]; do
	sudo xm destroy node-$node_count
	let node_count=$node_count-1
done

