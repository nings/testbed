#!/bin/bash
# This script will create and configure the base node
# for the testbed and also configure the host.
# Author Fredrik Bjurefors <fredrik.bjurefors@it.uu.se>
# 2008-11-14
# This script must be executed as su.

USER=$1

INSTALL_PATH=`pwd`

# pwd\
#     -/node\
#            -/cfg		Configuration files for the virtual nodes.
#            -/swap		Swap files for the virtual nodes.
#            -/cow		Common file system used by the virtual nodes.
#            -/mnt		Mount point for the file system during testbed setup.
NODE_PATH=`pwd`/node
IMAGE_PATH=${NODE_PATH}/cow
SWAP_PATH=${NODE_PATH}/swap
CONFIG_PATH=${NODE_PATH}/cfg
MOUNT_PATH=${NODE_PATH}/mnt

# set path to haggle installation.
HAGGLE_INSTALL_PATH=/usr/local/haggle
NODE_USERNAME=user

# BRIDGENAME should be set to 'xenbr0' in ubuntu and debian.
BRIDGENAME=xenbr0
NETID=192.168.122
BRIDGEIP=$NETID.1
DEBIAN_VERSION=squeeze
UBUNTU_VERSION=gutsy

# PACKAGES is a list of packages required to run the testbed. Note: No comma between package names.
PACKAGES="openssh-server debootstrap nfs-kernel-server nfs-common portmap dmsetup make sysstat";
# TODO add to packages... required to compile Haggle
# autoreconf libtool libxml2-dev libssl-dev libsqlite3-dev
# for vendetta
# openjdk-6-jdk

# portmap and nfs-common are used to NSF mount protocols, scenarios and log-area.
# old includes 
#INCLUDES="tcpdump,iptables,ssh,libxml2,portmap,nfs-common,screen,sudo,libsqlite3-0,iperf,gdb,libc6,libdbus-1-3";
INCLUDES="tcpdump,iptables,ssh,libxml2,portmap,nfs-common,screen,sudo,libsqlite3-0,iperf,gdb,libdbus-1-3,libc6,libbluetooth3";


# new includes INCLUDES="ssh,libxml2,portmap,nfs-common,screen,libsqlite3-0";

#EXCLUDES_DEBIAN="gcc-4.2-base,gcc-4.3-base,make";
EXCLUDES_UBUNTU="ubuntu-keyring,laptop-detect,eject";

USAGE()
{
    echo USAGE:
    echo "sudo $0"
    exit 1
}

#pass_requisites()
#{
if [ $(whoami) != "root" ]; then
	echo "This script must be executed as su."
	USAGE
	exit 1
fi

# Check that xen is installed and running.
# TODO: this does not really make sure that Xen is running.
#if [ "`uname -r | grep xen`" = "" ];then
#	echo A Xen kernel must be running on the computer.
#	exit 1
#fi

# Check that $BRIDGENAME exists.
# if ! /sbin/ifconfig $BRIDGENAME &>/dev/null; then
#	echo "The virtual bridge, "$BRIDEGENAME" does not exist."
#	echo "In /etc/xen/xend-config.sxp enable (network-script network-bridge)"
#	exit 1
#fi
#} # end pass_requisites()

# Check that all required packages are installed.
for PACKAGE in $PACKAGES
do
	STATE=`aptitude show $PACKAGE | grep ^State:`
	STATE=${STATE##*: }
	if ! [ "$STATE" = "installed" ]; then
		aptitude install $PACKAGE
	else
		echo $PACKAGE is already installed.
	fi
done

# Remove old node files.
rm -rf $NODE_PATH

if [ ! -d $NODE_PATH ]; then
	sudo -u $USER bash -c "mkdir $NODE_PATH"
fi

if [ ! -d $SWAP_PATH ]; then
	sudo -u $USER bash -c "mkdir $SWAP_PATH"
fi

if [ ! -d $CONFIG_PATH ]; then
	sudo -u $USER bash -c "mkdir $CONFIG_PATH"
fi

# Create directories for batch queue and archive.
if [ ! -d ~/queue ]; then
	sudo -u $USER bash -c "mkdir ~/queue"
fi
if [ ! -d ~/archive ]; then
	sudo -u $USER bash -c "mkdir ~/archive"
fi

echo "Creating images."

# Create a directory for the guest system files.
if [ ! -d $IMAGE_PATH ]; then
	sudo -u $USER bash -c "mkdir $IMAGE_PATH"
fi

# Create a mountpoint for the images.
if [ ! -d $MOUNT_PATH ]; then
	sudo -u $USER bash -c "mkdir $MOUNT_PATH"
fi

# Check that no old image files are mounted.
if df | grep $IMAGE_PATH/node.img; then
	echo $IMAGE_PATH/node.img is already mounted.
	echo Unmount and run the script again.
	exit 1;
fi

# Create a 1 GB image and a 64 MB image, the later one will be used as swap.
dd if=/dev/zero of=$IMAGE_PATH/node.img bs=1024k count=500

# Change permissions.
chmod 640 $IMAGE_PATH/node.img

# Format the image as ext3.
# Switched to ext2 to see if the nodes will stop crashing!!
mkfs.ext3 -F $IMAGE_PATH/node.img

# Disable time-dependent filesystem checking.
tune2fs -i 0 $IMAGE_PATH/node.img

# Mount the image.
if mount -o loop $IMAGE_PATH/node.img $MOUNT_PATH; then
	echo "Mounted node.img."
else
	echo "Mount failure. Could not mount "$IMAGE_PATH"/node.img at "$MOUNT_PATH
	exit 1;
fi

# Get architecture.
UNAME=`uname -m`
if [ "$UNAME" = "i386" ] || [ "$UNAME" = "i686" ] || [ "$UNAME" = "i586" ]; then
        ARCH=i386
elif [ "$UNAME" = "x86_64" ]; then
        ARCH=amd64
else
        echo "Architecture not supported!"
        exit 1;
fi

# Bootstrap the image.
if [ "`grep "Debian" /etc/issue`" != "" ]; then
	# debian excludes has been removed, changed from i386.
	if ! debootstrap --verbose --arch i386 --include=$INCLUDES $DEBIAN_VERSION $MOUNT_PATH http://ftp.uk.debian.org/debian/; then
		echo "Was not able to install Debian."
		umount $MOUNT_PATH
		exit 1;
	fi
elif [ "`grep "Ubuntu" /etc/issue`" != "" ]; then
	if ! debootstrap --verbose --arch i386 --exclude=$EXCLUDES_UBUNTU --include=$INCLUDES $UBUNTU_VERSION $MOUNT_PATH http://se.archive.ubuntu.com/ubuntu/; then
		echo "Was not able to install Ubuntu."
		umount $MOUNT_PATH
		exit 1;
	fi
else
	echo "Nodes can only be created on a Debian and Ubuntu system."
	exit 1;
fi

# Copy /etc/apt/sources.list to the new image.
cp /etc/apt/sources.list $MOUNT_PATH/etc/apt/

# Check kernel version to be able to copy the kernel modules and configure the configuration template for the nodes.
KERNELVERSION=`uname -r`
# KERNELVERSION override
#KERNELVERSION=2.6.31
echo 'Copying Kernel modules: '$KERNELVERSION

# Copy the kernel modules.
cp -dpR /lib/modules/$KERNELVERSION $MOUNT_PATH/lib/modules/

# Disable Thread-Local Storage.
if [ -e $MOUNT_PATH/lib/tls ];then
	mv $MOUNT_PATH/lib/tls $MOUNT_PATH/lib/tls.disabled
fi

# Get primary DNS of the host.
DNSIP=`grep -m 1 "nameserver" /etc/resolv.conf | awk '{printf $2" ";}'`

# Configure networking for the guest $MOUNT_PATH/etc/network/interfaces
echo '# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
# Uncomment this and configure after the system has booted for the first time
auto eth0
iface eth0 inet static
        address '$NETID'.2
        netmask 255.255.255.0
        broadcast '$NETID'.255
        gateway '$BRIDGEIP'
        dns-nameservers '$DNSIP >> $MOUNT_PATH/etc/network/interfaces

# Create $MOUNT_PATH/etc/hosts
echo '127.0.0.1       localhost localhost.localdomain' >> $MOUNT_PATH/etc/hosts

# Configure $MOUNT_PATH/etc/hosts/
COUNTER=0
IP=10
while [ $COUNTER -lt 100 ]; do
#    echo The counter is $COUNTER
	echo $NETID'.'$IP'       node-'$COUNTER >> $MOUNT_PATH/etc/hosts
	let COUNTER=$COUNTER+1 
	let IP=$IP+1
done

# For simplicity IPv6 is not used right now.

## The following lines are desirable for IPv6 capable hosts
##::1     ip6-localhost ip6-loopback
##fe00::0 ip6-localnet
##ff00::0 ip6-mcastprefix
##ff02::1 ip6-allnodes
##ff02::2 ip6-allrouters
##ff02::3 ip6-allhosts' >> $MOUNT_PATH/etc/hosts

# Create $MOUNT_PATH/etc/hostname
# Hostname is reconfigured at boot time on each node according to the configuration file.
echo node > $MOUNT_PATH/etc/hostname

# Configure default gw
echo "route add default gw $BRIDGEIP" >> $MOUNT_PATH/etc/rc.local

# Create $MOUNT_PATH/etc/fstab
#none		/dev/pts	devpts	defaults	0 0 
#devpts		/dev/pts	devpts	gid=5,mode=620	0 0 
echo 'proc            /proc       proc    defaults    0 0
/dev/sda1       /           ext3    defaults,errors=remount-ro    0 1
/dev/sda2       none        swap    sw          0 0' >> $MOUNT_PATH/etc/fstab

# Remove ttys that are not supported in xen.
if [ "`grep "Debian" /etc/issue`" != "" ]; then
	#awk '{if (match($0,"tty[23456]")) print "#"$0; else print}' /etc/inittab > tmp 
	# Only hvc0 is supported as console in Debian lenny.
	awk '{if (match($0,"tty[23456]")) print "#"$0; else if (match($0,"tty1")) print "1:2345:respawn:/sbin/getty 38400 hvc0\n#"$0; else print}' /etc/inittab > tmp
	mv tmp $MOUNT_PATH/etc/inittab
	rm tmp
elif [ "`grep "Ubuntu" /etc/issue`" != "" ]; then
	rm $MOUNT_PATH/etc/event.d/tty[23456]
else
	echo "Nodes can only be created on a Debian and Ubuntu system."
	exit 1;
fi

# Install testbed specific files on the host.
cd dist
make
cd ..

# Configure NFS path and bridge-IP on the guest system.
cp dist/node/node_config.sh $MOUNT_PATH/etc/init.d

NFSHAGGLEPATH="HAGGLEPATH="$HAGGLE_INSTALL_PATH
NFSIP="NFSIP="$BRIDGEIP

awk '{gsub(/# set HAGGLEPATH/,"'$NFSHAGGLEPATH'");print}' $MOUNT_PATH/etc/init.d/node_config.sh | awk '{gsub(/# set NFSIP/,"'$NFSIP'");print}' > tmp

# Configure kernel cmdline number depending on distribution.
# TODO Debian lenny also reads from $3
#if [ "`grep "Debian" /etc/issue`" != "" ]; then
#	awk '{sub(/\$3/,"$2");print}' tmp > $MOUNT_PATH/etc/init.d/node_config.sh
#elif [ "`grep "Ubuntu" /etc/issue`" != "" ]; then
	awk '{sub(/\$2/,"$3");print}' tmp > $MOUNT_PATH/etc/init.d/node_config.sh
#	echo "Nodes can only be created on a Debian and Ubuntu system."
#	exit 1;
#fi
chmod +x $MOUNT_PATH/etc/init.d/node_config.sh
rm tmp

# Change root to be able to create a new user, set the password for root and update rc.d on the guest image.
#
# Add user $NODE_USERNAME to the guest image.
echo 'Creating user '$NODE_USERNAME' on the node image.'
/usr/sbin/chroot $MOUNT_PATH adduser $NODE_USERNAME
# Set root password on the guest image.
echo 'Set root password for the node image.'
/usr/sbin/chroot $MOUNT_PATH passwd root
# Update rc.d, will make the node run the node_config.sh script during boot.
/usr/sbin/chroot $MOUNT_PATH update-rc.d node_config.sh defaults

# Create keys and copy to node or, if id_rsa.pub exists, only copy.
if [ -f /home/$USER/.ssh/id_rsa.pub ]; then
	mkdir $MOUNT_PATH/home/$NODE_USERNAME/.ssh
	cp /home/$USER/.ssh/id_rsa.pub $MOUNT_PATH/home/$NODE_USERNAME/.ssh/authorized_keys
else
	mkdir $MOUNT_PATH/home/$NODE_USERNAME/.ssh
	sudo -u $USER bash -c "ssh-keygen -t rsa"
	cp /home/$USER/.ssh/id_rsa.pub $MOUNT_PATH/home/$NODE_USERNAME/.ssh/authorized_keys
fi

# Configure: sshd without DNS usage.
echo "UseDNS no" >> $MOUNT_PATH/etc/ssh/sshd_config

# Remove /root/.ssh/known_hosts since the finger print changes each time
# a new node is created.
rm /home/$USER/.ssh/known_hosts &>/dev/null

# NFS mount directories. The existens of these directories are not checked 
# since we can be sure that they do not exist.
mkdir $MOUNT_PATH/home/$NODE_USERNAME/.Haggle
mkdir $MOUNT_PATH/usr/local/haggle

# Change owner of directories and files created in /home/$NODE_USERNAME
/usr/sbin/chroot $MOUNT_PATH chown -R $NODE_USERNAME:$NODE_USERNAME /home/$NODE_USERNAME/.ssh
/usr/sbin/chroot $MOUNT_PATH chown -R $NODE_USERNAME:$NODE_USERNAME /home/$NODE_USERNAME/.Haggle

# Set PATH to haggle on the node.
HAGGLE_BIN_PATH="HAGGLE_BIN_PATH="$HAGGLE_INSTALL_PATH/bin
awk '{gsub(/# set HAGGLE_BIN_PATH/,"'$HAGGLE_BIN_PATH'");print}' dist/node/.bashrc > $MOUNT_PATH/home/$NODE_USERNAME/.bashrc
/usr/sbin/chroot $MOUNT_PATH chown $NODE_USERNAME:$NODE_USERNAME /home/$NODE_USERNAME/.bashrc

# Unmount the image.
umount $MOUNT_PATH

# Change owner of the image to be able to make copies.
echo "Changing owner of the image file."
chown $USER:$USER $IMAGE_PATH/node.img

echo "NODE_USERNAME="$NODE_USERNAME > ../script/node.conf

# Begin host configuration.
echo "Configuring the host system."
# Add line in modprobe to enable additional loopback devices.
# /etc/modprobe.d/options in ubuntu.
# TODO add debian solution
if [ "`grep 'options loop max_loop=512' /etc/modprobe.d/options`" = "" ]; then
	echo 'options loop max_loop=512' >> /etc/modprobe.d/options
fi

# To be able to loop mount in debian 5.0.2 this line have to be added.
# To be able to start guest nodes without reboot, run modprobe dm-mod.
modprobe dm-mod
if [ "`grep 'dm-mod' /etc/modules`" = "" ]; then
	echo 'dm-mod' >> /etc/modules
fi

# Check bridge config, if ! IP = BRIDGEIP config BRIDGENAME.
IP=`ifconfig $BRIDGENAME | grep "inet addr"`
IP=${IP##*inet addr:}
IP=${IP%%  B*}

if [ "$IP" != "$BRIDGEIP" ]; then
	echo Configuring $BRIDGENAME
	ifconfig $BRIDGENAME $BRIDGEIP
fi

# Bridge configuration.
# Add a bridging interface to /etc/network/interfaces
if [ "`grep 'auto '${BRIDGENAME} /etc/network/interfaces`" = "" ]; then
	echo 'auto '$BRIDGENAME'
	iface '$BRIDGENAME' inet static
   		pre-up brctl addbr '$BRIDGENAME'
   		post-down brctl delbr '$BRIDGENAME'
   		post-up iptables -t nat -F
   		post-up iptables -t nat -A POSTROUTING -o eth0 -s '$NETID'.0/24 -j MASQUERADE
   		address '$BRIDGEIP'
   		netmask 255.255.255.0
   		bridge_fd 0
   		bridge_hello 0
   		bridge_stp off' >> /etc/network/interfaces
fi

# Enable forwarding. NOTE: Not necessary if useDNS no is configured in the node. 
# TODO Only work on ubuntu
#echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
# debian
#echo 1 > /proc/sys/net/ipv4/ip_forwaring


# Set NFS export directories.
if [ "`grep \"${HAGGLE_INSTALL_PATH} ${NETID}.0/255.255.255.0(ro)\" /etc/exports`" = "" ]; then
	echo $HAGGLE_INSTALL_PATH $NETID'.0/255.255.255.0(ro)' >> /etc/exports
fi

# Setting StrictHostKeyChacking no in /etc/ssh/ssh_config to be able to
# login to a new node without answering if the finger print should be
# added in known_hosts.
if [ "`grep 'StrictHostKeyChecking no' /etc/ssh/ssh_config`" = "" ]; then
	echo "Setting StrictHostKeyChecking no in /etc/ssh/ssh_config"
	echo "	StrictHostKeyChecking no" >> /etc/ssh/ssh_config
fi

# Configure /etc/hosts

if [ "`grep "${NETID}.99" /etc/hosts`" = "" ]; then
	COUNTER=0
	IP=10
	while [ $COUNTER -lt 100 ]; do
		echo $NETID'.'$IP'       node-'$COUNTER >> /etc/hosts
    		let COUNTER=$COUNTER+1 
		let IP=$IP+1
	done
fi



# Create a config file template.
echo 'kernel = "/boot/vmlinuz-'$KERNELVERSION'"' > $CONFIG_PATH/node-xencfg.template
echo 'ramdisk = "/boot/initrd.img-'$KERNELVERSION'"' >> $CONFIG_PATH/node-xencfg.template
echo 'memory = 64' >> $CONFIG_PATH/node-xencfg.template
echo 'name = "$NODENAME"' >> $CONFIG_PATH/node-xencfg.template
echo 'vif = [ "mac=00:34:34:34:34:$NODENO, bridge='$BRIDGENAME'" ]' >> $CONFIG_PATH/node-xencfg.template
echo 'disk = [ "file:'$IMAGE_PATH'/$NODENAME.img,xvda1,w" ]' >> $CONFIG_PATH/node-xencfg.template
#echo 'disk = [ "cow:'$IMAGE_PATH'/node.img 128,sda1,w", "file:'$SWAP_PATH'/$NODENAME-swap.img,sda2,w" ]' >> $CONFIG_PATH/node-xencfg.template
echo 'ip = "'$NETID'.$IP"' >> $CONFIG_PATH/node-xencfg.template
echo 'netmask = "255.255.255.0"' >> $CONFIG_PATH/node-xencfg.template
echo 'gateway = "'$BRIDGEIP'"' >> $CONFIG_PATH/node-xencfg.template
echo 'hostname = "$NODENAME"' >> $CONFIG_PATH/node-xencfg.template
echo 'root = "/dev/xvda1 ro"' >> $CONFIG_PATH/node-xencfg.template

# Add 'extra', should be "xencons=tty" for gutsy.
if [ "`grep "Ubuntu" /etc/issue`" != "" ] && [ $UBUNTU_VERSION = "gutsy" ]; then
	echo 'extra = "xencons=tty"' >> $CONFIG_PATH/node-xencfg.template
fi

# Add 'extra', should be "xencon=tty1" for hardy.
if [ "`grep "Ubuntu" /etc/issue`" != "" ] && [ $UBUNTU_VERSION = "hardy" ]; then
	echo 'extra = "xencon=tty1"' >> $CONFIG_PATH/node-xencfg.template
fi
chown $USER:$USER $CONFIG_PATH/node-xencfg.template
