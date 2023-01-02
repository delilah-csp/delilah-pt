#!/bin/bash
# Force locale language to be set to English. This avoids issues when doing
# text and string processing.
export LANG=C

# Determine the absolute path to the executable
# EXE will have the PWD removed so we can concatenate with the PWD safely
PWD=`pwd`
EXE=`echo $0 | sed s=$PWD==`
EXEPATH="$PWD"/"$EXE"
clear
cat << EOM

EOM

AMIROOT=`whoami | awk {'print $1'}`
if [ "$AMIROOT" != "root" ] ; then

	echo "	**** Error *** must run script with sudo"
	echo ""
	exit
fi

#Precentage function
untar_progress ()
{
    TARBALL=$1;
    DIRECTPATH=$2;
    BLOCKING_FACTOR=$(($(xz --robot --list ${TARBALL} | grep 'totals' | awk '{print $5}') / 51200 + 1));
    tar --blocking-factor=${BLOCKING_FACTOR} --checkpoint=1 --checkpoint-action='ttyout=Written %u%  \r' -Jxf ${TARBALL} -C ${DIRECTPATH}
}

#copy/paste programs
cp_progress ()
{
	CURRENTSIZE=0
	while [ $CURRENTSIZE -lt $TOTALSIZE ]
	do
		TOTALSIZE=$1;
		TOHERE=$2;
		CURRENTSIZE=`sudo du -c $TOHERE | grep total | awk {'print $1'}`
		echo -e -n "$CURRENTSIZE /  $TOTALSIZE copied \r"
		sleep 1
	done
}

check_for_sdcards()
{
        # find the avaible SD cards
        ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-8`
        PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n ''`
        if [ "$PARTITION_TEST" = "" ]; then
	        echo -e "Please insert a SD card to continue\n"
	        while [ "$PARTITION_TEST" = "" ]; do
		        read -p "Type 'y' to re-detect the SD card or 'n' to exit the script: " REPLY
		        if [ "$REPLY" = 'n' ]; then
		            exit 1
		        fi
		        ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-8`
		        PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n ''`
	        done
        fi
}

# find the avaible SD cards
ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-9`
if [ "$ROOTDRIVE" = "root" ]; then
    ROOTDRIVE=`readlink /dev/root | cut -c1-3`
else
    ROOTDRIVE=`echo $ROOTDRIVE | cut -c1-3`
fi

PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n ''`

# Check for available mounts
check_for_sdcards

echo -e "\nAvailable Drives to write images to: \n"
echo "#  major   minor    size   name "
cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n ''
echo " "

DEVICEDRIVENUMBER=
while true;
do
	read -p 'Enter Device Number or 'n' to exit: ' DEVICEDRIVENUMBER
	#DEVICEDRIVENUMBER="1"
	echo " "
        if [ "$DEVICEDRIVENUMBER" = 'n' ]; then
                exit 1
        fi

        if [ "$DEVICEDRIVENUMBER" = "" ]; then
                # Check to see if there are any changes
                check_for_sdcards
                echo -e "These are the Drives available to write images to:"
                echo "#  major   minor    size   name "
                cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n ''
                echo " "
               continue
        fi

	DEVICEDRIVENAME=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n '' | grep "${DEVICEDRIVENUMBER}:" | awk '{print $5}'`
	if [ -n "$DEVICEDRIVENAME" ]
	then
	        DRIVE=/dev/$DEVICEDRIVENAME
	        DEVICESIZE=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n '' | grep "${DEVICEDRIVENUMBER}:" | awk '{print $4}'`
		break
	else
		echo -e "Invalid selection!"
                # Check to see if there are any changes
                check_for_sdcards
                echo -e "These are the only Drives available to write images to: \n"
                echo "#  major   minor    size   name "
                cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n ''
                echo " "
	fi
done

DRIVE=/dev/$DEVICEDRIVENAME
NUM_OF_DRIVES=`df | grep -c $DEVICEDRIVENAME`

# This if statement will determine if we have a mounted sdX or mmcblkX device.
# If it is mmcblkX, then we need to set an extra char in the partition names, 'p',
# to account for /dev/mmcblkXpY labled partitions.
if [[ ${DEVICEDRIVENAME} =~ ^sd. ]]; then
	echo "$DRIVE is an sdx device"
	P=''
else
	echo "$DRIVE is an mmcblkx device"
	P='p'
fi

if [ "$NUM_OF_DRIVES" != "0" ]; then
        echo "Unmounting the $DEVICEDRIVENAME drives"
        for ((c=1; c<="$NUM_OF_DRIVES"; c++ ))
        do
                unmounted=`df | grep '\<'$DEVICEDRIVENAME$P$c'\>' | awk '{print $1}'`
                if [ -n "$unmounted" ]
                then
                     echo " unmounted ${DRIVE}$P$c"
                     sudo umount -f ${DRIVE}$P$c
                fi

        done
fi

# Refresh this variable as the device may not be mounted at script instantiation time
# This will always return one more then needed
NUM_OF_PARTS=`cat /proc/partitions | grep -v $ROOTDRIVE | grep -c $DEVICEDRIVENAME`
for ((c=1; c<"$NUM_OF_PARTS"; c++ ))
do
        SIZE=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<'$DEVICEDRIVENAME$P$c'\>'  | awk '{print $3}'`
        echo "Current size of $DEVICEDRIVENAME$P$c $SIZE bytes"
done

# check to see if the device is already partitioned
for ((  c=1; c<5; c++ ))
do
	eval "SIZE$c=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<'$DEVICEDRIVENAME$P$c'\>'  | awk '{print $3}'`"
done

PARTITION="0"
if [ -n "$SIZE1" -a -n "$SIZE2" ] ; then
	if  [ "$SIZE1" -gt "72000" -a "$SIZE2" -gt "700000" ]
	then
		PARTITION=1

		if [ -z "$SIZE3" -a -z "$SIZE4" ]
		then
			#Detected 2 partitions
			PARTS=2

		elif [ "$SIZE3" -gt "1000" -a -z "$SIZE4" ]
		then
			#Detected 3 partitions
			PARTS=3

		else
			echo "SD Card is not correctly partitioned"
			PARTITION=0
		fi
	fi
else
	echo "SD Card is not correctly partitioned"
	PARTITION=0
	PARTS=0
fi


#Partition is found
if [ "$PARTITION" -eq "1" ]
then
cat << EOM

################################################################################

   Detected device has $PARTS partitions already

   Re-partitioning will allow the choice of 2 or 3 partitions

################################################################################

EOM

	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		read -p 'Would you like to re-partition the drive anyways [y/n] : ' CASEPARTITION
		echo ""
		echo " "
		ENTERCORRECTLY=1
		case $CASEPARTITION in
		"y")  echo "Now partitioning $DEVICEDRIVENAME ...";PARTITION=0;;
		"n")  echo "Skipping partitioning";;
		*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
		esac
		echo ""
	done

fi

#Partition is not found, choose to partition 2 or 3 segments
if [ "$PARTITION" -eq "0" ]
then
cat << EOM

################################################################################

	Select 2 partitions if only need boot and rootfs (most users).
	Select 3 partitions if need SDK & other content on SD card.  This is
        usually used by device manufacturers with access to partition tarballs.

	****WARNING**** continuing will erase all data on $DEVICEDRIVENAME

################################################################################

EOM
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do

		#read -p 'Number of partitions needed [2/3] : ' CASEPARTITIONNUMBER
		CASEPARTITIONNUMBER="2"
		echo ""
		echo " "
		ENTERCORRECTLY=1
		case $CASEPARTITIONNUMBER in
		"2")  echo "Now partitioning $DEVICEDRIVENAME with 2 partitions...";PARTITION=2;;
		"3")  echo "Now partitioning $DEVICEDRIVENAME with 3 partitions...";PARTITION=3;;
		"n")  exit;;
		*)  echo "Please enter 2 or 3";ENTERCORRECTLY=0;;
		esac
		echo " "
	done
fi

#create only 2 partitions
if [ "$PARTITION" -eq "2" ]
then

# Set the PARTS value as well
PARTS=2
cat << EOM

################################################################################

		Now making 2 partitions

################################################################################

EOM
#dd if=/dev/zero of=$DRIVE bs=1024 count=1024

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`

#sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE << EOF
#sfdisk $DRIVE << EOF
#start=1MiB size=1GiB bootable type=L
#start=2GiB size=4GiB type=L
#EOF

SD_DUMP_FILE=sd.dump
SD_DUMP_FILE_BAK=sd.dump.bak
sed 's/sd./$DRIVE/g' $SD_DUMP_FILE > $SD_DUMP_FILE_BAK

sfdisk $DRIVE < $SD_DUMP_FILE_BAK

cat << EOM

################################################################################

		Partitioning Boot

################################################################################
EOM
	mkfs.vfat -F 32 -n "boot" ${DRIVE}${P}1
cat << EOM

################################################################################

		Partitioning rootfs

################################################################################
EOM
	mkfs.ext3 -L "rootfs" ${DRIVE}${P}2
	sync
	sync
	INSTALLSTARTHERE=n
fi

#Break between partitioning and installing file system
cat << EOM

################################################################################

   Partitioning is now done
   Continue to install filesystem or select 'n' to safe exit

   **Warning** Continuing will erase files any files in the partitions

################################################################################

EOM
ENTERCORRECTLY=0
while [ $ENTERCORRECTLY -ne 1 ]
do
	#read -p 'Would you like to continue? [y/n] : ' EXITQ
	EXITQ="y"
	echo ""
	echo " "
	ENTERCORRECTLY=1
	case $EXITQ in
	"y") ;;
	"n") exit;;
	*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
	esac
done

#Add directories for images
export START_DIR=$PWD
mkdir $START_DIR/tmp
export PATH_TO_SDBOOT=boot
export PATH_TO_SDROOTFS=rootfs
export PATH_TO_TMP_DIR=$START_DIR/tmp

echo " "
echo "Mount the partitions "
mkdir $PATH_TO_SDBOOT
mkdir $PATH_TO_SDROOTFS

sudo mount -t vfat ${DRIVE}${P}1 boot/
sudo mount -t ext3 ${DRIVE}${P}2 rootfs/

echo " "
echo "Emptying partitions "
echo " "
sudo rm -rf  $PATH_TO_SDBOOT/*
sudo rm -rf  $PATH_TO_SDROOTFS/*

echo ""
echo "Syncing...."
echo ""
sync
sync
sync

cat << EOM
################################################################################

	Choose file path to install from

	1 ) Install pre-built images from SDK
	2 ) Enter in custom boot and rootfs file paths

################################################################################

EOM
ENTERCORRECTLY=0
while [ $ENTERCORRECTLY -ne 1 ]
do
	#read -p 'Choose now [1/2] : ' FILEPATHOPTION
	FILEPATHOPTION="2"
	echo ""
	echo " "
	ENTERCORRECTLY=1
	case $FILEPATHOPTION in
	"1") echo "Will now install from SDK pre-built images";;
	"2") echo "";;
	*)  echo "Please enter 1 or 2";ENTERCORRECTLY=0;;
	esac
done

# SDK DEFAULTS
if [ $FILEPATHOPTION -eq 2  ] ; then
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		#read -e -p 'Enter path for Boot Partition : '  BOOTUSERFILEPATH
		BOOTUSERFILEPATH="SD_image"

		echo ""
		ENTERCORRECTLY=1
		if [ -f $BOOTUSERFILEPATH ]
		then
			echo "File exists"
			echo ""
		elif [ -d $BOOTUSERFILEPATH ]
		then
			echo "Directory exists"
			echo ""
			echo "This directory contains:"
			ls $BOOTUSERFILEPATH
			echo ""
			#read -p 'Is this correct? [y/n] : ' ISRIGHTPATH
			ISRIGHTPATH="y"
				case $ISRIGHTPATH in
				"y") ;;
				"n") ENTERCORRECTLY=0;;
				*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
				esac
		else
			echo "Invalid path make sure to include complete path"

			ENTERCORRECTLY=0
		fi
	done


cat << EOM


################################################################################

   For Kernel Image and Device Trees files

    What would you like to do?
     1) Reuse kernel image and device tree files found in the selected rootfs.
     2) Provide a directory that contains the kernel image and device tree files
        to be used.

################################################################################

EOM

ENTERCORRECTLY=0
while [ $ENTERCORRECTLY -ne 1 ]
do

	#read -p 'Choose option 1 or 2 : ' CASEOPTION
	CASEOPTION="2"
	echo ""
	echo " "
	ENTERCORRECTLY=1
	case $CASEOPTION in
		"1")  echo "Reusing kernel and dt files from the rootfs's boot directory";KERNELFILESOPTION=1;;
		"2")  echo "Choosing a directory that contains the kernel files to be used";KERNELFILESOPTION=2;;
		"n")  exit;;
		*)  echo "Please enter 1 or 2";ENTERCORRECTLY=0;;
	esac
	echo " "
done

if [ $KERNELFILESOPTION == 2 ]
then

cat << EOM
################################################################################

  For Kernel Image and Device Trees files

  The kernel image name should contain the image type uImage or zImage depending
  on which format is used.

  The device tree files must end with .dtb
      e.g    am335x-evm.dtb am43x-gp-evm.dtb


################################################################################

EOM
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		#read -e -p 'Enter path for kernel image and device tree files : '  KERNELUSERFILEPATH
		KERNELUSERFILEPATH="SD_image"

		echo ""
		ENTERCORRECTLY=1

		if [ -d $KERNELUSERFILEPATH ]
		then
			echo "Directory exists"
			echo ""
			echo "This directory contains:"
			ls $KERNELUSERFILEPATH
			echo ""
			#read -p 'Is this correct? [y/n] : ' ISRIGHTPATH
			ISRIGHTPATH="y"
			case $ISRIGHTPATH in
				"y") ;;
				"n") ENTERCORRECTLY=0;;
				*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
				esac
		else
			echo "Invalid path make sure to include complete path"
			ENTERCORRECTLY=0
		fi
	done
fi

cat << EOM


################################################################################

   For Rootfs partition

   If files are located in Tarball write complete path including the file name.
      e.x. $:  /home/user/MyCustomTars/rootfs.tar.xz

  If files are located in a directory write the directory path
      e.x. $: /ti-sdk/targetNFS/

################################################################################

EOM
	ENTERCORRECTLY=0
	while [ $ENTERCORRECTLY -ne 1 ]
	do
		#read -e -p 'Enter path for Rootfs Partition : ' ROOTFSUSERFILEPATH
		ROOTFSUSERFILEPATH="SD_image/rootfs.tar.gz"
		echo ""
		ENTERCORRECTLY=1
		if [ -f $ROOTFSUSERFILEPATH ]
		then
			echo "File exists"
			echo ""
		elif [ -d $ROOTFSUSERFILEPATH ]
		then
			echo "This directory contains:"
			ls $ROOTFSUSERFILEPATH
			echo ""
			#read -p 'Is this correct? [y/n] : ' ISRIGHTPATH
			ISRIGHTPATH="y"
				case $ISRIGHTPATH in
				"y") ;;
				"n") ENTERCORRECTLY=0;;
				*)  echo "Please enter y or n";ENTERCORRECTLY=0;;
				esac

		else
			echo "Invalid path make sure to include complete path"

			ENTERCORRECTLY=0
		fi
	done
	echo ""


	# Check if user entered a tar or not for Boot
	ISBOOTTAR=`ls $BOOTUSERFILEPATH | grep .tar.xz | awk {'print $1'}`
	if [ -n "$ISBOOTTAR" ]
	then
		BOOTPATHOPTION=2
	else
		BOOTPATHOPTION=1
		BOOTFILEPATH=$BOOTUSERFILEPATH
		BOOTBIN=`ls $BOOTFILEPATH | grep BOOT | awk {'print $1'}`
	fi


	if [ "$KERNELFILESOPTION" == "2" ]
	then
		KERNELIMAGE=`ls $KERNELUSERFILEPATH | grep image | awk {'print $1'}`
	fi


	#Check if user entered a tar or not for Rootfs
	ISROOTFSTAR=`ls $ROOTFSUSERFILEPATH | grep .tar.xz | awk {'print $1'}`
	if [ -n "$ISROOTFSTAR" ]
	then
		ROOTFSPATHOPTION=2
	else
		ROOTFSPATHOPTION=1
		ROOTFSFILEPATH=$ROOTFSUSERFILEPATH
	fi
fi

cat << EOM
################################################################################

	Copying files now... will take minutes

################################################################################

Copying boot partition
EOM

echo "Boot Partition BOOTPATHOPTION is $BOOTPATHOPTION"

if [ $BOOTPATHOPTION -eq 1 ] ; then

	echo ""
	#copy boot files out of board support

	if [ "$BOOTBIN" != "" ] ; then
		cp $BOOTFILEPATH/$BOOTBIN $PATH_TO_SDBOOT/
		echo "BOOT.bin copied"
	else
		echo "No BOOT.bin file found"
	fi

elif [ $BOOTPATHOPTION -eq 2  ] ; then
	untar_progress $BOOTUSERFILEPATH $PATH_TO_TMP_DIR
	cp -rf $PATH_TO_TMP_DIR/* $PATH_TO_SDBOOT
	echo ""

fi

echo ""
sync

if [ "$KERNELFILESOPTION" == "2" ]
then

	if [ "$KERNELIMAGE" != "" ] ; then

		cp -f $KERNELUSERFILEPATH/$KERNELIMAGE $PATH_TO_SDBOOT
		echo "Kernel image copied"
	else
		echo "$KERNELIMAGE file not found"
	fi
fi

echo "Copying rootfs System partition"
sudo tar xvf $ROOTFSUSERFILEPATH -C $PATH_TO_SDROOTFS

echo ""
echo ""
echo "Syncing..."
sync
sync
sync
sync
sync
sync
sync
sync


echo " "
echo "Un-mount the partitions "
sudo umount -f $PATH_TO_SDBOOT
sudo umount -f $PATH_TO_SDROOTFS


echo " "
echo "Remove created temp directories "
sudo rm -rf $PATH_TO_TMP_DIR
sudo rm -rf $PATH_TO_SDROOTFS
sudo rm -rf $PATH_TO_SDBOOT

echo " "
echo "Operation Finished"
echo " "
