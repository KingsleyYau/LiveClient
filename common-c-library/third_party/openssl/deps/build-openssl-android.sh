#!/bin/sh
# OpenSSL build script for android
# Author:	Max.Chiu
# Description: asm

# Config version
VERSION=1.0.1r

# Configure enviroment
export ANDROID_NDK_ROOT="/Applications/Android/android-ndk"
export TOOLCHAIN=$(pwd)/toolchain
export SYSROOT=$TOOLCHAIN/sysroot
#export ANDROID_API=android-21
#export TOOLCHAIN_VERSION=4.9

function configure_toolchain {
	if [ -d $TOOLCHAIN ]; then
		rm -rf $TOOLCHAIN
	fi
	$ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh \
	    --toolchain=$ANDROID_EABI \
	    --platform=$ANDROID_API --install-dir=$TOOLCHAIN 
	    
	export ANDROID_DEV="$SYSROOT/usr"
}

function configure_prefix {
	export PREFIX=$(pwd)/out.android/$ARCH_ABI

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

	export EXTRA_CFLAGS="-I$PREFIX/include" 
	export EXTRA_LDFLAGS="-L$PREFIX/lib"
}

function configure_arm {
	export ANDROID_API=android-9
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=armeabi
	export ARCH=arm
	export ANDROID_ARCH=arch-arm
	export ANDROID_EABI="arm-linux-androideabi-$TOOLCHAIN_VERSION"
	export ANDROID_CONFIG=android
	export CROSS_COMPILE_CUSTOM="arm-linux-androideabi-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM
		
	export CONFIG_PARAM=""

	export OPTIMIZE_CFLAGS="-marm -march=armv5"

	configure_prefix
}

function configure_armv7a {
	export ANDROID_API=android-9
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=armeabi-v7a
	export ARCH=arm
	export ANDROID_ARCH=arch-arm
	export ANDROID_EABI="arm-linux-androideabi-$TOOLCHAIN_VERSION"
	export ANDROID_CONFIG=android-armv7
	export CROSS_COMPILE_CUSTOM="arm-linux-androideabi-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM
	export EXTRA_CFLAGS="$EXTRA_CFLAGS -mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a "
	
	export CONFIG_PARAM=""

	export OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a"

	configure_prefix
}

function configure_arm64 {
	export ANDROID_API=android-21
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=arm64-v8a
	export ARCH=aarch64
	export ANDROID_ARCH=arch-arm64
	export ANDROID_EABI="aarch64-linux-android-$TOOLCHAIN_VERSION"
	export ANDROID_CONFIG=android
	export CROSS_COMPILE_CUSTOM="aarch64-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM
	
	export CONFIG_PARAM=""
	
	export OPTIMIZE_CFLAGS=""
	
	configure_prefix
}

function configure_x86 {
	export ANDROID_API=android-9
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=x86
	export ARCH=x86
	export ANDROID_ARCH=arch-x86
	export ANDROID_EABI="x86-$TOOLCHAIN_VERSION"
	export ANDROID_CONFIG=android-x86
	export CROSS_COMPILE_CUSTOM="i686-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM

	export CONFIG_PARAM="no-asm"

	export OPTIMIZE_CFLAGS="-m32"

	configure_prefix
}

function show_enviroment {
	echo "####################### $ANDROID_ARCH ###############################"
	echo "### Common config ###"
	echo "PREFIX : $PREFIX"
	echo "SYSROOT : $SYSROOT"

	echo "PKG_CONFIG_LIBDIR : $PKG_CONFIG_LIBDIR"
	echo "PKG_CONFIG_PATH : $PKG_CONFIG_PATH"
	
	echo "CROSS_COMPILE_CUSTOM : $CROSS_COMPILE_CUSTOM"
	echo "CROSS_COMPILE_PREFIX : $CROSS_COMPILE_PREFIX"
	echo "CONFIG_PARAM : $CONFIG_PARAM"

	echo "###  OpenSSL config ###"
	echo "ANDROID_DEV : $ANDROID_DEV"
	
	echo "### Android config ###"
	echo "ANDROID_NDK_ROOT : $ANDROID_NDK_ROOT"
	echo "ANDROID_API : $ANDROID_API"
	echo "ANDROID_ARCH : $ANDROID_ARCH"
	echo "ANDROID_EABI : $ANDROID_EABI"
	echo "ANDROID_CONFIG : $ANDROID_CONFIG"
	echo "TOOLCHAIN : $TOOLCHAIN"
	echo "TOOLCHAIN_VERSION : $TOOLCHAIN_VERSION"
	echo "####################### $ANDROID_ARCH enviroment ok ###############################"
}

 
function build_openssl {
	echo "# Start building OpenSSL for $ARCH_ABI"
	OUTPUT="openssl-$VERSION"
	cd $OUTPUT
	
	export CC="${CROSS_COMPILE_PREFIX}gcc"
	export CXX="${CROSS_COMPILE_PREFIX}g++"
	export AR="${CROSS_COMPILE_PREFIX}ar"
	export LD="${CROSS_COMPILE_PREFIX}ld"
	export AS="${CROSS_COMPILE_PREFIX}as"
	export NM="${CROSS_COMPILE_PREFIX}nm"
	export RANLIB="${CROSS_COMPILE_PREFIX}ranlib"
	export STRIP="${CROSS_COMPILE_PREFIX}strip"
	
	# build
	./Configure $ANDROID_CONFIG no-ssl2 no-ssl3 no-hw no-shared $CONFIG_PARAM --openssldir="$PREFIX" \
    					|| exit 1
    
	make clean || exit 1
	make depend || exit 1
	make || exit 1
	make install # install doc may be fail, ignore it
	
	cd ..
	echo "# Build OpenSSL finish for $ARCH_ABI"
}

# Start Build
BUILD_ARCH=(arm armv7a x86 arm64)
#BUILD_ARCH=(arm64)

echo "# Starting building..."

for var in ${BUILD_ARCH[@]};do
	configure_$var
	configure_toolchain
	show_enviroment
	echo "# Starting building for $ARCH_ABI..."
	build_openssl || exit 1
	rm -rf $TOOLCHAIN || exit 1
	echo "# Starting building for $ARCH_ABI finish..."
done

echo "# Build finish" 