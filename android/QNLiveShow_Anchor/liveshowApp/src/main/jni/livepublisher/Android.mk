LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := lspublisher
#$(info $(TARGET_ARCH_ABI))     
LOCAL_SRC_FILES := lib/$(TARGET_ARCH_ABI)/liblspublisher.so
include $(PREBUILT_SHARED_LIBRARY)  