# Copyright (C) 2015 The common-c-library
# common module Makefile
#
# Created on: 2015/10/10
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

export MAKE	:=	make

release=0
ifeq ($(release), 1)
CXXFLAGS = -O3 
else
CXXFLAGS = -O2 -g
endif

CXXFLAGS += -DLINUX -DFILE_JNI_LOG
CXXFLAGS +=	-Wall -fmessage-length=0 -Wno-unused-variable -Wno-unused-but-set-variable -DLINUX
CXXFLAGS +=	-I. -I..

OBJS 		=	md5.o aes.o KThread.o Arithmetic.o IAutoLock.o CommonFunc.o KLog.o \
				filelog/LogFile.o filelog/LogManager.o
		
TARGET =	libcommon.a

.PHONY: all clean $(TARGET)

$(TARGET):	$(OBJS)
	$(AR) cr $@ $(OBJS)
	@echo '################################################################'
	@echo ''
	@echo '# Bulid libcommon.a completed!'
	@echo ''
	@echo '################################################################'

all:	$(TARGET) 

clean:
	rm -f $(OBJS) $(TARGET)