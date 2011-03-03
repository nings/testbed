#!/bin/bash

. node.conf

USAGE() {
    echo USAGE:
    echo "$0 <number of nodes> <iteration> <archivepath>"
    exit 1
}

if [ $# -lt 3 ];then 
    USAGE
fi

cd $(dirname $0)
nodeCount=$1
iteration=$2
archivepath=$3

if [ ! -d tmp ]; then
	mkdir tmp
fi
# Create directory for log files
mkdir tmp/$iteration
files=""
for((i = 0; $i < $nodeCount; i++)); do
	node_name="node-"$i
	files=$files" "$node_name
	mkdir tmp/$iteration/$node_name
	# Get log from node.
	if ! scp $NODE_USERNAME@$node_name:.Haggle/* tmp/$iteration/$node_name/; then
		echo "Could not download logs from $node_name"
#		exit 1
	fi
done

tarball=$iteration".tar"
cmd="tar -rf "$archivepath$tarball
# Add execution log and execute. No, copy to log directory instead.
cp *.log tmp/$iteration/
#tarcmd=$cmd" *.log"
#$tarcmd
# Add all log files.	
cmd=$cmd" -C tmp/ "$iteration
# Execute cmd.
$cmd

gzip $archivepath$tarball


# Remove logs from each node.
# for((i = 0; $i < $nodeCount; i++)); do
# 	node_name="node-"$i
# 	if ! ssh $NODE_USERNAME@$node_name rm .Haggle/*; then
# 		echo "Could not remove logs on $node_name"
# 		exit 1
# 	fi
# done

# Remove all log files from host
cd $(dirname $0)
rm -r tmp/*
rm *.log

