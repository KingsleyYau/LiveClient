#!/bin/sh
# ffmpeg build script for linux
# Author:	Max.Chiu
# Description: asm

# Config version
VERSION=2.8.7
#VERSION=3.2.1

function configure_prefix {
	export PREFIX=$(pwd)/build

	export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
	export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

	export EXTRA_CFLAGS="-I$PREFIX/include $EXTRA_CFLAGS" 
	export EXTRA_LDFLAGS="-L$PREFIX/lib $EXTRA_LDFLAGS "
}

function build_lame {
	echo "# Start building lame"
	
	cd lame-3.99.5
	./configure \
				--prefix=$PREFIX \
				--enable-static \
				--disable-shared \
				|| exit 1   		
    		
	make clean || exit 1
	make || exit 1
	make install || exit 1
	
	cd ..
	echo "# Build lame finish"
}

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

	#export CC="$(xcrun --sdk $PLATFORM -f clang)"

	# build
	./configure \
						--prefix="$PREFIX" \
						--extra-cflags="$EXTRA_CFLAGS" \
						--extra-ldflags="$EXTRA_LDFLAGS" \
						--disable-shared \
						--enable-static \
						--enable-gpl \
						--enable-libx264 \
						--enable-nonfree \
    				--enable-libfdk-aac \
    				--enable-libmp3lame \
				    --enable-version3 \
    				--enable-small \
    				--disable-vda \
   					--disable-iconv \
    				--disable-outdevs \
    				--disable-ffprobe \
    				--disable-asm \
				    --enable-encoder=libx264 \
				    --enable-encoder=libfdk_aac \
				    --enable-decoder=libx264 \
				    --enable-decoder=libfdk_aac \
    				--enable-demuxer=h264 \
    				--enable-parser=h264 \
    				|| exit 1
    				
						
	make clean || exit 1
	make || exit
	make install || exit 1

	cd ..
	echo "# Build ffmpeg finish"
}

# Start Build

echo "# Starting building..."

configure_prefix || exit 1
#build_fdk_aac || exit 1
#build_lame || exit 1
#build_x264 || exit 1
build_ffmpeg || exit 1
	
echo "# Build finish" 