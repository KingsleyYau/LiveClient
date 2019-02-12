# Copyright (C) 2014 The QpidNetwork Project
# HttpRequest Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

SELF_PATH := $(call my-dir)
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := livehttprequest

LOCAL_MODULE_FILENAME := liblivehttprequest

LOCAL_C_INCLUDES := $(LIBRARY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_THIRDY_PARTY_PATH)

$(info LOCAL_PATH : $(LOCAL_PATH))
$(info LIBRARY_PATH : $(LIBRARY_PATH))

LOCAL_CFLAGS = -fpermissive -Wno-write-strings

LOCAL_LDFLAGS += -L$(LIBRARY_THIRDY_PARTY_PATH)/curl/android/lib/$(TARGET_ARCH_ABI)/lib -lcurl
LOCAL_LDFLAGS += -L$(LIBRARY_THIRDY_PARTY_PATH)/openssl/android/lib/$(TARGET_ARCH_ABI)/lib -lssl -lcrypto
LOCAL_LDLIBS += -lz

LOCAL_STATIC_LIBRARIES += zip
LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += json
LOCAL_STATIC_LIBRARIES += xml
LOCAL_STATIC_LIBRARIES += amf
# manrequesthandler 里面已经有httpclient了，manrequesthandler是livechat的http库。这样就使用同一个httpclient库
#LOCAL_STATIC_LIBRARIES += httpclient
LOCAL_SHARED_LIBRARIES += crashhandler
LOCAL_STATIC_LIBRARIES += androidcommon
LOCAL_STATIC_LIBRARIES += httpcontroller
LOCAL_STATIC_LIBRARIES += manrequesthandler

LOCAL_CPPFLAGS  := -std=c++11
LOCAL_CPPFLAGS	+= -fpermissive

REAL_PATH := $(realpath $(LOCAL_PATH))

$(info REAL_PATH : $(REAL_PATH))
$(info LOCAL_C_INCLUDES : $(LOCAL_C_INCLUDES))

LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))
$(info LOCAL_SRC_FILES : $(LOCAL_SRC_FILES))

include $(BUILD_SHARED_LIBRARY)