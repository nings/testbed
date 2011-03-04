#!/bin/sh

for((i = 4; $i < 18; i++)); do
	time startsce.sh worktodo/$i/scenario.xml
done
