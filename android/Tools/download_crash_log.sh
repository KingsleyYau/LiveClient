#!/bin/sh
# App crash log file download and unzip script
# Author:	Max.Chiu

USAGE="Usage: ./download_crash_log.sh [URL] [Total Page] [Output dir] [android/iOS]\n\
Example: ./download_crash_log.sh \"http://mobile.asiame.com/other/crash_file_view/usertype/?date1=2019-01-01&date2=2019-02-12&manid=&devicetype=31&deviceid=&versioncode=136&search=+%E6%90%9C+%E7%B4%A2+&__hash__=14b802a461d11e2cea5307d1f86a9fff_07201d6c31a21b8435a1b3b19951e8d0\" 2 output android"
 
PARAM_URL=""
if [ ! "$1" == "" ]
then
	PARAM_URL="$1"
else
	echo $USAGE
	exit 1
fi

PARAM_PAGE=""
if [ ! "$2" == "" ]
then
	PARAM_PAGE="$2"
else
	echo $USAGE
	exit 1
fi

PARAM_DIR=""
if [ ! "$3" == "" ]
then
	PARAM_DIR=./"$3"
else
	echo $USAGE
	exit 1
fi

PARAM_TYPE=""
if [ ! "$4" == "" ]
then
	PARAM_TYPE="$4"
else
	echo $USAGE
	exit 1
fi

rm -rf link.txt
for ((i=1; i<=$PARAM_PAGE; i++))
do
	URL="$PARAM_URL&p=$i"
	RESULT=`curl "$URL"`
	
	echo $RESULT | sed -e $'s/zip"/zip"\\\n/g' >> tmp.txt
	sed -e 's/.*a\ href="\(.*zip\)"/\1/g' -i "" tmp.txt
	sed -e '$d' -i "" tmp.txt
	cat tmp.txt >> link.txt
	rm -rf tmp.txt
done

mkdir -p $PARAM_DIR
ZIP_DIR=$PARAM_DIR/zip
mkdir -p $ZIP_DIR
CRASH_DIR=$PARAM_DIR/crash
mkdir -p $CRASH_DIR
REPORT_DIR=$PARAM_DIR/report
mkdir -p $REPORT_DIR

DOMAIN="http://mobile.asiame.com"
cat link.txt | while read line
do
	URL=$DOMAIN$line
	FILE_NAME=`echo $line | awk -F '/' '{print $NF}'`
	DIR_NAME=`echo $FILE_NAME | awk -F '.' '{print $1}'`
	curl -o $ZIP_DIR/$FILE_NAME "$URL"
	unzip -o -P Qpid_Dating $ZIP_DIR/$FILE_NAME -d $CRASH_DIR/$DIR_NAME
done
rm -rf link.txt

./analyze_crash_log.sh $CRASH_DIR $REPORT_DIR $PARAM_TYPE