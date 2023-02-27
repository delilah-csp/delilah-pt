/*
* Copyright (C) 2013 - 2016  Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in this
* Software without prior written authorization from Xilinx.
*
*/

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
#include "memory_config.h"

extern void test_memory_range(struct memory_range_s *range);

static void * Thread_Main_Control(void * data)
{
    int i;

    printf("--Starting Memory Test Application--\n\r");
    printf("NOTE: This application runs with D-Cache disabled.");
    printf("As a result, cacheline requests will not be generated\n\r");

    for (i = 0; i < n_memory_ranges; i++) {
        test_memory_range(&memory_ranges[i]);
    }

    printf("--Memory Test Application Complete--\n\r");

    return 0;
}

int main(int argc, char *argv[])
{
    pthread_t p_thread;
    int thr_id;
    int status;
    int a = 1;

    signal(SIGPIPE, SIG_IGN);

    thr_id = pthread_create(&p_thread, NULL, Thread_Main_Control, (void *)&a);
    if(thr_id < 0)
    {
        printf("Thread_Main_Control thread create error\n");
        return 0;
    }
    pthread_join(p_thread, (void **)&status);

    exit(0);
}
