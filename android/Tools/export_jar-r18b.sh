#!/bin/sh

# Compile coollive files and export jar file
# Author:	Max.Chiu

# Change dir
CUR_PATH=$(cd "$(dirname "$0")";pwd)

LOG_FILE=$(pwd)/export.log
rm -f $LOG_FILE
echo "# LOG_FILE : $LOG_FILE"

NDK_PATH=/Applications/Android/android-sdks-studio/ndk-bundle
NDK_CMD=$NDK_PATH/ndk-build
ECLIPSE_PROJECT_PATH=$CUR_PATH/../coollive
SDK_PATH=/Applications/Android/android-sdks/platforms
TMP_PATH=$(pwd)/tmp
mkdir -p $TMP_PATH

# Create version
VERSION=`grep "public final static String VERSION" $ECLIPSE_PROJECT_PATH/src/net/qdating/LSConfig.java | awk -F '"' '{print $2}'`
echo "Version : $VERSION" >> $LOG_FILE

# Compile java source
javac \
-source 1.6 -target 1.6 \
-bootclasspath $SDK_PATH/android-25/android.jar \
-Xlint:deprecation \
-g \
-d $TMP_PATH \
$ECLIPSE_PROJECT_PATH/src/net/qdating/utils/Log.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/filter/*.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/filter/beauty/*.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/filter/sample/*.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/player/*.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/publisher/*.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/*.java \
>> $LOG_FILE 2>&1

# Compile libs
cd $ECLIPSE_PROJECT_PATH/jni >/dev/null 2>&1 
$NDK_CMD >> $LOG_FILE 2>&1 
cd - >/dev/null 2>&1 

# package
mkdir -p $VERSION

# Copy source files
mkdir -p $TMP_PATH/net/qdating/ 
cp -rf $ECLIPSE_PROJECT_PATH/src/net/qdating/*.java $TMP_PATH/net/qdating/

# Delete system tmp files
find $TMP_PATH -name ".DS_Store" | xargs rm -rf {}

# Export jar
jar cvf $VERSION/coollive.jar -C $TMP_PATH . >> $LOG_FILE 2>&1
rm -f $ECLIPSE_PROJECT_PATH/libs/*.jar >> $LOG_FILE 2>&1
cp -rf $ECLIPSE_PROJECT_PATH/libs $VERSION >> $LOG_FILE 2>&1

# Copy assets
mkdir -p $VERSION/assets
cp -rf $ECLIPSE_PROJECT_PATH/assets/filters $VERSION/assets/ >> $LOG_FILE 2>&1

mkdir -p $VERSION/doc
javadoc \
-public \
-author \
-windowtitle "" \
-version \
-d $VERSION/doc \
$ECLIPSE_PROJECT_PATH/src/net/qdating/*.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/player/LSPlayerRendererBinder.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/player/ILSPlayerStatusCallback.java \
$ECLIPSE_PROJECT_PATH/src/net/qdating/publisher/ILSPublisherStatusCallback.java \
>> $LOG_FILE 2>&1

# Delete tmp files
find . -name "*crashhandler*.so" | xargs rm -rf {}; >> $LOG_FILE 2>&1
rm -rf $TMP_PATH >> $LOG_FILE 2>&1

# Package obj files
tar zcvf ./$VERSION/obj.tar.gz --exclude ".DS_Store" -C $ECLIPSE_PROJECT_PATH obj >> $LOG_FILE 2>&1

echo "# Export finish!"