# Makefile

.PHONY: all


install: all
	@echo "#######################################################"
	@echo "Installing host components" 
	@echo "#######################################################"
#	cp -df host/protocol-setup/* ../protocol-setup/
#	cp -dfr host/scenarios/* ../scenarios/
#	cp -df host/start_haggle_testbed ../
#	cp -df host/create_xenconfig.sh ../
#	cp -df host/manage_nodes.sh ../
#	cp -df host/manage_node.sh ../
	cp -df host/block-cow /etc/xen/scripts/
	cp -df host/create_cow /usr/sbin/
	cp -df host/destroy_cow /usr/sbin/
	@echo "#######################################################"
	@echo "Installing node components" 
	@echo "#######################################################"
#	cp -df node/node_config.sh ../node/cow/mnt/etc/init.d/
#	cp -df node/start_test_remote ../node/cow/mnt/root/

clean:
#		rm -rf *~ protocol-setup/*~ tsb spyd iwtool crypt apts logroute countdown utime ttcp mp3stream startsync open

# eof
