#!/bin/sh
# ffmpeg build script for linux
# Author:	Max.Chiu
# Description: asm

# Config version
VERSION=2.8.7
#VERSION=3.2.1

function build_x264 {
	echo "# Start building x264"
	
	cd x264
	./configure \
				--prefix=$PREFIX \
				--enable-static \
				--enable-pic \
				--disable-cli \
				--disable-asm \
				|| exit 1
    		
    		
	make clean || exit 1
	make || exit 1
	make install || exit 1
	
	cd ..
	echo "# Build x264 finish"
}

function build_fdk_aac {
	echo "# Start building fdk-aac"

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig/
  export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/
    
	cd fdk-aac-0.1.5
	
	./configure \
				--prefix=$PREFIX \
				--enable-static \
				--disable-shared \
				--with-pic \
				|| exit 1

	make clean || exit 1
	make || exit 1
	make install || exit 1
	
	cd ..
	echo "# Build fdk-aac finish"
}

function build_ffmpeg {
	echo "# Start building ffmpeg"
	FFMPEG="ffmpeg-$VERSION"
	cd $FFMPEG

	export CC="$(xcrun --sdk $PLATFORM -f clang)"

	# build
	./configure \
						--prefix="$PREFIX" \
						--disable-shared \
						--enable-static \
						--enable-gpl \
						--enable-libx264 \
						--enable-nonfree \
    				--enable-libfdk-aac \
				    --disable-doc \
				    --enable-version3 \
    				--enable-small \
    				--disable-vda \
   					--disable-iconv \
    				--disable-outdevs \
    				--disable-ffprobe \
    				--disable-ffplay \
    				--disable-ffserver \
    				--disable-asm \
						--disable-encoders \
				    --enable-encoder=libx264 \
				    --enable-encoder=aac \
				    --disable-decoders \
				    --enable-decoder=h264 \
				    --enable-decoder=libfdk_aac \
    				--disable-demuxers \
    				--enable-demuxer=h264 \
    				--disable-parsers \
    				--enable-parser=h264 \
    				|| exit 1
    				
						
	make clean || exit 1
	make || exit
	make install || exit 1

	cd ..
	echo "# Build ffmpeg finis"
}

# Start Build

echo "# Starting building..."

export PREFIX=$(pwd)/build/

build_fdk_aac || exit 1
build_x264 || exit 1
build_ffmpeg || exit 1
	
echo "# Build finish" 