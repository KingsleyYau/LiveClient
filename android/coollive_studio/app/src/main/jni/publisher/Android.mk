# Copyright (C) 2014 The QpidNetwork Project
# LSPublisher Module Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

SELF_PATH := $(call my-dir)
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := lspublisher

LOCAL_MODULE_FILENAME := liblspublisher

LOCAL_C_INCLUDES := $(LIBRARY_PATH)
LOCAL_C_INCLUDES += $(LIBRARY_THIRDY_PARTY_PATH)

LOCAL_CFLAGS = -fpermissive -Wno-write-strings
LOCAL_CFLAGS += -D__STDC_CONSTANT_MACROS

LOCAL_LDLIBS := -llog -lz
LOCAL_LDFLAGS += -L$(LIBRARY_THIRDY_PARTY_PATH)/ffmpeg/android/lib/$(TARGET_ARCH_ABI)/lib \
					-lavfilter \
					-lavformat \
					-lavdevice \
					-lavcodec \
					-lswscale \
					-lavutil \
					-lswresample \
					-lpostproc \
					-lx264 \
					-lfdk-aac
		
LOCAL_STATIC_LIBRARIES += rtmpdump
LOCAL_SHARED_LIBRARIES += androidcommon

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))

include $(BUILD_SHARED_LIBRARY)