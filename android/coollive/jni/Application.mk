# Copyright (C) 2014 The CoolLive Project
# CoolLive Project Application Makefile
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

APP_PLATFORM := android-9
APP_STL := stlport_static #使用STLport作为静态库
#APP_STL := stlport_shared #使用STLport作为动态库，这个可能产生兼容性和部分低版本的Android固件
#APP_STL := gnustl_static #使用 GNU libstdc++ 作为静态库
#APP_STL := system #使用默认最小的C++运行库，这样生成的应用体积小，内存占用小，但部分功能将无法支持

#APP_OPTIM := debug # gdbserver调试模式

#APP_ABI := all #NDK-rv7之后可以使用这样方式编译支持多种芯片 [armeabi] [armeabi-v7a] [arm64-v8a] [x86] [mips]
APP_ABI	:= armeabi armeabi-v7a arm64-v8a x86

NDK_TOOLCHAIN_VERSION = 4.9

#STLPORT_FORCE_REBUILD := true 可以强制重新编译STLPort源码
APP_CFLAGS += -O2 -D_ANDROID -DPRINT_JNI_LOG -DFILE_JNI_LOG #-D_CHECK_MEMORY_LEAK#-O2 #-DHAVE_PTHREADS -DHAVE_ANDROID_OS=1 -g #-std=c++0x#-std=gnu++0x
#APP_CXXFLAGS += -std=c++11