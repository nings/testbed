#!/bin/bash

# Make sure to be in the correct directory!!!

while [ 1 ]; do
# Get file from queue with ls 
	FILE=`ls -c queue | more | tail -1`
	while [ "$FILE" = "" ]; do
		sleep 10
		FILE=`ls -c queue | more | tail -1`
	done
# Untar file into archive directory with pending-tag.
	date
	echo $FILE
	tar -xzvf queue/$FILE -C archive
	ARCHIVENAME=`echo $FILE | awk -F. '{print $1}'`
	mv archive/$ARCHIVENAME archive/$ARCHIVENAME-pending
#	rm queue/$FILE
# For testing purpose
	sleep 10
# Find scenario.
	SCENARIO=`ls archive/$ARCHIVENAME-pending/*.xml`
# Log haggle version
	cd haggle-googlecode/
	hg branch > ../archive/$ARCHIVENAME-pending/haggle-revision
	hg branches >> ../archive/$ARCHIVENAME-pending/haggle-revision
	cd -
# Log bandwidth utilization of the disk.
	iostat -d -x 5 > archive/$ARCHIVENAME-pending/io_util.log &
# Log CPU usage
	mpstat 1 > archive/$ARCHIVENAME-pending/cpu_util.log &
# Execute scanrio(s).
	#java scenariorunner2
	java -classpath scenariorunner2.jar scenariorunner2 $SCENARIO
# Stop disk log.
	ps ax | grep iostat | awk '{print $1}' | xargs kill
# Stop cpu log
	ps ax | grep mpstat | awk '{print $1}' | xargs kill
# When done, remove pending-tag
	mv archive/$ARCHIVENAME-pending archive/$ARCHIVENAME-$(date +"%s")
done
