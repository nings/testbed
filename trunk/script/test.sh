#!/bin/bash
COUNTER=0
while [ $COUNTER -lt 49 ]; do
#    ./start_program_on_node.sh node-$COUNTER haggle --non-interactive 
sudo xm destroy node-$COUNTER
    let COUNTER=$COUNTER+1
done

