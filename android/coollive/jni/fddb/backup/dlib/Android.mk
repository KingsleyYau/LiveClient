# Copyright (C) 2014 The QpidNetwork Project
# LSPlayer Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

# Pre build OpenCV lib
SELF_PATH := $(call my-dir)

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := opencv
LOCAL_MODULE_FILENAME := libopencv_java3
LOCAL_SRC_FILES := libs/$(TARGET_ARCH_ABI)/libopencv_java3.so
include $(PREBUILT_SHARED_LIBRARY)

# Build own face-detection lib
include $(CLEAR_VARS)

LOCAL_MODULE := lsffdb

LOCAL_MODULE_FILENAME := liblsffdb

LOCAL_C_INCLUDES := $(LIBRARY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_THIRDY_PARTY_PATH)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include/

LOCAL_CFLAGS = -fpermissive -Wno-write-strings
LOCAL_CFLAGS += -D__STDC_CONSTANT_MACROS

LOCAL_CXXFLAGS += -std=c++11
LOCAL_CPPFLAGS += -fexceptions -fpermissive -frtti

LOCAL_LDLIBS = -llog -lz
LOCAL_LDFLAGS = -L$(LOCAL_PATH)/libs/$(TARGET_ARCH_ABI)/ \
                 -ldlib

LOCAL_STATIC_LIBRARIES += common
LOCAL_SHARED_LIBRARIES = opencv

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_SHARED_LIBRARY)