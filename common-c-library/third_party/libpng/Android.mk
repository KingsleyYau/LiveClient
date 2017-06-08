# Copyright (C) 2014 The QpidNetwork Project
# Common Module Makefile
#
# Created on: 2015/05/11
# Author: Samson Fan
#

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := png
LOCAL_MODULE_FILENAME := libpng

LOCAL_CFLAGS = -Wno-write-strings

#LOCAL_LDLIBS += -llog
#LOCAL_LDLIBS += -lz

LOCAL_CPPFLAGS  := -std=c++11

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-c-files-under, $(REAL_PATH))

#include $(BUILD_SHARED_LIBRARY)
include $(BUILD_STATIC_LIBRARY)
