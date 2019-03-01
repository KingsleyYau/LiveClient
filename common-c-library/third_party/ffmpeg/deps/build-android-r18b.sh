#!/bin/sh
# ffmpeg build script for android
# Author:	Max.Chiu
# Description: asm
# NDK version should be r18b

# Config version
VERSION=2.8.7
#VERSION=3.2.1

# Configure enviroment
export ANDROID_NDK_ROOT="/Applications/Android/android-sdks-studio/ndk-bundle"
export TOOLCHAIN=$(pwd)/toolchain_new
export SYSROOT=$TOOLCHAIN/sysroot

function reset {
	export EXTRA_CFLAGS=""
	export EXTRA_LDFLAGS=""
	export CFLAGS=""
	export LDFLAGS=""
}

function configure_toolchain {
	if [ -d $TOOLCHAIN ]; then
		rm -rf $TOOLCHAIN
	fi
	$ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh \
	    --toolchain=$ANDROID_EABI \
	    --platform=$ANDROID_API --install-dir=$TOOLCHAIN 
}

function configure_toolchain_prefix {
	export CC="${CROSS_COMPILE_PREFIX}gcc --sysroot=${SYSROOT}"
	export CXX="${CROSS_COMPILE_PREFIX}g++ --sysroot=${SYSROOT}"
	export AR="${CROSS_COMPILE_PREFIX}ar"
	export LD="${CROSS_COMPILE_PREFIX}ld"
	#export AS="${CROSS_COMPILE_PREFIX}as"
	export NM="${CROSS_COMPILE_PREFIX}nm"
	export RANLIB="${CROSS_COMPILE_PREFIX}ranlib"
	export STRIP="${CROSS_COMPILE_PREFIX}strip"
}

function configure_prefix {
	export PREFIX=$(pwd)/out.android/$ARCH_ABI

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

	export EXTRA_CFLAGS="-I$PREFIX/include -ffunction-sections -fdata-sections"
	export EXTRA_LDFLAGS="-L$PREFIX/lib"
	
	configure_toolchain_prefix
}

function configure_armv7a {
	export ANDROID_API=android-16
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=armeabi-v7a
	export ARCH=arm
	export ANDROID_ARCH=arch-arm
	export ANDROID_EABI="arm-linux-androideabi-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE="arm-linux-androideabi-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE
	
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
	export CROSS_COMPILE="aarch64-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE
	
	export CONFIG_PARAM=""
	
	export OPTIMIZE_CFLAGS=""
	
	configure_prefix
}

function configure_x86 {
	export ANDROID_API=android-16
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=x86
	export ARCH=x86
	export ANDROID_ARCH=arch-x86
	export ANDROID_EABI="x86-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE="i686-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE

	export CONFIG_PARAM="--disable-asm"

	export OPTIMIZE_CFLAGS="-m32"

	configure_prefix
}

function configure_x86_64 {
	export ANDROID_API=android-21
	export TOOLCHAIN_VERSION=4.9
	
	export ARCH_ABI=x86_64
	export ARCH=x86_64
	export ANDROID_ARCH=arch-x86_64
	export ANDROID_EABI="x86_64-$TOOLCHAIN_VERSION"
	export CROSS_COMPILE="x86_64-linux-android-"
	export CROSS_COMPILE_PREFIX=$TOOLCHAIN/bin/$CROSS_COMPILE

	export CONFIG_PARAM="--disable-asm"

	export OPTIMIZE_CFLAGS="-m64"

	configure_prefix
}

function show_enviroment {
	echo "####################### $ANDROID_ARCH ###############################"
	echo "ANDROID_NDK_ROOT : $ANDROID_NDK_ROOT"
	echo "TOOLCHAIN : $TOOLCHAIN"
	echo "TOOLCHAIN_VERSION : $TOOLCHAIN_VERSION"
	echo "ANDROID_API : $ANDROID_API"
	echo "ANDROID_ARCH : $ANDROID_ARCH"
	echo "ANDROID_EABI : $ANDROID_EABI"
	echo "SYSROOT : $SYSROOT"
	echo "CROSS_COMPILE : $CROSS_COMPILE"
	echo "CROSS_COMPILE_PREFIX : $CROSS_COMPILE_PREFIX"
	echo "CONFIG_PARAM : $CONFIG_PARAM"
	echo "PREFIX : $PREFIX"
	echo "PKG_CONFIG_LIBDIR : $PKG_CONFIG_LIBDIR"
	echo "PKG_CONFIG_PATH : $PKG_CONFIG_PATH"
	echo "####################### $ANDROID_ARCH enviroment ok ###############################"
}

 
function build_x264 {
	echo "# Building [libx264] for $ARCH_ABI"
	
	cd x264
	
	export CFLAGS="$OPTIMIZE_CFLAGS"

	./configure \
				--prefix="$PREFIX" \
				--sysroot="$SYSROOT" \
    		--cross-prefix="$CROSS_COMPILE_PREFIX" \
    		--extra-cflags="$EXTRA_CFLAGS" \
				--extra-ldflags="$EXTRA_LDFLAGS" \
				--host=$ARCH-linux \
				--enable-static \
				--enable-pic \
				--disable-cli \
				$CONFIG_PARAM \
				|| exit 1
				#--disable-asm \ ffmpeg will link some asm method, so x264(arm64) must be built without this param, but x264(x86) must be built with this param
    		
    		
	make clean || exit 1
	make || exit 1
	make install || exit 1
		
	cd ..
	echo "# Build [libx264] finish for $ARCH_ABI"
}

function build_fdk_aac {
	echo "# Building [libfdk-aac] for $ARCH_ABI"
	    
	cd fdk-aac-0.1.5
	
	export CFLAGS="$EXTRA_CFLAGS $OPTIMIZE_CFLAGS"

	./configure \
				--prefix=$PREFIX \
				--host=$ARCH-linux \
				--enable-static \
				--disable-shared \
				--with-pic \
				|| exit 1 
    		
	make clean || exit 1
	make || exit 1
	make install || exit 1
	
	cd ..
	echo "# Build [libfdk-aac] finish for $ARCH_ABI"
}

function build_ffmpeg {
	echo "# Building [libffmpeg] for $ARCH_ABI"
	FFMPEG="ffmpeg-$VERSION"
	cd $FFMPEG
	
	# build
	rm -f config.log
	
	export CFLAGS="$OPTIMIZE_CFLAGS"
	export LDFLAGS=""
	
	./configure \
						--prefix="$PREFIX" \
						--extra-cflags="$EXTRA_CFLAGS" \
						--extra-ldflags="$EXTRA_LDFLAGS" \
						--target-os=linux \
						--enable-cross-compile \
						--sysroot=$SYSROOT \
    				--cross-prefix=$CROSS_COMPILE_PREFIX \
    				--arch=$ARCH \
						--disable-shared \
						--enable-static \
						--disable-indev=v4l2 \
						--enable-gpl \
						--enable-libx264 \
						--enable-nonfree \
    				--enable-libfdk-aac \
				    --disable-doc \
				    --enable-version3 \
    				--disable-vda \
   					--disable-iconv \
    				--disable-outdevs \
    				--disable-ffprobe \
    				--disable-ffplay \
    				--disable-ffserver \
    				--disable-asm \
						--disable-encoders \
				    --enable-encoder=libx264 \
				    --enable-encoder=libfdk_aac \
				    --disable-decoders \
				    --enable-decoder=libx264 \
				    --enable-decoder=libfdk_aac \
    				--disable-demuxers \
    				--enable-demuxer=h264 \
    				--disable-parsers \
    				--enable-parser=h264 \
    				$CONFIG_PARAM \
    				|| exit 1
    				#--enable-small \
    				#--disable-ffmpeg \
    				#--disable-debug \
						#--enable-runtime-cpudetect \
    				
						
	make clean || exit 1
	make || exit
	make install || exit 1

	cd ..
	echo "# Build [libffmpeg] finish for $ARCH_ABI"
}

function build_ffmpeg_so {
	${CROSS_COMPILE_PREFIX}ld -rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -L$PREFIX/lib -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so \
    $PREFIX/lib/libx264.a \
    $PREFIX/lib/libavcodec.a \
    $PREFIX/lib/libavfilter.a \
    $PREFIX/lib/libswresample.a \
    $PREFIX/lib/libavformat.a \
    $PREFIX/lib/libavutil.a \
    $PREFIX/lib/libswscale.a \
    $PREFIX/lib/libpostproc.a \
    $PREFIX/lib/libavdevice.a \
    -lc -lm -lz -ldl -llog
}

# Start Build
BUILD_ARCH=(armv7a arm64 x86 x86_64)
#BUILD_ARCH=(armv7a)

echo "# Starting building..."

for var in ${BUILD_ARCH[@]};do
	reset
	configure_$var
	show_enviroment
	configure_toolchain
	echo "# Building start for $ARCH_ABI..."
	build_x264 || exit 1
	build_fdk_aac || exit 1
	build_ffmpeg || exit 1
	echo "# Building finish for $ARCH_ABI..."
done

echo "# Build all finish" 