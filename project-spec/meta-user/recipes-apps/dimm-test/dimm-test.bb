#
# This file is the dimm-test recipe.
#

SUMMARY = "Simple dimm-test application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://dimm-test.c \
	   file://Makefile \
	   file://memory_config_g.c \
	   file://memory_config.h \
	   file://memorytest.c \
	   file://xil_testmem.c \
	   file://xil_testmem.h \
	   file://xil_types.h \
	   file://xil_io.h \
	   file://xil_assert.c \
	   file://xil_assert.h \
	   file://xstatus.h \
		  "

S = "${WORKDIR}"

do_compile() {
	     oe_runmake
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 dimm-test ${D}${bindir}
}
