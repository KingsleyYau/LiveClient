#!/bin/sh
# google breakpad build script
# Author:	Max.Chiu

mkdir -p deps
cd deps

wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
yum install devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++

yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto -y

wget https://github.com/git/git/archive/v2.2.1.tar.gz
tar zxvf v2.2.1.tar.gz
cd git-2.2.1
make configure
./configure --prefix=/usr/local
make all doc
make install install-doc install-html
cd ..

yum install zlib-devel bzip2-devel ncurses-devel sqlite-devel -y

wget --no-check-certificate https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz
tar zxvf Python-2.7.9.tar.xz
cd Python-2.7.9
./configure --prefix=/usr/local
make && make altinstall
cd ..

cd ..
 
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=`pwd`/depot_tools:"$PATH"

mkdir breakpad && cd breakpad
fetch breakpad
cd src
./configure && make
make check
make install
cd ..
cd ..

echo "Build Breakpad finish"