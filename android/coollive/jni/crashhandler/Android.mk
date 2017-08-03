# Copyright (C) 2014 The QpidNetwork Project
# CrashHandler Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := crashhandler-interface

LOCAL_MODULE_FILENAME := libcrashhandler-interface

LOCAL_C_INCLUDES := $(LIBRARY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_THIRDY_PARTY_PATH)
LOCAL_CPP_INCLUDES := $(LOCAL_C_INCLUDES)

LOCAL_STATIC_LIBRARIES += common
LOCAL_SHARED_LIBRARIES += crashhandler
LOCAL_SHARED_LIBRARIES += androidcommon

LOCAL_LDLIBS += -llog

LOCAL_CFLAGS = -fpermissive
LOCAL_CPPFLAGS := -std=c++11

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_SHARED_LIBRARY)