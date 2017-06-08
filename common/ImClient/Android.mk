# Copyright (C) 2014 The QpidNetwork Project
# LiveChat Module Makefile
#
# Created on: 2015/04/13
# Author: Samson Fan
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := im

LOCAL_MODULE_FILENAME := libim

#LOCAL_LDLIBS += -llog
#LOCAL_LDLIBS += -lz

LOCAL_STATIC_LIBRARIES += z
LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += json
LOCAL_STATIC_LIBRARIES += mongoose

LOCAL_CPPFLAGS  := -std=c++11
#LOCAL_CFLAGS = -Wall -Werror

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY)
