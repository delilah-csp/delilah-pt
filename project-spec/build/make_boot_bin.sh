#!/bin/sh

FSBL=zynqmp_fsbl.elf
#FSBL=zynqmp_fsbl_sdk.elf
PMUFW=pmufw.elf
FPGA=system.bit
ATF=bl31.elf
UBOOT=u-boot.elf

echo petalinux-package --boot  --fsbl ${FSBL} --pmufw ${PMUFW} --fpga ${FPGA} --atf ${ATF} -u-boot ${UBOOT} --force
cd ../../images/linux
#cp ../../pre-built/linux/images/zynqmp_fsbl.elf .
petalinux-package --boot  --fsbl ${FSBL} --pmufw ${PMUFW} --fpga ${FPGA} --atf ${ATF} --u-boot ${UBOOT} --force
cd ../../project-spec/build
