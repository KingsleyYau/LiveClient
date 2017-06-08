#!/bin/sh
# jni create symbols script
# Author:       Max.Chiu
echo "####### jni create symbols script #######"
ARRAY=(armeabi armeabi-v7a x86)
for ARCH in ${ARRAY[@]};do
	echo "ARCH=$ARCH"
	LIBS=(`ls ./obj/local/$ARCH/*.so | awk -F"/" '{print $NF}'`)
	for LIB in ${LIBS[@]};do
		echo "LIB=$LIB"
		SYM="$LIB.sym"
		echo "SYM=./obj/local/$ARCH/$SYM"
		./dump_syms ./obj/local/$ARCH/$LIB > "$SYM"
		VERSION=`head $SYM | awk '{if(NR==1){print $4}}'`
		echo "VERSION=$VERSION"
		mkdir -p ./symbols/$LIB/$VERSION/
		mv $SYM symbols/$LIB/$VERSION/ -f
	done
done
echo "####### create symbols ok #######"
