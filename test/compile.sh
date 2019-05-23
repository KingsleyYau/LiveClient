#!/bin/sh
# nginx compile script
# Author:	Max.Chiu
# Description:

# define version
nginx_ver="1.11.10"

# define folder path
curr_path=`pwd`
src_dir="$curr_path/src"
build_dir="$curr_path/build"
nginx_src_dir="$src_dir/nginx-$nginx_ver"
nginx_rtmp_src_dir="$src_dir/nginx-rtmp-module"
nginx_http_proxy_connect_src_dir="$src_dir/ngx_http_proxy_connect_module"
nginx_http_upload_src_dir="$src_dir/nginx_upload_module-2.2.0"
openssl="$src_dir/openssl-1.0.1r"

#echo "curr_path: $curr_path"
#echo "src_dir: $src_dir"
#echo "build_dir: $build_dir"
#echo "nginx_src_dir: $nginx_src_dir"
#echo "nginx_rtmp_src_dir: $nginx_rtmp_src_dir"
#echo "nginx_http_proxy_connect_src_dir: $nginx_http_proxy_connect_src_dir"
#echo "nginx_http_upload_src_dir: $src_dir/nginx_upload_module-2.2.0"

# enter source folder
cd $src_dir

# enter nginx source folder
cd $nginx_src_dir
# 仅第一次编译使用
#patch -p1 < $nginx_http_proxy_connect_src_dir/proxy_connect.patch
export CFLAGS="-DNGX_HAVE_OPENSSL_MD5_H -DNGX_HAVE_OPENSSL_SHA1_H"
./configure --prefix=$build_dir --add-module=$nginx_rtmp_src_dir --add-module=$nginx_http_proxy_connect_src_dir --add-module=$nginx_http_upload_src_dir --with-http_ssl_module --with-stream || exit 1
make || exit 1
make install || exit 1
cd ..

# back to the current folder
cd $curr_path
