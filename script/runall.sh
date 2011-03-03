#!/bin/sh

for((i = 1; $i < 3; i++)); do
	startsce.sh worktodo/$i/scenario.xml
done
