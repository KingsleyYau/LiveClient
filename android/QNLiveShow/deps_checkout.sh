#!/bin/sh

# ---- enter folder
BASEDIR=$(dirname $0)
cd $BASEDIR

# ---- define folder path
common_fodler=../../common
common_c_folder=../../common-c-library
livemessage_folder=../../livemessage

# ---- load config file
while read -r line
do 
  declare $line
done < ./deps_config.txt

# ---- check shell result function
function check_result()
{
shell_result=$1
printf_info=$2
echo "shell result:$shell_result"
if [ $shell_result = "0" ];then
echo ""
echo ""
echo "------===== FINISH =====------"
echo "------===== checkout $printf_info =====------"
echo ""
else
echo "----=== ERROR ===----"
echo "----=== checkout $printf_info ===----"
echo ""
exit 1
fi
}

# ---- handle function
function handle()
{
  module_folder=$1
  module_svn=$2
  module_result=0
  if [ -e "$module_folder" ]; then
    svn_url=`svn info $module_folder|grep "URL:"|grep "svn:"|awk -F ' ' {'print $2'}`
    if [ "$svn_url" = "$module_svn" ]; then
      svn update $module_folder
      module_result=$?
      check_result $module_result "update svnUrl: $svn_url"
    else
      echo "----=== ERROR ===----"
      echo "$module_folder folder's svn path is not match, please remove and retry."
      echo "current: $svn_url"
      echo "target: $module_svn"
      echo ""
      exit 1
    fi
  else
    svn checkout $module_svn $module_folder
    module_result=$?
    check_result $module_result "checkout svnUrl: $module_svn"
  fi
}

# ---- handle

if [ "trunk" = "$common_c_library_ver" ]; then
  handle $common_c_folder svn://192.168.8.177:8034/client/livecommon/common-c-library
else
  handle $common_c_folder svn://192.168.8.177:8034/client/tag/livecommon/common-c-library/common-c-library_v$common_c_library_ver/common-c-library
fi

if [ "trunk" = "$common_ver" ]; then
handle $common_fodler svn://192.168.8.177:8034/client/livecommon/common
else
handle $common_fodler svn://192.168.8.177:8034/client/tag/livecommon/common/common_v$common_ver/common
fi

if [ "trunk" = "$livemessage_ver" ]; then
  handle $livemessage_folder svn://192.168.8.177:8034/client/livecommon/livemessage
else
  handle $livemessage_folder svn://192.168.8.177:8034/client/tag/livecommon/livemessage/livemessage_v$livemessage_ver/livemessage
fi

# ---- print finish info
echo ""
echo ""
echo "------===== FINISH =====------"
echo "common_c_library: $common_c_library_ver"
echo "common: $common_ver"
echo "livemessage: $livemessage_ver"
echo ""

