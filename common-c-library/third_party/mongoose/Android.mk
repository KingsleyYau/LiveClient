# Copyright (C) 2017 The LiveShow Project
# Amf Module Makefile
#
# Created on: 2017/5/31
# Author: Hunter.Mun
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := mongoose

LOCAL_MODULE_FILENAME := libmongoose

LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/openssl/include

LOCAL_CPPFLAGS  := -std=c++11

REAL_PATH := $(realpath $(LOCAL_PATH))
#LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))
LOCAL_SRC_FILES := $(call all-c-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY) 
