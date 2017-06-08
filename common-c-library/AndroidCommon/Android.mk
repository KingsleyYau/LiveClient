# Copyright (C) 2014 The QpidNetwork Project
# Common Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := androidcommon

LOCAL_MODULE_FILENAME := libandroidcommon

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)

LOCAL_CPPFLAGS := -std=c++11
LOCAL_CPPFLAGS += -fpermissive

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))
LOCAL_SRC_FILES += $(call all-c-files-under, $(REAL_PATH))

$(info REAL_PATH : $(REAL_PATH))
$(info LOCAL_PATH : $(LOCAL_PATH))

include $(BUILD_STATIC_LIBRARY) 
