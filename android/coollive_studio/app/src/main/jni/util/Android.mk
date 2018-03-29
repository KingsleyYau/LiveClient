# Copyright (C) 2014 The QpidNetwork Project
# LSUtil Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

SELF_PATH := $(call my-dir)
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := lsimageutil

LOCAL_MODULE_FILENAME := liblsimageutil

LOCAL_C_INCLUDES := $(LIBRARY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_THIRDY_PARTY_PATH)

LOCAL_LDLIBS += -lGLESv2 -lEGL

LOCAL_CFLAGS = -fpermissive -Wno-write-strings
LOCAL_CFLAGS += -D__STDC_CONSTANT_MACROS

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_SHARED_LIBRARY)