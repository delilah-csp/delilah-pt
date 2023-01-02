SRC_URI += "file://bsp.cfg \
            file://0001-Fix-SPI-NOR-Flash-size-problem.patch \
            file://0002-Remove-PCIe-compile-error.patch \
            file://0003-Remove-PCIe-compile-error.patch \
            file://user_2019-11-01-15-49-00.cfg \
            file://user_2019-11-01-16-14-00.cfg \
            file://user_2019-11-05-20-05-00.cfg \
            file://user_2022-04-07-13-19-00.cfg \
            file://user_2022-04-08-15-32-00.cfg \
            file://user_2022-04-08-16-28-00.cfg \
            file://user_2022-04-08-16-38-00.cfg \
            file://user_2022-12-14-13-43-00.cfg \
            "

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
