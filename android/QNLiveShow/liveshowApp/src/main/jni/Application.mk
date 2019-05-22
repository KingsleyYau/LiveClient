# Copyright (C) 2014 The QpidNetwork Project
# QpidNetwork Project Application Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

APP_PLATFORM := android-16
APP_STL := c++_shared #使用STLport作为静态库
#APP_STL := stlport_shared #使用STLport作为动态库，这个可能产生兼容性和部分低版本的Android固件
#APP_STL := gnustl_static #使用 GNU libstdc++ 作为静态库
#APP_STL := system #使用默认最小的C++运行库，这样生成的应用体积小，内存占用小，但部分功能将无法支持

APP_OPTIM := debug # gdbserver调试模式

#APP_ABI := all #NDK-rv7之后可以使用这样方式编译支持多种芯片 [armeabi] [armeabi-v7a] [x86] [mips]
APP_ABI	:= armeabi-v7a x86 arm64-v8a x86_64

#NDK_TOOLCHAIN_VERSION = 4.8

#STLPORT_FORCE_REBUILD := true 可以强制重新编译STLPort源码
APP_CFLAGS += -O2 -D_ANDROID -DMG_ENABLE_SSL -D_HTTPS_SUPPORT -D_ANDROID_NDK_VERSION=16 -g -O0 -DPRINT_JNI_LOG -DFILE_JNI_LOG -DMONGOOSE_LOG #-O2#-DHAVE_PTHREADS -DHAVE_ANDROID_OS=1 -g #-std=c++0x#-std=gnu++0x
#APP_CXXFLAGS += -std=c++11
