# Copyright (C) 2014 The QpidNetwork Project
# Curl Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

LOCAL_PATH:= $(call my-dir)

common_CFLAGS := -Wpointer-arith -Wwrite-strings -Wunused -Winline -Wnested-externs -Wmissing-declarations -Wmissing-prototypes -Wno-long-long -Wfloat-equal -Wno-multichar -Wsign-compare -Wno-format-nonliteral -Wendif-labels -Wstrict-prototypes -Wdeclaration-after-statement -Wno-system-headers \
	-DHAVE_CONFIG_H

#########################
# Build the libcurl library

include $(CLEAR_VARS)
include $(LOCAL_PATH)/lib/Makefile.inc

LOCAL_SRC_FILES := $(addprefix lib/, $(CSOURCES))

LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/curl/include/
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/curl/lib/
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/openssl/include

LOCAL_CFLAGS += $(common_CFLAGS)

#LOCAL_LDFLAGS += -L$(LOCAL_PATH)/../openssl/lib/$(TARGET_ARCH)

#LOCAL_LDLIBS += -lz -lssl -lcrypto

LOCAL_MODULE:= http
LOCAL_MODULE_TAGS := optional

include $(BUILD_STATIC_LIBRARY)