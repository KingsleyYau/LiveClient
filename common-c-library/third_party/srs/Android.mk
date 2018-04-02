# Copyright (C) 2014 The QpidNetwork Project
# Xml Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := srs_librtmp

LOCAL_MODULE_FILENAME := libsrs_librtmp

LOCAL_CPPFLAGS  := -std=gnu++98

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY) 
