#!/bin/sh

# Synchronize coollive source code and export jar file
# Author:	Max.Chiu

# change dir
CUR_PATH=$(cd "$(dirname "$0")";pwd)
echo "# CUR_PATH : $CUR_PATH"

CLEAN=""
if [ ! "$1" == "" ]
then
	CLEAN="$1"
fi
echo "# CLEAN : $CLEAN"

ECLIPSE_PROJECT_PATH=$CUR_PATH/../coollive/
STUDIO_PROJECT_PATH=$CUR_PATH/../coollive_studio

# copy jni version files

if [ "$CLEAN" == "clean" ]
then
	cp -rf $STUDIO_PROJECT_PATH/app/src/main/jni/Application.mk $ECLIPSE_PROJECT_PATH/jni/Application.mk
fi

cp -rf $STUDIO_PROJECT_PATH/app/src/main/jni/LSVersion.h $ECLIPSE_PROJECT_PATH/jni/LSVersion.h
cp -rf $STUDIO_PROJECT_PATH/app/src/main/jni/player/* $ECLIPSE_PROJECT_PATH/jni/player
cp -rf $STUDIO_PROJECT_PATH/app/src/main/jni/publisher/* $ECLIPSE_PROJECT_PATH/jni/publisher
cp -rf $STUDIO_PROJECT_PATH/app/src/main/jni/util/* $ECLIPSE_PROJECT_PATH/jni/util
#cp -rf $STUDIO_PROJECT_PATH/app/src/main/jni/fddb/* $ECLIPSE_PROJECT_PATH/jni/fddb
# copy java files
rm -rf $ECLIPSE_PROJECT_PATH/src/*
cp -rf $STUDIO_PROJECT_PATH/app/src/main/java/* $ECLIPSE_PROJECT_PATH/src
cp -rf $STUDIO_PROJECT_PATH/app/src/main/res/layout/* $ECLIPSE_PROJECT_PATH/res/layout

$CUR_PATH/export_jar-r18b.sh

echo "# Sync finish!"