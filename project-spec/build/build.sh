#!/bin/sh

IMG_SRC=../../images/linux

SD_IMG_DEST_1=../image/SD_image
SD_IMG_DEST_2=/nfs/tmp/SD_image

QSPI_IMG_DEST_1=../image/QSPI_image
QSPI_IMG_DEST_2=/nfs/tmp/QSPI_image

mkdir -p ${SD_IMG_DEST_1}
mkdir -p ${SD_IMG_DEST_2}

mkdir -p ${QSPI_IMG_DEST_1}
mkdir -p ${QSPI_IMG_DEST_2}

START_TIME=`date +%s`

case "$1" in
sd)
	echo "Building SD Boot..."
	cp -a config_sd ../configs/config
	cd ../..
	petalinux-config --oldconfig
	petalinux-build
	cd project-spec/build
	./make_boot_bin.sh
	cp -a ${IMG_SRC}/BOOT.BIN ${SD_IMG_DEST_1}
	cp -a ${IMG_SRC}/image.ub ${SD_IMG_DEST_1}

	cp -a ${IMG_SRC}/BOOT.BIN ${SD_IMG_DEST_2}
	cp -a ${IMG_SRC}/image.ub ${SD_IMG_DEST_2}

	cp -a ${IMG_SRC}/rootfs.tar.gz ${SD_IMG_DEST_1}
	;;
qspi)
	echo "Building QSPI Boot..."
	cp -a config_qspi ../configs/config
	cd ../..
	petalinux-config --oldconfig
	petalinux-build
	cd project-spec/build
	./make_boot_bin.sh
	cp -a ${IMG_SRC}/BOOT.BIN ${QSPI_IMG_DEST_1}
	cp -a ${IMG_SRC}/image.ub ${QSPI_IMG_DEST_1}

	cp -a ${IMG_SRC}/BOOT.BIN ${QSPI_IMG_DEST_2}
	cp -a ${IMG_SRC}/image.ub ${QSPI_IMG_DEST_2}
	;;
all|*)
	echo "Building SD Boot..."
	cp -a config_sd ../configs/config
	cd ../..
	petalinux-config --oldconfig
	petalinux-build
	cd project-spec/build
	./make_boot_bin.sh
	cp -a ${IMG_SRC}/BOOT.BIN ${SD_IMG_DEST_1}
	cp -a ${IMG_SRC}/image.ub ${SD_IMG_DEST_1}

	cp -a ${IMG_SRC}/BOOT.BIN ${SD_IMG_DEST_2}
	cp -a ${IMG_SRC}/image.ub ${SD_IMG_DEST_2}

	cp -a ${IMG_SRC}/rootfs.tar.gz ${SD_IMG_DEST_1}

	echo "Building QSPI Boot..."
	cp -a config_qspi ../configs/config
	cd ../..
	petalinux-config --oldconfig
	petalinux-build
	cd project-spec/build
	./make_boot_bin.sh
	cp -a ${IMG_SRC}/BOOT.BIN ${QSPI_IMG_DEST_1}
	cp -a ${IMG_SRC}/image.ub ${QSPI_IMG_DEST_1}

	cp -a ${IMG_SRC}/BOOT.BIN ${QSPI_IMG_DEST_2}
	cp -a ${IMG_SRC}/image.ub ${QSPI_IMG_DEST_2}
	;;
esac

echo "Build Done."

END_TIME=`date +%s`
echo "Total compile time is $((($END_TIME-$START_TIME)/60)) minutes $((($END_TIME-$START_TIME)%60)) seconds"
