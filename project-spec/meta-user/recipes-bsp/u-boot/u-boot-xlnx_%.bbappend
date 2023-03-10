SRC_URI_append = " file://platform-top.h"
SRC_URI += "file://bsp.cfg \
            file://user_2019-11-07-10-32-00.cfg \
            "

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-Reduce-SDHCI-CMD-Timeout.patch \
            file://0002-Add-W25M512JV-to-UBOOT.patch \
            file://0003-Control-M.2-PWR-RST-through-GPIO.patch \
            file://0004-Init-PL-DDR4.patch \
           "
