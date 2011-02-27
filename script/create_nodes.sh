#!/bin/bash

USAGE() {
    echo USAGE:
    echo "$0 <start number of nodes> <end number of nodes>"
    exit 1
}

if [ $# -lt 1 ];then 
    USAGE
fi

cd $(dirname $0)
node_count=$2
number_of_started_nodes=0
number_of_running_nodes=0
number_of_tries=0

node_start=$1

sleep_time=0

while [ "$number_of_running_nodes" -lt "$node_count" ]; do
	number_of_running_nodes=0
	number_of_started_nodes=0
	if ! sudo xm list > node_list; then
		exit 1
	fi
	for (( i=$node_start; i<$node_count; i++ )); do
		if [ "`grep -w "node-${i}" node_list`" == "" ]; then
			echo node-$i is not running.
			if ./manage_node.sh start node-$i; then
				let number_of_started_nodes=$number_of_started_nodes+1
			fi
		fi
	
	sleep $sleep_time
	
	let sleep_time=$sleep_time+1

	echo Pinging nodes.

		if [ "`ping -c 3 node-${i} | grep " 0% packet loss"`" == "" ]; then
			echo "node-$i is not answering to ping."
			if [ "$number_of_tries" -eq "3" ]; then
				echo Destroying node-$i
				sudo xm destroy node-$i
				number_of_tries=0
			fi		
		else
			let number_of_running_nodes=$number_of_running_nodes+1
			ssh user@node-${i} rm -rf .Haggle	# added by christian 7/3 2010
		fi

		
	done

	echo Number of started nodes where $number_of_started_nodes
	if [ $number_of_started_nodes -ne 0 ]; then
		number_of_tries=0
		echo "Waiting for nodes to start."
		sleep 20
	fi 

	if ! sudo xm list > node_list; then
		exit 1
	fi

	let number_of_tries=$number_of_tries+1
done

if ! sudo xm list > node_list; then
	exit 1
fi

echo
echo All nodes are running!
