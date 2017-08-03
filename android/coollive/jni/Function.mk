# Copyright (C) 2014 The CoolLive Project
# Makefile Common Function
#
# Created on: 2014/10/27
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

# -----------------------------------------------------------------------------
# Macro    : all-cpp-files-under 查找目录所有cpp文件
# Arguments: 1:Real path 目录绝对路径，可以使用realpath或者abspath
# Usage    : $(call all-cpp-files-under)
# Return   : The list of cpp source file
# -----------------------------------------------------------------------------
define all-cpp-files-under
$(notdir $(wildcard $1/*.cpp))
endef

# -----------------------------------------------------------------------------
# Macro    : all-cpp-files 查找目录(递归)所有cpp文件
# Arguments: 1:Real path 目录绝对路径，可以使用realpath或者abspath
# Usage    : $(call all-cpp-files-under)
# Return   : The list of cpp source file
# -----------------------------------------------------------------------------
define all-cpp-files
$(shell find $1 -name "*.cpp")
endef

# -----------------------------------------------------------------------------
# Macro    : all-c-files-under 查找目录所有cpp文件
# Arguments: 1:Real path 目录绝对路径，可以使用realpath或者abspath
# Usage    : $(call all-cpp-files-under)
# Return   : The list of cpp source file
# -----------------------------------------------------------------------------
define all-c-files-under
$(notdir $(wildcard $1/*.c))
endef

# -----------------------------------------------------------------------------
# Macro    : all-c-files 查找目录(递归)所有cpp文件
# Arguments: 1:Real path 目录绝对路径，可以使用realpath或者abspath
# Usage    : $(call all-cpp-files-under)
# Return   : The list of cpp source file
# -----------------------------------------------------------------------------
define all-c-files
$(shell find $1 -name "*.c")
endef

# -----------------------------------------------------------------------------
# Macro    : all-static-lib 查找目录(递归)所有a文件
# Arguments: 1:Real path 目录绝对路径，可以使用realpath或者abspath
# Usage    : $(call all-cpp-files-under)
# Return   : The list of cpp source file
# -----------------------------------------------------------------------------
define all-static-lib
$(shell find $1 -name "*.a")
endef