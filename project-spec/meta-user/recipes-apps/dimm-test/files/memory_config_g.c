/* This file is automatically generated based on your hardware design. */
#include "memory_config.h"

struct memory_range_s memory_ranges[] = {
	{
		"ddr4_0_C0_DDR4_ADDRESS_BLOCK",
		"ddr4_0",
		0x1000000000,
		17179869184,
		"/dev/uio4",
	},
	{
		"ddr4_1_C0_DDR4_ADDRESS_BLOCK",
		"ddr4_1",
		0x4800000000,
		17179869184,
		"/dev/uio5",
	},
};

int n_memory_ranges = 2;