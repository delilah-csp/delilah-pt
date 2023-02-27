/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <time.h>

#include <termios.h>
#include <pthread.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <linux/input.h>

#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/mman.h>
#include "xstatus.h"
#include "memory_config.h"
#include "xil_testmem.h"

/*
 * memory_test.c: Test memory ranges present in the Hardware Design.
 *
 * This application runs with D-Caches disabled. As a result cacheline requests
 * will not be generated.
 *
 * For MicroBlaze/PowerPC, the BSP doesn't enable caches and this application
 * enables only I-Caches. For ARM, the BSP enables caches by default, so this
 * application disables D-Caches before running memory tests.
 */

void putnum(unsigned int num);

void test_memory_range(struct memory_range_s *range) {
    int status;


    int fd = open(range->dev, O_RDWR);
    char *dimm_info = NULL;

    if (fd < 0) {
        perror("open error");
        exit(EXIT_FAILURE);
    }

    dimm_info = (char *)mmap(NULL, range->size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if(dimm_info < 0)
    {
        perror("mmap error");
        exit(EXIT_FAILURE);
    }

    /* This application uses print statements instead of xil_printf/printf
     * to reduce the text size.
     *
     * The default linker script generated for this application does not have
     * heap memory allocated. This implies that this program cannot use any
     * routines that allocate memory on heap (printf is one such function).
     * If you'd like to add such functions, then please generate a linker script
     * that does allocate sufficient heap memory.
     */

    printf("Testing memory region: %s\r\n", range->name);
    printf("    Memory Controller: %s\r\n", range->ip);
    #ifdef __MICROBLAZE__
        printf("         Base Address: 0x"); putnum(range->base); printf("\n\r");
        printf("                 Size: 0x"); putnum(range->size); printf (" bytes \n\r");
    #else
        printf("         Base Address: 0x%lx \n\r",range->base);
        printf("                 Size: 0x%lx bytes \n\r",range->size);
    #endif

    status = Xil_TestMem32((u32*)dimm_info, 1024, 0xAAAA5555, XIL_TESTMEM_ALLMEMTESTS);
    printf("          32-bit test: "); printf(status == XST_SUCCESS? "PASSED!":"FAILED!"); printf("\n\r");

    status = Xil_TestMem16((u16*)dimm_info, 2048, 0xAA55, XIL_TESTMEM_ALLMEMTESTS);
    printf("          16-bit test: "); printf(status == XST_SUCCESS? "PASSED!":"FAILED!"); printf("\n\r");

    status = Xil_TestMem8((u8*)dimm_info, 4096, 0xA5, XIL_TESTMEM_ALLMEMTESTS);
    printf("           8-bit test: "); printf(status == XST_SUCCESS? "PASSED!":"FAILED!"); printf("\n\r");

    munmap(dimm_info, range->size);
    close(fd);
}