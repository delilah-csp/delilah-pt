#!/bin/sh

BOOT_DIR=/media/hgchoe/boot
ROOTFS_DIR=/media/hgchoe/rootfs

echo mkdir -p $ROOTFS_DIR/home/root/update_image/
mkdir -p $ROOTFS_DIR/home/root/update_image/

echo cp QSPI_image/BOOT.BIN $ROOTFS_DIR/home/root/update_image/
cp QSPI_image/BOOT.BIN $ROOTFS_DIR/home/root/update_image/

echo cp QSPI_image/image.ub $ROOTFS_DIR/home/root/update_image/
cp QSPI_image/image.ub $ROOTFS_DIR/home/root/update_image/

echo "Copy Fusing QSPI Upgrade script"
cp $ROOTFS_DIR/home/root/S99_Fusing_QSPI_FS.sh $ROOTFS_DIR/etc/rcS.d/
 
echo sync
sync
sync

umount /media/hgchoe/*
