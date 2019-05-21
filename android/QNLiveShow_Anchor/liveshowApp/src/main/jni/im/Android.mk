# Copyright (C) 2014 The QpidNetwork Project
# LiveChat Module Makefile
#
# Created on: 2015/05/11
# Author: Samson Fan
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := im-interface

LOCAL_MODULE_FILENAME := libim-interface

LOCAL_CFLAGS = -fpermissive -Wno-write-strings

LOCAL_C_INCLUDES := $(LIBRARY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_THIRDY_PARTY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_IM_HOME_PATH)

LOCAL_LDFLAGS += -L$(LIBRARY_THIRDY_PARTY_PATH)/openssl/android/lib/$(TARGET_ARCH_ABI)/lib -lssl -lcrypto
LOCAL_LDLIBS += -lz
LOCAL_LDLIBS += -llog

#LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += zbim
#LOCAL_STATIC_LIBRARIES += androidcommon

LOCAL_CPPFLAGS  := -std=c++11

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_SHARED_LIBRARY)
