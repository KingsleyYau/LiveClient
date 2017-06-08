# Copyright (C) 2014 The QpidNetwork Project
# Xml Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := xml

LOCAL_MODULE_FILENAME := libxml

LOCAL_CPPFLAGS  := -std=c++11

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY) 
