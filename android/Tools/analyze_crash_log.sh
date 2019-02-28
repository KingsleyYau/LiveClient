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
	cat $TMP_FILE | while read line
	do
		EXTENSION=${line##*.}
		if [ "$EXTENSION" == "dmp" ];then
			# Handle with C++ Dump
			mkdir -p $OUTPUT_DIR/c
			cp -f $line $OUTPUT_DIR/c
			echo "c++ : $line" >> $REPORT_FILE
		else
			# Handle with Java Exception
			WHOLE_EX=`cat $line | grep "Exception"`
			VER=`cat $line | grep "versionCode" | awk -F ' = ' '{print $NF}'`
			
			if [ ! "$WHOLE_EX" == "" ];then
				EX=`echo $WHOLE_EX | awk -F ': ' '{print $1}'` 
				mkdir -p $OUTPUT_DIR/"$VER"_"$EX"
				cp -f $line $OUTPUT_DIR/"$VER"_"$EX"
				echo "$EX : $line" >> $REPORT_FILE
			fi
		fi
	done
elif [ "$PARAM_TYPE" == "iOS" ];then
	find $PARAM_DIR -type f > $TMP_FILE
	cat $TMP_FILE | while read line
	do
		# Handle with Object-C Exception
		WHOLE_EX=`cat $line | grep "ExecptionName"`
		VER=`cat $line | grep -v "System-Version\|CFBundleVersion\|Versions" | grep "Version" | awk -F ' = ' '{print $NF}'`
		
		if [ ! "$WHOLE_EX" == "" ];then
			EX=`echo $WHOLE_EX | awk -F ' = ' '{print $NF}'` 
			mkdir -p $OUTPUT_DIR/"$VER"_"$EX"
			cp -f $line $OUTPUT_DIR/"$VER"_"$EX"
			BASE_ADDR=`cat $line | grep "dating.app/dating" | awk -F ' ' '{print $1}'`
			#FRAME_ADDR=`cat $line | grep ".*\(0x[a-zA-Z0-9]*\).*[+] [0-9]*" | awk -F ' ' '{print $3}'`
			#atos -o dating.app.dSYM/Contents/Resources/DWARF/dating -arch arm64 -l $BASE_ADDR $FRAME_ADDR
			#CMD="atos -o dating.app.dSYM/Contents/Resources/DWARF/dating -arch arm64 -l $BASE_ADDR"
			#CMD="echo \1 $BASE_ADDR "
			#echo "sed -e \"s/.*\(0x[a-zA-Z0-9]*\).*[+] [0-9]*/$($CMD)/g\" $line"
			#cat $line | awk '/.*0x[a-zA-Z0-9]*.*[+] [0-9]*/ {rcmd=cmd" "$3;result=system(rcmd)}' cmd="$CMD"
			echo "$EX : $line" >> $REPORT_FILE
		fi
	done
fi
rm -f $TMP_FILE