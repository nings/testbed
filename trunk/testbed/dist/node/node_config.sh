#!/bin/sh
# Node configuration  
# Authors :  Fredrik Bjurefors <fredrik.bjurefors@it.uu.se>
# chkconfig: 345 99 99
# description: Configures nodes in the testbed 

PATH=/sbin:/bin:/usr/sbin:/usr/bin
. /lib/init/vars.sh
. /lib/lsb/init-functions

# set NFSIP
# set HAGGLELOG
# set HAGGLEPATH
# set USERNAME

case "$1" in
    start)
        IPADDR=$(cat /proc/cmdline  | awk -F: '{print $1}' | awk -F= '{print $2}')
        HOSTNAME=$(cat /proc/cmdline  | awk -F: '{print $5}')
        log_success_msg "Setting "$HOSTNAME 
        hostname $HOSTNAME

        log_success_msg "Setting "$IPADDR 
        ifconfig eth0 $IPADDR	
	route add default gw $NFSIP

	log_success_msg "Setting up /dev/pts"
	mkdir /dev/pts
	mount -t devpts devpts /dev/pts 

        log_success_msg "Mounting protocols from host"
	mount -t nfs $NFSIP:$HAGGLEPATH $HAGGLEPATH
#	mount -t nfs $NFSIP:$HAGGLELOG/$HOSTNAME /home/$USERNAME/.Haggle
    ;;
    stop)
        echo "Unmounting protocols"
	umount $HAGGLEPATH
#	umount /home/$USERNAME/.Haggle
    ;;
    *)
        echo "USAGE: $0 start|stop"
        exit 1
    ;;
esac
exit 0

