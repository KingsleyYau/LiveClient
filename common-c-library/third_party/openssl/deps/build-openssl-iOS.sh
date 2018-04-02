#!/bin/sh
# OpenSSL build script for iOS
# Author:	Max.Chiu

# Config OpenSSL version
VERSION="1.0.1r"
#VERSION=3.2.1

# Configure enviroment
export IPHONEOS_DEPLOYMENT_TARGET="8.0"

DEVELOPER="/Applications/Xcode.app/Contents/Developer"

function configure_prefix {
	export PREFIX=$(pwd)/out.iOS/$ARCH

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
	
}

function configure_i386 {
	export PLATFORM="iphonesimulator"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	export CROSS_TOP=`xcrun --sdk $PLATFORM --show-sdk-platform-path`"/Developer"
	export CROSS_SDK="iPhoneSimulator.sdk"
	
	export ARCH=i386
	export HOST=$ARCH-apple-darwin
	
	export EXTRA_CFLAGS=""
	export CONFIG_PARAM="no-asm"
	
	configure_prefix
}

function configure_x86_64 {
	export PLATFORM="iphonesimulator"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	export CROSS_TOP=`xcrun --sdk $PLATFORM --show-sdk-platform-path`"/Developer"
	export CROSS_SDK="iPhoneSimulator.sdk"
	
	export ARCH=x86_64
	export HOST=$ARCH-apple-darwin
	
	export EXTRA_CFLAGS=""
	export CONFIG_PARAM="no-asm"
	
	configure_prefix
}

function configure_armv7 {
	export PLATFORM="iphoneos"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	export CROSS_TOP=`xcrun --sdk $PLATFORM --show-sdk-platform-path`"/Developer"
	export CROSS_SDK="iPhoneOS.sdk"
	
	export ARCH=armv7
	export HOST=$ARCH-apple-darwin
	
	configure_prefix
}

function configure_arm64 {
	export PLATFORM="iphoneos"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	export CROSS_TOP=`xcrun --sdk $PLATFORM --show-sdk-platform-path`"/Developer"
	export CROSS_SDK="iPhoneOS.sdk"
	
	export ARCH=arm64
	export HOST=armv7s-apple-darwin
		
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

function build_openssl {
	echo "# Start building openssl for $ARCH"
	OPENSSL="openssl-$VERSION"
	cd $OPENSSL

	export CC="$(xcrun --sdk $PLATFORM -f clang) -arch ${ARCH} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET} -fembed-bitcode"
	
	# build
	./Configure iphoneos-cross no-ssl2 no-ssl3 no-hw no-shared $CONFIG_PARAM --openssldir="$PREFIX" \
    					|| exit 1

	#perl -i -pe "s|CFLAG= (.*)|CFLAG= -isysroot ${SYSROOT}|g" Makefile
	make depend
	make clean || exit 1
	make || exit
	make install # install doc may be fail, ignore it

	cd ..
	echo "# Build openssl finish for $ARCH"
}

function combine {
	echo "# Starting combining..."
	cd "out.iOS"
	
	mkdir universal
	lipo armv7/lib/libssl.a arm64/lib/libssl.a i386/lib/libssl.a x86_64/lib/libssl.a -create -output universal/libssl.a
	lipo armv7/lib/libcrypto.a arm64/lib/libcrypto.a i386/lib/libcrypto.a x86_64/lib/libcrypto.a -create -output universal/libcrypto.a
	
	cd ..
	echo "# Combine finish"
}

# Start Build
BUILD_ARCH=(armv7 arm64 i386 x86_64)
#BUILD_ARCH=(armv7)

echo "# Starting building..."

for var in ${BUILD_ARCH[@]};do
	echo "##############################################################################################"
	echo "##############################################################################################"
	configure_$var
	echo "# Starting building for $ARCH..."
	show_enviroment
	build_openssl || exit 1
	echo "# Build for $ARCH finish"
done

combine

echo "# Build finish" 