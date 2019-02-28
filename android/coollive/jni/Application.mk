# Copyright (C) 2014 The CoolLive Project
# CoolLive Project Application Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

APP_PLATFORM := android-16
APP_STL := stlport_static #使用STLport作为静态库

#APP_OPTIM := debug # gdbserver调试模式

#APP_ABI := all #[armeabi-v7a] [arm64-v8a] [x86], NDK-r7之后可以使用这样方式编译支持多种芯片, NDK-r10e之后[armeabi]和[mips]被废弃
#APP_ABI	:= armeabi armeabi-v7a arm64-v8a x86
APP_ABI	:= armeabi armeabi-v7a arm64-v8a x86

#NDK_TOOLCHAIN_VERSION = 4.9

#STLPORT_FORCE_REBUILD := true 可以强制重新编译STLPort源码
APP_CFLAGS += -O2 -D_ANDROID -DPRINT_JNI_LOG -DFILE_JNI_LOG #-D_CHECK_MEMORY_LEAK#-O2 #-g