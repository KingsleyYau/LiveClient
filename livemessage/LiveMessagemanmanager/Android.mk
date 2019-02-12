# Copyright (C) 2014 The QpidNetwork Project
# LiveChat Module Makefile
#
# Created on: 2015/10/21
# Author: Samson Fan
# LiveChatManager for man

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := livemessagemanmanager

LOCAL_MODULE_FILENAME := liblivemessagemanmanager

#LOCAL_LDLIBS += -llog
#LOCAL_LDLIBS += -lz

LOCAL_STATIC_LIBRARIES += z
LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += httpcontroller
LOCAL_STATIC_LIBRARIES += json
LOCAL_STATIC_LIBRARIES += mongoose
LOCAL_STATIC_LIBRARIES += im

LOCAL_CPPFLAGS  := -std=c++11
#LOCAL_CFLAGS = -Wall -Werror

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)
#LOCAL_C_INCLUDES += $(LIBRARY_IM_HOME_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_IM_COMMON_HOME_PATH)

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY)
