# Copyright (C) 2014 The CoolLive Project
# CoolLive Project Application Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

APP_PLATFORM := android-16

#APP_STL := c++_static
APP_STL := c++_shared

#APP_OPTIM := debug # gdbserver调试模式

#APP_ABI := all #[armeabi-v7a] [arm64-v8a] [x86], NDK-r7开始可以使用这样方式编译支持多种芯片, NDK-r16开始[armeabi]和[mips]被废弃
APP_ABI	:= armeabi-v7a arm64-v8a x86 x86_64

APP_CFLAGS += -O2 -D_ANDROID_NDK_VERSION=16 -D_ANDROID -DPRINT_JNI_LOG -DFILE_JNI_LOG #-g