#!/usr/bin/env python3
import math

prog_slots = 8
prog_size = 8 * 1024 * 1024

data_slots = 4
data_size = 128 * 1024 * 1024

high_counter = 0x10
low_counter = 0x0

ddr_size = 16 * 1024 * 1024 * 1024
ddr0_high = 0x10
ddr0_low = 0x0

bar_size = 32 * 1024 * 1024
bar_high = 0x0
bar_low = 0x10000000

cma_size = 1024 * 1024 * 1024

dts = "/ {\n"
dts += "    memory {\n"
dts += "        device_type = \"memory\";\n"
dts += f"        reg = <0x0 0x0 0x0 0x7ff00000>, <{hex(ddr0_high)} {hex(ddr0_low)} {hex(math.floor(ddr_size / 0x100000000))} {hex(ddr_size % 0x100000000)}>;\n"
dts += "    };\n\n"

dts += "    reserved-memory {\n"
dts += "        #address-cells = <2>;\n"
dts += "        #size-cells = <2>;\n"
dts += "        ranges;\n\n"

dts += f"        delilah_bar: delilah@0 {{\n"
dts += "            compatible = \"shared-dma-pool\";\n"
dts += "            reusable;\n"
dts += f"            reg = <{hex(bar_high)} {hex(bar_low)} 0x0 {hex(bar_size)}>;\n"
dts += f"            label = \"delilah_bar\";\n"
dts += "        };\n\n"

for i in range(prog_slots):
    dts += f"        delilah_p{i}: delilah@p{i} {{\n"
    dts += "            compatible = \"shared-dma-pool\";\n"
    dts += "            reusable;\n" # no-map for DMA, reusable for CMA
    dts += f"            reg = <{hex(high_counter)} {hex(low_counter)} 0x0 {hex(prog_size)}>;\n"
    dts += f"            label = \"delilah_p{i}\";\n"
    dts += "        };\n\n"

    low_counter += prog_size
    if low_counter >= 0x100000000:
        low_counter = low_counter - 0x100000000
        high_counter += 1

for i in range(data_slots):
    dts += f"        delilah_d{i}: delilah@d{i} {{\n"
    dts += "            compatible = \"shared-dma-pool\";\n"
    dts += "            reusable;\n" # no-map for DMA, reusable for CMA
    dts += f"            reg = <{hex(high_counter)} {hex(low_counter)} 0x0 {hex(data_size)}>;\n"
    dts += f"            label = \"delilah_d{i}\";\n"
    dts += "        };\n\n"

    low_counter += data_size
    if low_counter >= 0x100000000:
        low_counter = low_counter - 0x100000000
        high_counter += 1

dts += "        cma0: cma@0 {\n"
dts += "            compatible = \"shared-dma-pool\";\n"
dts += "            reusable;\n"
dts += f"            reg = <{hex(high_counter)} {hex(low_counter)} 0x0 {hex(cma_size)}>;\n"
dts += "            linux,cma-default;\n"
dts += "        };\n\n"

low_counter += cma_size
if low_counter >= 0x100000000:
    low_counter = low_counter - 0x100000000
    high_counter += 1

ddr_left_high = math.floor((ddr_size - (data_size * data_slots) - (prog_size * prog_slots) - cma_size) / 0x100000000)
ddr_left_low = math.floor((ddr_size - (data_size * data_slots) - (prog_size * prog_slots) - cma_size) % 0x100000000)

dts += "        ddr_rest {\n"
dts += f"            reg = <{hex(high_counter)} {hex(low_counter)} {hex(ddr_left_high)} {hex(ddr_left_low)}>;\n"
dts += "        };\n\n"

dts += "    };\n\n"

dts += "    udma_bar {\n"
dts += "        compatible = \"ikwzm,u-dma-buf\";\n"
dts += "        device-name = \"delilah_bar0\";\n"
dts += f"        size = <0x0 {hex(bar_size)}>;\n"
dts += "        memory-region = <&delilah_bar>;\n"
dts += "        sync-mode = <1>;\n"
dts += "        sync-always;\n"
dts += "    };\n\n"

for i in range(prog_slots):
    dts += f"    udma_p{i} {{\n"
    dts += "        compatible = \"ikwzm,u-dma-buf\";\n"
    dts += f"        device-name = \"delilah_prog{i}\";\n"
    dts += f"        size = <0x0 {hex(prog_size)}>;\n"
    dts += f"        memory-region = <&delilah_p{i}>;\n"
    dts += "        sync-mode = <1>;\n"
    dts += "        dma-mask = <64>;\n"
    dts += "    };\n\n"

for i in range(data_slots):
    dts += f"    udma_d{i} {{\n"
    dts += "        compatible = \"ikwzm,u-dma-buf\";\n"
    dts += f"        device-name = \"delilah_data{i}\";\n"
    dts += f"        size = <0x0 {hex(data_size)}>;\n"
    dts += f"        memory-region = <&delilah_d{i}>;\n"
    dts += "        sync-mode = <1>;\n"
    dts += "        dma-mask = <64>;\n"
    dts += "    };\n\n"

dts += "};\n"

print(dts)

