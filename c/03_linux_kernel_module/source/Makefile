# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}
# ${{VAR_PROJECT_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}

obj-m += src/

PWD                := $(CURDIR)
KDIR               := /lib/modules/$(shell uname -r)/build
BUILD_DIR          := $(PWD)/build
BUILD_DIR_MAKEFILE := $(BUILD_DIR)/Makefile

ifeq ($(CONFIG_STATUS_CHECK_GCC),y)
CC=$(STATUS_CHECK_GCC)
ccflags-y += -fanalyzer
endif

all: $(BUILD_DIR_MAKEFILE)
	$(MAKE) -C $(KDIR) CC=$(CC) M=$(BUILD_DIR) src=$(PWD)/src modules

$(BUILD_DIR):
	mkdir -p "$@"

$(BUILD_DIR_MAKEFILE): $(BUILD_DIR)
	touch "$@"

clean:
	$(MAKE) -C $(KDIR) CC=$(CC) M=$(PWD) clean

