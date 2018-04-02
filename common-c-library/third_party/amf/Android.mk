# Copyright (C) 2014 The QpidNetwork Project
# Amf Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := amf

LOCAL_MODULE_FILENAME := libamf

LOCAL_CPPFLAGS += -std=c++0x# -Wall -Wextra -pedantic
#LOCAL_CPPFLAGS += -frtti -fexceptions -Wno-sign-compare

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY) 
