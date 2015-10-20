# Copyright (c) 2014-2015 Cryptography Research, Inc.
# Released under the MIT License.  See LICENSE.txt for license information.


UNAME := $(shell uname)
MACHINE := $(shell uname -m)


WARNFLAGS = -pedantic -Wall -Wextra -Werror -Wpedantic -Wunreachable-code \
	 -Wmissing-declarations -Wunused-function $(EXWARN)

INCFLAGS = -Isrc/include -Isrc/public_include
LANGFLAGS = -std=c99 -fno-strict-aliasing
GENFLAGS = -ffunction-sections -fdata-sections -fvisibility=hidden -fomit-frame-pointer -fPIC
OFLAGS ?= -O2

CC = clang
ARCHFLAGS += $(XARCHFLAGS)
CFLAGS  = $(LANGFLAGS) $(WARNFLAGS) $(INCFLAGS) $(OFLAGS) $(ARCHFLAGS) $(GENFLAGS) $(XCFLAGS)
LDFLAGS = $(XLDFLAGS)
ASFLAGS = $(ARCHFLAGS) $(XASFLAGS)

.PHONY: clean all test bench todo doc lib bat sage sagetest
.SUFFIXES: .o .c

all: build/x448.o

scan: clean
	scan-build --use-analyzer=`which clang` \
		 -enable-checker deadcode -enable-checker llvm \
		 -enable-checker osx -enable-checker security -enable-checker unix \
		make all

build/timestamp::
	mkdir -p build
	touch $@

build/%.o: %.c build/timestamp Makefile *.h
	$(CC) $(CFLAGS) -c -o $@ $<

build/x448_test: build/x448_test.o build/x448.o
	$(CC) $(LDFLAGS) -o $@ $^
	
test: build/x448_test
	$<

clean:
	rm -fr build
