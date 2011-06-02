#!/bin/sh
#echo "Nightly Run Successful: $(date)" >> /media/bak/testbed/script/tmp/mybackup.log
#scerun.jar /media/temp/work1/9/scenario.xml
for((i = 3 ; $i <= 4 ; i++)); do
#  time startsce.sh /media/temp/work1/$i/scenario.xml
	time scerun.jar /media/data/runex/cam/$i/scenario.xml 
#scerun.jar /media/file/work514/$i/scenario.xml
done
# for((i = 3 ; $i <= 4 ; i++)); do
# 	time scerun.jar /media/data/runex/mit/$i/scenario.xml 
# done
# for((i = 1 ; $i <= 4 ; i++)); do
# 	time scerun.jar /media/data/runex/inf/$i/scenario.xml 
# done
