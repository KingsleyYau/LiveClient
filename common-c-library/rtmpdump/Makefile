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

THIRD_PARTY	= 	../third_party/srs/srs_librtmp.o
UTIL 		=	util/EncodeDecodeBuffer.o util/FrameBuffer.o util/CacheBufferQueue.o
PLAYER		=	RtmpDump.o RtmpPlayer.o PlayerController.o Statistics.o
PUSHER		=	RtmpPublisher.o PublisherController.o
AUDIO		=	audio/AudioFrame.o audio/AudioEncoderAAC.o audio/AudioDecoderAAC.o \
				audio/AudioMuxer.o audio/AudioRecorderAAC.o
VIDEO 		=	video/VideoFrame.o video/VideoEncoderH264.o video/VideoDecoderH264.o\
				video/VideoFormatConverter.o video/VideoMuxer.o \
				video/VideoRotateFilter.o video/VideoFilters.o\
				video/VideoRecorderH264.o
LINUX		=	linux/VideoDecoderImp.o linux/AudioDecoderImp.o
				
OBJS		= $(THIRD_PARTY)
OBJS		+= $(UTIL)
OBJS		+= $(PLAYER)
OBJS		+= $(PUSHER)
OBJS		+= $(AUDIO)
OBJS		+= $(VIDEO)
OBJS		+= $(LINUX)
	
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