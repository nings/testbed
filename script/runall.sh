#!/bin/sh
#echo "Nightly Run Successful: $(date)" >> /media/bak/testbed/script/tmp/mybackup.log
for((i = 1; $i <= 18; i++)); do
  time startsce.sh /media/temp/work1/$i/scenario.xml
done
