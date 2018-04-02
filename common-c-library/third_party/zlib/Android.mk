# Copyright (C) 2014 The QpidNetwork Project
# Minizip Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := z

LOCAL_MODULE_FILENAME := libz

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)

LOCAL_CPPFLAGS := -std=c++11
LOCAL_CPPFLAGS += -fpermissive
LOCAL_CFLAGS += -Wall -Wextra -pedantic -fPIC -DUSE_MMAP -std=c99

LOCAL_SRC_FILES := \
	src/adler32.c \
	src/compress.c \
	src/crc32.c \
	src/deflate.c \
	src/gzclose.c \
	src/gzlib.c \
	src/gzread.c \
	src/gzwrite.c \
	src/infback.c \
	src/inflate.c \
	src/inftrees.c \
	src/inffast.c \
	src/trees.c \
	src/uncompr.c \
	src/zutil.c

include $(BUILD_STATIC_LIBRARY) 