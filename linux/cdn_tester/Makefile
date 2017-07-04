# Copyright (C) 2015 The cdn_tester
# cdn_tester Makefile
#
# Created on: 2017/07/04
# Author: Max.Chiu
# Email: Kingsleyyau@gmail.com
#

export MAKE	:=	make

release=0
ifeq ($(release), 1)
CXXFLAGS = -O3 
else
CXXFLAGS = -O2 -g #-D_CHECK_MEMORY_LEAK
endif

CXXFLAGS += -DFILE_JNI_LOG
CXXFLAGS +=	-Wall -fmessage-length=0 -Wno-unused-variable -Wno-unused-but-set-variable
CXXFLAGS +=	-I. -Iinclude -I../../common-c-library/ -Ideps/build/include/

# 注意连接依赖顺序问题, 被依赖的放后面
LIBS =		-L. \
			-Wl,-Bstatic -L../../common-c-library/rtmpdump -lrtmpdump \
			-Wl,-Bstatic -L../../common-c-library/common -lcommon \
			-Wl,-Bstatic -Ldeps/build/lib -lavfilter -lavformat -lavdevice -lavcodec -lswscale -lavutil -lswresample -lpostproc -lx264 -lfdk-aac \
			-Wl,-Bdynamic -ldl -lz -lpthread -lidn -lrt

OBJS 		=	main.o LSPlayerImp.o
		
TARGET =	cdn_tester

DEPDIRS	:= ../../common-c-library/rtmpdump ../../common-c-library/common
			
CLEAN_DEPS := $(addprefix _clean_, $(DEPDIRS))

.PHONY: all deps clean cleanall install $(DEPDIRS) $(TARGET)

$(TARGET):	deps $(OBJS)
	$(CXX) -o $(TARGET) $(OBJS) $(LIBS)
	@echo '################################################################'
	@echo ''
	@echo '# Bulid cdn_tester completed!'
	@echo ''
	@echo '################################################################'

$(DEPDIRS):
	$(MAKE) -C $@
	
$(CLEAN_DEPS):	
	$(MAKE) -C $(patsubst _clean_%, %, $@) clean
					
deps:	$(DEPDIRS)
	@echo '################################################################'
	@echo ''
	@echo '# Bulid deps cdn_tester completed!'
	@echo ''
	@echo '################################################################'
	
all:	deps $(TARGET) $(LIVECHAT_TEST)

clean:
	rm -f $(TARGET) $(OBJS)
	
cleanall: clean	$(CLEAN_DEPS)
	@echo '################################################################'
	@echo ''
	@echo '# Clean all cdn_tester finished!'
	@echo ''
	@echo '################################################################'
	
install: 
	copy cdn_tester /usr/local/bin
	chmod +x /usr/local/bin/cdn_tester
	@echo '################################################################'
	@echo ''
	@echo '# Install cdn_tester finished!'
	@echo ''
	@echo '################################################################'
