#!/bin/sh
# App crash log file analyze script
# Author:	Max.Chiu

USAGE="Usage: ./analyze_crash_log.sh [Input dir] [Output dir] [android/iOS]\n\
Example: ./analyze_crash_log.sh input android"

PARAM_DIR=""
if [ ! "$1" == "" ]
then
	PARAM_DIR="$1"
else
	echo "$USAGE" 
	exit 1
fi

PARAM_OUTPUT_DIR=""
if [ ! "$2" == "" ]
then
	PARAM_OUTPUT_DIR="$2"
else
	echo "$USAGE" 
	exit 1
fi

PARAM_TYPE=""
if [ ! "$3" == "" ]
then
	PARAM_TYPE="$3"
else
	echo $USAGE
	exit 1
fi

OUTPUT_DIR=$PARAM_OUTPUT_DIR
mkdir -p $OUTPUT_DIR
TMP_FILE=$OUTPUT_DIR/tmp.txt
REPORT_FILE=$OUTPUT_DIR/report.txt
rm -f $REPORT_FILE

if [ "$PARAM_TYPE" == "android" ];then
	find $PARAM_DIR -type f > $TMP_FILE
	cat $TMP_FILE | while read LINE
	do
		EXTENSION=${LINE##*.}
		if [ "$EXTENSION" == "dmp" ];then
			# Handle with C++ Dump
			mkdir -p $OUTPUT_DIR/c
			cp -f $LINE $OUTPUT_DIR/c
			echo "c++ : $LINE" >> $REPORT_FILE
		else
			# Handle with Java Exception
			WHOLE_EX=`cat $LINE | grep "Exception"`
			VER=`cat $LINE | grep "versionCode" | awk -F ' = ' '{print $NF}'`
			
			if [ ! "$WHOLE_EX" == "" ];then
				EX=`echo $WHOLE_EX | awk -F ': ' '{print $1}'` 
				mkdir -p $OUTPUT_DIR/"$VER"_"$EX"
				cp -f $LINE $OUTPUT_DIR/"$VER"_"$EX"
				echo "$EX : $LINE" >> $REPORT_FILE
			fi
		fi
	done
elif [ "$PARAM_TYPE" == "iOS" ];then
	find $PARAM_DIR -type f > $TMP_FILE
	cat $TMP_FILE | while read LINE
	do
		# Handle with Object-C Exception
		WHOLE_EX=`cat $LINE | grep "ExecptionName"`
		VER=`cat $LINE | grep -v "System-Version\|CFBundleVersion\|Versions" | grep "Version" | awk -F ' = ' '{print $NF}'`
		
		if [ ! "$WHOLE_EX" == "" ];then
			EX=`echo $WHOLE_EX | awk -F ' = ' '{print $NF}'` 
			
			# Create output folder
			DES_DIR=$OUTPUT_DIR/"$VER"_"$EX"
			mkdir -p $DES_DIR
			
			# Copy crash dump to output folder
			DES_FILE_NAME=`echo $LINE | awk -F '/' '{print $NF}'`
			DES_FILE_NAME=$DES_DIR/$DES_FILE_NAME
			cp -f $LINE $DES_FILE_NAME
			
			# Change dump address to code
			BASE_ADDR=`cat $DES_FILE_NAME | grep "dating.app/dating" | awk -F ' ' '{print $1}'`
			FRAME_ADDR=`cat $DES_FILE_NAME | grep ".*\(0x[a-zA-Z0-9]*\).*[+] [0-9]*" | awk -F ' ' '{print $3}'`
			#atos -o dating.app.dSYM/Contents/Resources/DWARF/dating -arch arm64 -l $BASE_ADDR $FRAME_ADDR
			# Separate [FRAME_ADDR] with Space into [FRAME_ARRAY]
			FRAME_ARRAY=(${FRAME_ADDR// /})
			FRAME_ARRAY_NUM=${#FRAME_ARRAY[@]}   
			for ((i=0; i<$FRAME_ARRAY_NUM; i++)) {
					FRAME_ITEM=${FRAME_ARRAY[$i]};
					STACK=`atos -o $VER/dating.app.dSYM/Contents/Resources/DWARF/dating -arch arm64 -l $BASE_ADDR $FRAME_ITEM`
					sed -i '' -e 's/^\([[:space:]*]'"$i"'[[:space:]*].*\)0x[a-zA-Z0-9]*.*[+] [0-9]*/\1'"$STACK"'/g' $DES_FILE_NAME
			}
			echo "$EX : $DES_FILE_NAME" >> $REPORT_FILE
		fi
	done
fi
rm -f $TMP_FILE