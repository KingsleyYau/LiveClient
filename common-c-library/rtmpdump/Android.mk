MODULE_PATH := $(call my-dir)
LOCAL_PATH := $(MODULE_PATH)

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

ANDROID_IMP_PATH := android
ANDROID_IMP_SRC := $(subst $(MODULE_PATH)/,, $(wildcard $(MODULE_PATH)/$(ANDROID_IMP_PATH)/*.cpp))
ANDROID_IMP_SRC += $(subst $(MODULE_PATH)/,, $(wildcard $(MODULE_PATH)/$(ANDROID_IMP_PATH)/*.c))
LOCAL_SRC_FILES += $(ANDROID_IMP_SRC)

include $(BUILD_STATIC_LIBRARY)
