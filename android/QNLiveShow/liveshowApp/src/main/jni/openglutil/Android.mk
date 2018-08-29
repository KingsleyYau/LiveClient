LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := lsimageutil
#$(info $(TARGET_ARCH_ABI))
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/liblsimageutil.so
include $(PREBUILT_SHARED_LIBRARY)