#!/bin/sh
# jni dump stack script
# Author:       Max.Chiu
echo "####### jni dump stack script #######"
ARRAY=(`find . -name *.dmp`)
for DMP in ${ARRAY[@]};do
	echo "DMP=$DMP"
	STACK="$DMP.stack.log"
	echo "STACK=$STACK"
	./minidump_stackwalk -s $DMP ./symbols > $STACK
#	LIBS=(`ls ./obj/local/$ARCH/*.so | awk -F"/" '{print $NF}'`)
#	for LIB in ${LIBS[@]};do
#		echo "LIB=$LIB"
#		SYM="$LIB.sym"
#		echo "SYM=./obj/local/$ARCH/$SYM"
#		./dump_syms ./obj/local/$ARCH/$LIB > "$SYM"
#		VERSION=`head $SYM | awk '{if(NR==1){print $4}}'`
#		echo "VERSION=$VERSION"
#		mkdir -p ./symbols/$LIB/$VERSION/
#		mv $SYM symbols/$LIB/$VERSION/ -f
#	done
done
echo "####### dump stack ok #######"
