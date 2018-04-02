#!/bin/sh
# Curl build script for android
# Author:	Max.Chiu
# Description: asm

# Config version
VERSION="7.56.1"

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
	   
}

function configure_prefix {
	export PREFIX=$(pwd)/out.android/$ARCH_ABI

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

	export EXTRA_CFLAGS="-I$PREFIX/include $EXTRA_CFLAGS" 
	export EXTRA_LDFLAGS="-L$PREFIX/lib $EXTRA_LDFLAGS "
	
	export OpenSSL=$(pwd)/out.android/$ARCH_ABI
	
}

function configure_arm {
	export HOST=arm-linux-androideabi

	export ANDROID_API=android-9
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=armeabi
	export ARCH=arm
	export ANDROID_ARCH=arch-arm
	export ANDROID_EABI="arm-linux-androideabi-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE_CUSTOM="arm-linux-androideabi-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM
		
	export CONFIG_PARAM=""

	export OPTIMIZE_CFLAGS="-marm -march=armv5"

	configure_prefix
}

function configure_armv7a {
	export HOST=arm-linux-androideabi

	export ANDROID_API=android-9
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=armeabi-v7a
	export ARCH=arm
	export ANDROID_ARCH=arch-arm
	export ANDROID_EABI="arm-linux-androideabi-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE_CUSTOM="arm-linux-androideabi-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM
	export EXTRA_CFLAGS="$EXTRA_CFLAGS -mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a "
	
	export CONFIG_PARAM=""

	export OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a"

	configure_prefix
}

function configure_arm64 {
	export HOST=aarch64-linux-android

	export ANDROID_API=android-21
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=arm64-v8a
	export ARCH=aarch64
	export ANDROID_ARCH=arch-arm64
	export ANDROID_EABI="aarch64-linux-android-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE_CUSTOM="aarch64-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM
	
	export CONFIG_PARAM=""
	
	export OPTIMIZE_CFLAGS=""
	
	configure_prefix
}

function configure_x86 {
	export HOST=i686-linux-android
	
	export ANDROID_API=android-9
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=x86
	export ARCH=x86
	export ANDROID_ARCH=arch-x86
	export ANDROID_EABI="x86-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE_CUSTOM="i686-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE_CUSTOM

	export CONFIG_PARAM="no-asm"

	export OPTIMIZE_CFLAGS="-m32"

	configure_prefix
}

function show_enviroment {
	echo "####################### $ARCH_ABI ###############################"
	echo "### Common config ###"
	echo "PREFIX : $PREFIX"
	echo "SYSROOT : $SYSROOT"

	echo "PKG_CONFIG_LIBDIR : $PKG_CONFIG_LIBDIR"
	echo "PKG_CONFIG_PATH : $PKG_CONFIG_PATH"
	
	echo "CROSS_COMPILE_CUSTOM : $CROSS_COMPILE_CUSTOM"
	echo "CROSS_COMPILE_PREFIX : $CROSS_COMPILE_PREFIX"
	echo "CONFIG_PARAM : $CONFIG_PARAM"
	
	echo "### Curl config ###"
	echo "HOST : $HOST"
	echo "OpenSSL : $OpenSSL"

	echo "### Android config ###"
	echo "ANDROID_NDK_ROOT : $ANDROID_NDK_ROOT"
	echo "ANDROID_API : $ANDROID_API"
	echo "ANDROID_ARCH : $ANDROID_ARCH"
	echo "ANDROID_EABI : $ANDROID_EABI"
	echo "TOOLCHAIN : $TOOLCHAIN"
	echo "TOOLCHAIN_VERSION : $TOOLCHAIN_VERSION"
	echo "####################### $ARCH_ABI enviroment ok ###############################"
}

 
function build_curl {
	echo "# Start building Curl for $ARCH_ABI"
	OUTPUT="curl-$VERSION"
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
	./configure --prefix=$PREFIX --disable-shared --enable-static --host="$HOST" --with-ssl=${OpenSSL}
    
	make clean || exit 1
	make || exit 1
	make install # install doc may be fail, ignore it
	
	cd ..
	echo "# Build Curl finish for $ARCH_ABI"
}

# Start Build
BUILD_ARCH=(arm armv7a x86 arm64)
#BUILD_ARCH=(arm)

echo "# Starting building..."

for var in ${BUILD_ARCH[@]};do
	configure_$var
	configure_toolchain
	show_enviroment
	echo "# Starting building for $ARCH_ABI..."
	build_curl || exit 1
	rm -rf $TOOLCHAIN || exit 1
	echo "# Starting building for $ARCH_ABI finish..."
done

echo "# Build finish" 