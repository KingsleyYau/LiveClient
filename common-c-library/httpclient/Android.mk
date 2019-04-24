# Copyright (C) 2014 The QpidNetwork Project
# HttpClient Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := httpclient

LOCAL_MODULE_FILENAME := libhttpclient

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/openssl/android/include
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/curl/android/include

#LOCAL_CFLAGS = -fpermissive
LOCAL_CFLAGS := -D_HTTPS_SUPPORT

LOCAL_STATIC_LIBRARIES += common

LOCAL_CPPFLAGS  := -std=c++11

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY)
