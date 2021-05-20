#!/bin/sh
# jni dump stack script
# Author:       Max.Chiu
echo "####### jni dump stack script #######"
ARRAY=(`find ./crash -name *.dmp`)
for DMP in ${ARRAY[@]};do
        echo "DMP=$DMP"
        STACK="$DMP.stack.log"
        echo "STACK=$STACK"
        ./minidump_stackwalk -s $DMP ./symbols > $STACK
done
echo "####### dump stack ok #######"