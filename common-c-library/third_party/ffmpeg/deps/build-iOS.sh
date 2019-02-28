#!/bin/sh
# ffmpeg build script for android
# Author:	Max.Chiu
# Description: asm

# Config version
VERSION=2.8.7
#VERSION=3.2.1

# Configure enviroment
export IPHONEOS_DEPLOYMENT_TARGET="8.0"

DEVELOPER="/Applications/Xcode.app/Contents/Developer"

function configure_prefix {
	export PREFIX=$(pwd)/out.iOS/$ARCH

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

	export EXTRA_CFLAGS="-I$PREFIX/include $EXTRA_CFLAGS" 
	export EXTRA_LDFLAGS="-L$PREFIX/lib $EXTRA_LDFLAGS "
	
	export CFLAGS="-arch ${ARCH} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET} -isysroot ${SYSROOT}"
	export LDFLAGS="-arch ${ARCH} -isysroot ${SYSROOT}"
}

function configure_i386 {
	export PLATFORM="iphonesimulator"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	
	export ARCH=i386
	export HOST=$ARCH-apple-darwin
	
	#toolchain=$(xcrun --sdk $PLATFORM -f clang)
	#export CROSS_COMPILE_PREFIX="`dirname $toolchain`/"
	
	export EXTRA_CFLAGS=""
	
	configure_prefix
}

function configure_x86_64 {
	export PLATFORM="iphonesimulator"
	
	export SYSROOT=`xcrun --sdk $PLATFORM --show-sdk-path`
	
	export ARCH=x86_64
	export HOST=$ARCH-apple-darwin
	
	#toolchain=$(xcrun --sdk $PLATFORM -f clang)
	#export CROSS_COMPILE_PREFIX="`dirname $toolchain`/"
	
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
	export HOST=armv7s-apple-darwin
	
	configure_prefix
}

function show_enviroment {
	echo "####################### $ARCH ###############################"
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
	echo "####################### $ANDROID_ARCH enviroment ok ###############################"
}

 
function build_x264 {
	echo "# Start building x264 for $ARCH"
	
	cd x264
	./configure \
				--prefix=$PREFIX \
				--sysroot=$SYSROOT \
				--cross-prefix=$CROSS_COMPILE_PREFIX \
    		--extra-cflags=$EXTRA_CFLAGS \
				--extra-ldflags=$EXTRA_LDFLAGS \
				--host=$HOST \
				--enable-static \
				--enable-pic \
				--disable-cli \
				--disable-asm \
				$CONFIG_PARAM \
				|| exit 1
    		
    		
	make clean || exit 1
	make || exit 1
	make install || exit 1
	
	cd ..
	echo "# Build x264 finish for $ARCH"
}

function build_fdk_aac {
	echo "# Start building fdk-aac for $ARCH"
		
	export CC="$(xcrun --sdk $PLATFORM -f clang) --sysroot=${SYSROOT} -arch ${ARCH} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
	export CXX="$(xcrun --sdk $PLATFORM -f clang++) --sysroot=${SYSROOT} -arch ${ARCH} -miphoneos-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
	
	export CFLAGS="$CFLAGS $OPTIMIZE_CFLAGS"
		
	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig/
  export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
    
	cd fdk-aac-0.1.5
	
	./configure \
				--prefix=$PREFIX \
				--host=$HOST \
				--enable-static \
				--disable-shared \
				--with-pic \
				$CONFIG_PARAM \
				|| exit 1
    		
    		
	make clean || exit 1
	make || exit 1
	make install || exit 1
	
	cd ..
	echo "# Build fdk-aac finish for $ARCH"
}

function build_ffmpeg {
	echo "# Start building ffmpeg for $ARCH"
	FFMPEG="ffmpeg-$VERSION"
	cd $FFMPEG

	export CC="$(xcrun --sdk $PLATFORM -f clang)"

	# build
	./configure \
						--prefix="$PREFIX" \
						--extra-cflags="$EXTRA_CFLAGS" \
						--extra-ldflags="$EXTRA_LDFLAGS" \
						--enable-cross-compile \
						--cross-prefix=$CROSS_COMPILE_PREFIX \
						--cc=$CC \
						--ar=$AR \
						--target-os=linux \
						--sysroot="$SYSROOT" \
    				--arch=$ARCH \
						--disable-shared \
						--enable-static \
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
				    --enable-encoder=mjpeg \
				    --enable-encoder=libfdk_aac \
				    --disable-decoders \
				    --enable-decoder=libx264 \
				    --enable-decoder=mjpeg \
				    --enable-decoder=libfdk_aac \
    				--disable-demuxers \
    				--enable-demuxer=h264 \
    				--enable-demuxer=mjpeg \
    				--disable-parsers \
    				--enable-parser=h264
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
	echo "# Build ffmpeg finish for $ARCH"
}

function combine {
	echo "# Starting combining..."
	cd "out.iOS"
	
	lipo armv7/lib/libfdk-aac.a arm64/lib/libfdk-aac.a i386/lib/libfdk-aac.a x86_64/lib/libfdk-aac.a -create -output universal/libfdk-aac.a
	lipo armv7/lib/libx264.a arm64/lib/libx264.a i386/lib/libx264.a x86_64/lib/libx264.a -create -output universal/libx264.a
	lipo armv7/lib/libavcodec.a arm64/lib/libavcodec.a i386/lib/libavcodec.a x86_64/lib/libavcodec.a -create -output universal/libavcodec.a
	lipo armv7/lib/libavdevice.a arm64/lib/libavdevice.a i386/lib/libavdevice.a x86_64/lib/libavdevice.a -create -output universal/libavdevice.a
	lipo armv7/lib/libavfilter.a arm64/lib/libavfilter.a i386/lib/libavfilter.a x86_64/lib/libavfilter.a -create -output universal/libavfilter.a
	lipo armv7/lib/libavformat.a arm64/lib/libavformat.a i386/lib/libavformat.a x86_64/lib/libavformat.a -create -output universal/libavformat.a
	lipo armv7/lib/libavutil.a arm64/lib/libavutil.a i386/lib/libavutil.a x86_64/lib/libavutil.a -create -output universal/libavutil.a
	lipo armv7/lib/libpostproc.a arm64/lib/libpostproc.a i386/lib/libpostproc.a x86_64/lib/libpostproc.a -create -output universal/libpostproc.a
	lipo armv7/lib/libswresample.a arm64/lib/libswresample.a i386/lib/libswresample.a x86_64/lib/libswresample.a -create -output universal/libswresample.a
	lipo armv7/lib/libswscale.a arm64/lib/libswscale.a i386/lib/libswscale.a x86_64/lib/libswscale.a -create -output universal/libswscale.a
	
	cd ..
	echo "# Combine finish"
}

# Start Build
BUILD_ARCH=(armv7 arm64 i386 x86_64)
#BUILD_ARCH=(i386 x86_64)

echo "# Starting building..."

for var in ${BUILD_ARCH[@]};do
	configure_$var
	show_enviroment
	echo "# Starting building for $ARCH..."
	#build_fdk_aac || exit 1
	build_x264 || exit 1
	build_ffmpeg || exit 1
	echo "# Build for $ARCH finish"
done

combine

echo "# Build finish" 