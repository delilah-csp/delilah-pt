DESCRIPTION = "PETALINUX image definition for Xilinx boards"
LICENSE = "MIT"

require recipes-core/images/petalinux-image-common.inc 

inherit extrausers 
COMMON_FEATURES = "\
		ssh-server-dropbear \
		hwcodecs \
		debug-tweaks \
		"
IMAGE_LINGUAS = " "

IMAGE_INSTALL = "\
		kernel-modules \
		e2fsprogs \
		e2fsprogs-mke2fs \
		libss \
		libcomerr \
		libext2fs \
		libe2p \
		e2fsprogs-e2fsck \
		e2fsprogs-badblocks \
		mtd-utils \
		mtd-utils-jffs2 \
		mtd-utils-misc \
		mtd-utils-dev \
		mtd-utils-ubifs \
		mtd-utils-dbg \
		util-linux \
		util-linux-fsck \
		util-linux-umount \
		util-linux-mount \
		util-linux-blkid \
		util-linux-mkfs \
		util-linux-fdisk \
		nfs-utils \
		nfs-utils-stats \
		nfs-utils-dbg \
		nfs-utils-dev \
		nfs-utils-client \
		openssh-sftp-server \
		pciutils \
		libpci \
		pciutils-ids \
		run-postinsts \
		cpufrequtils \
		udev-extraconf \
		gdb \
		gdb-dev \
		packagegroup-core-boot \
		packagegroup-core-ssh-dropbear \
		perf \
		tcf-agent \
		watchdog-init \
		bridge-utils \
		hellopm \
		packagegroup-petalinux-benchmarks \
		delilah \
		dimm-test \
		udmabuf \
		nvme-cli \
		fio \
		"
EXTRA_USERS_PARAMS = "usermod -P root root;"
