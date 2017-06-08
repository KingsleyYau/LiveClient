LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := rtmpdump

LOCAL_CPPFLAGS  := -std=c++11
LOCAL_CPPFLAGS	+= -fpermissive -Wno-write-strings 
# For test file
#LOCAL_CPPFLAGS	+= -DFILE_TEST

LOCAL_C_INCLUDES := $(COMMON_C_LIBRARY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)
LOCAL_C_INCLUDES += $(COMMON_C_THIRDY_PARTY_PATH)/ffmpeg/android/include

LOCAL_CFLAGS = -fpermissive
LOCAL_CFLAGS += -D__STDC_CONSTANT_MACROS

LOCAL_LDLIBS := -llog

LOCAL_STATIC_LIBRARIES += common
LOCAL_STATIC_LIBRARIES += srs_librtmp

REAL_PATH := $(realpath $(LOCAL_PATH))
LOCAL_SRC_FILES := $(call all-cpp-files-under, $(REAL_PATH))
LOCAL_SRC_FILES += $(call all-c-files-under, $(REAL_PATH))

include $(BUILD_STATIC_LIBRARY)
