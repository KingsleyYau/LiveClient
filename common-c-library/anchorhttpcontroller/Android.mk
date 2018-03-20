# Copyright (C) 2014 The QpidNetwork Project
# HttpController Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

SELF_PATH := $(call my-dir)
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := anchorhttpcontroller

LOCAL_MODULE_FILENAME := libanchorhttpcontroller

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/curl/android/include

LOCAL_CFLAGS = -fpermissive -Wno-write-strings

LOCAL_STATIC_LIBRARIES += zip
LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += json
LOCAL_STATIC_LIBRARIES += xml
LOCAL_STATIC_LIBRARIES += amf
LOCAL_STATIC_LIBRARIES += httpclient
LOCAL_STATIC_LIBRARIES += simulatorchecker
LOCAL_SHARED_LIBRARIES += crashhandler

LOCAL_CPPFLAGS  := -std=c++11
LOCAL_CPPFLAGS	+= -fpermissive

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY)
