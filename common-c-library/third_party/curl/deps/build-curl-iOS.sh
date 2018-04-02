#!/bin/sh
# Curl build script for iOS
# Author:	Max.Chiu

# Config Curl version
VERSION="7.56.1"

# Configure enviroment
export IPHONEOS_DEPLOYMENT_TARGET="8.0"

DEVELOPER="/Applications/Xcode.app/Contents/Developer"

function configure_prefix {
	export PREFIX=$(pwd)/out.iOS/$ARCH

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

	export EXTRA_CFLAGS="-I$PREFIX/include $EXTRA_CFLAGS" 
	export EXTRA_LDFLAGS="-L$PREFIX/lib $EXTRA_LDFLAGS "
	
	export CFLAGS="-arch ${ARCH} -isysroot ${SYSROOT} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET} -Wunguarded-availability"
	export OpenSSL=$(pwd)/out.iOS/$ARCH
}

function configure_i386 {
	export PLATFORM="iphonesimulator"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	
	export ARCH=i386
	export HOST=$ARCH-apple-darwin
	
	export EXTRA_CFLAGS=""
	
	configure_prefix
}

function configure_x86_64 {
	export PLATFORM="iphonesimulator"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	
	export ARCH=x86_64
	export HOST=$ARCH-apple-darwin
	
	export EXTRA_CFLAGS=""
	
	configure_prefix
}

function configure_armv7 {
	export PLATFORM="iphoneos"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	
	export ARCH=armv7
	export HOST=$ARCH-apple-darwin
	
	configure_prefix
}

function configure_arm64 {
	export PLATFORM="iphoneos"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	
	export ARCH=arm64
	export HOST=arm-apple-darwin
	
	configure_prefix
}

function show_enviroment {
	echo "# ################################ $ARCH ################################ #"
	echo "ARCH : $ARCH"
	echo "HOST : $HOST"
	echo "PLATFORM : $PLATFORM"
	echo "SYSROOT : $SYSROOT"
	echo "CFLAGS : $CFLAGS"
	echo "LDFLAGS : $LDFLAGS"
	echo "CROSS_COMPILE_PREFIX : $CROSS_COMPILE_PREFIX"
	echo "PREFIX : $PREFIX"
	echo "EXTRA_CFLAGS : $EXTRA_CFLAGS"
	echo "EXTRA_LDFLAGS : $EXTRA_LDFLAGS"
	echo "# ################################ $ARCH ################################ #"
}

function build_curl {
	echo "# Start building curl for $ARCH"
	FFMPEG="curl-$VERSION"
	cd $FFMPEG
	
	# build
	./configure --prefix=$PREFIX --disable-shared --enable-static --host="$HOST" --with-ssl=${OpenSSL}

	make clean || exit 1
	make || exit
	make install || exit 1

	cd ..
	echo "# Build curl finish for $ARCH"
}

function combine {
	echo "# Starting combining..."
	cd "out.iOS"
	
	mkdir universal
	lipo armv7/lib/libcurl.a arm64/lib/libcurl.a i386/lib/libcurl.a x86_64/lib/libcurl.a -create -output universal/libcurl.a
	
	cd ..
	echo "# Combine finish"
}

# Start Build
#BUILD_ARCH=(armv7 arm64 i386 x86_64)
BUILD_ARCH=(i386 x86_64)

echo "# Starting building..."

for var in ${BUILD_ARCH[@]};do
	echo "##############################################################################################"
	echo "##############################################################################################"
	configure_$var
	echo "# Starting building for $ARCH..."
	show_enviroment
	build_curl || exit 1
	echo "# Build for $ARCH finish"
done

combine

echo "# Build finish" 