# Copyright (C) 2014 The CoolLive Project
# CoolLive Project Main Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

MAIN_PATH := $(call my-dir)

LIBRARY_PATH := $(MAIN_PATH)/../../../../../../common-c-library
LIBRARY_THIRDY_PARTY_PATH := $(LIBRARY_PATH)/third_party
include $(LIBRARY_PATH)/Android.mk

include $(call all-makefiles-under, $(MAIN_PATH))