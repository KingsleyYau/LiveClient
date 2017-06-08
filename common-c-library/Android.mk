# Copyright (C) 2014 The QpidNetwork Project
# QpidNetwork Project Main Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

COMMON_C_LIBRARY_PATH := $(call my-dir)
COMMON_C_THIRDY_PARTY_PATH := $(COMMON_C_LIBRARY_PATH)/third_party

include $(COMMON_C_LIBRARY_PATH)/Function.mk
include $(call all-subdir-makefiles)
