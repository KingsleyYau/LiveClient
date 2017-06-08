# Copyright (C) 2014 The QpidNetwork Project
# CrashHandler Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := crashhandler

LOCAL_MODULE_FILENAME := libcrashhandler

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../third_party/google-breakpad/src

LOCAL_CFLAGS = -fpermissive

LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += breakpad_client

LOCAL_LDLIBS += -llog

LOCAL_CPPFLAGS  := -std=c++11

LOCAL_REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(LOCAL_REAL_PATH))

include $(BUILD_SHARED_LIBRARY)