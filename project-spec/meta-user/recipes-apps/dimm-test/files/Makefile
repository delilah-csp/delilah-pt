APP = dimm-test

# Add any other object files to this list below
APP_OBJS = dimm-test.o memory_config_g.o memorytest.o xil_testmem.o xil_assert.o

all: build

build: $(APP)

$(APP): $(APP_OBJS)
	$(CC) $(LDFLAGS) -pthread -o $@ $(APP_OBJS) $(LDLIBS)

clean:
	-rm -f $(APP) $(APP_OBJS)


