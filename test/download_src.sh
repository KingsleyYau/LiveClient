#!/bin/sh
# nginx dependence download script
# Author:	Max.Chiu
# Description:

src_dir="./src"
nginx_ver="1.11.10"
nginx_rtmp_mod_ver="1.1.11"

# make source folder and enter
mkdir -p $src_dir
cd $src_dir

# download nginx source 
nginx_src_url="http://nginx.org/download/nginx-1.11.10.tar.gz"
curl -O $nginx_src_url
# unpakcage source
tar zxvf nginx-$nginx_ver.tar.gz

# download nginx-rtmp-module
rtmp_module_url="https://github.com/arut/nginx-rtmp-module"
git clone $rtmp_module_url
# select tag
cd nginx-rtmp-module
git checkout -b v$nginx_rtmp_mod_ver
cd ..

# download nginx-rtmp-module
http_proxy_connect_module_url="https://github.com/chobits/ngx_http_proxy_connect_module"
git clone $http_proxy_connect_module_url

# back to root folder
cd ..
