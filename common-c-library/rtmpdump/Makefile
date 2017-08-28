# Copyright (C) 2015 The common-c-library
# rtmpdump module Makefile
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
CXXFLAGS +=	-Wall -fmessage-length=0 -Wno-unused-variable -Wno-unused-but-set-variable -D__STDC_CONSTANT_MACROS
CXXFLAGS +=	-I. -I.. -I../third_party

THIRD_PARTY	= ../third_party/srs/srs_librtmp.o
OBJS 		=	EncodeDecodeBuffer.o
PLAYER		=	RtmpPlayer.o PlayerController.o FrameBuffer.o CacheBufferQueue.o
PUSHER		=	RtmpPublisher.o PublisherController.o
ENCODER		=	AudioEncoderAAC.o VideoEncoderH264.o 
DECODER 	=	AudioFrame.o AudioDecoderAAC.o \
				VideoFrame.o VideoDecoderH264.o VideoFormatConverter.o VideoMuxer.o VideoRotateFilter.o VideoFilters.o\
				linux/VideoDecoderImp.o linux/AudioDecoderImp.o
				
OBJS		+= $(THIRD_PARTY)
OBJS		+= $(PLAYER)
OBJS		+= $(PUSHER)
OBJS		+= $(ENCODER)
OBJS		+= $(DECODER)
		
TARGET =	librtmpdump.a

.PHONY: all clean $(TARGET)

$(TARGET):	$(OBJS)
	$(AR) cr $@ $(OBJS)
	@echo '################################################################'
	@echo ''
	@echo '# Bulid librtmpdump.a completed!'
	@echo ''
	@echo '################################################################'

all:	$(TARGET) 

clean:
	rm -f $(OBJS) $(TARGET)