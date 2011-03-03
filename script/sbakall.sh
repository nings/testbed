cp *.sh /home/amc/svn/testbed/script/
cp *.py /home/amc/svn/testbed/script/
cp java/* /home/amc/svn/testbed/script/java/

cd /home/amc/svn/testbed/script/
svn add *
svnci
