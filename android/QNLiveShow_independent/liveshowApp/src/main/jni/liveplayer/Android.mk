LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := lsplayer
#$(info $(TARGET_ARCH_ABI))     
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/liblsplayer.so
include $(PREBUILT_SHARED_LIBRARY)  