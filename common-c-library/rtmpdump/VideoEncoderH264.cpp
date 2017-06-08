/*
 * VideoEncoderH264.cpp
 *
 *  Created on: 2017年5月8日
 *      Author: max
 */

#include "VideoEncoderH264.h"

#include <common/KLog.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
}

VideoEncoderH264::VideoEncoderH264() {
	// TODO Auto-generated constructor stub
	mCodec = NULL;
	mContext = NULL;

    mDecoderFormat = AV_PIX_FMT_NV21;
}

VideoEncoderH264::~VideoEncoderH264() {
	// TODO Auto-generated destructor stub
	Destroy();
}

bool VideoEncoderH264::Create(int width, int height, int frameInterval, int bitRate, int keyFrameInterval) {
	FileLog("rtmpdump", "VideoEncoderH264::Create( "
			"this : %p, "
			"avcodec_version : %d, "
			"width : %d, "
			"height : %d, "
			"frameInterval : %d, "
			"bitRate : %d,"
			"keyFrameInterval : %d "
			")",
			this,
			avcodec_version(),
			width,
			height,
			frameInterval,
			bitRate,
			keyFrameInterval
			);

    bool result = true;

	avcodec_register_all();
    av_log_set_level(AV_LOG_ERROR);

    mCodec = avcodec_find_encoder(AV_CODEC_ID_H264);
    if (!mCodec) {
    	// codec not found
    	FileLog("rtmpdump",
    			"VideoEncoderH264::Create( "
    			"[Codec not found], "
    			"this : %p "
    			")",
				this
				);
    	result = false;
    }

    if( result ) {
        mContext = avcodec_alloc_context3(mCodec);

        mContext->codec_type = AVMEDIA_TYPE_VIDEO;

        // 宽高
        mContext->width = width;
        mContext->height = height;
        // 帧率
        mContext->time_base = (AVRational){1, frameInterval};
        // 码率
        mContext->bit_rate = bitRate;
        // 关键帧间隔
        mContext->gop_size = keyFrameInterval;
        // 无B Frame
        mContext->max_b_frames  = 0;
        // 输入格式
        mContext->pix_fmt = (AVPixelFormat)mDecoderFormat;
    }

	if( !result ) {
		Destroy();
		FileLog("rtmpdump",
				"VideoEncoderH264::Create( "
				"[Fail], "
				"this : %p "
				")",
				this
				);
	}

	return result;
}

void VideoEncoderH264::Destroy() {
	FileLog("rtmpdump",
			"VideoEncoderH264::Destroy( "
			"this : %p "
			")",
			this
			);

	if( mContext ) {
		avcodec_close(mContext);
		mContext = NULL;
	}

	mCodec = NULL;
}

VideoBuffer* VideoEncoderH264::GetBuffer() {
	VideoBuffer* decoderBuffer = NULL;
	mFinishBufferList.lock();
	if( !mFinishBufferList.empty() ) {
		decoderBuffer = (VideoBuffer *)mFinishBufferList.front();
		mFinishBufferList.pop_front();
	}
	mFinishBufferList.unlock();
	return decoderBuffer;
}

void VideoEncoderH264::ReleaseBuffer(VideoBuffer* decoderBuffer) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(decoderBuffer);
	mFreeBufferList.unlock();
}

void VideoEncoderH264::EncodeVideoFrame(const char* data, int size, u_int32_t timestamp) {
	mFreeBufferList.lock();
	VideoBuffer* decodeBuffer = NULL;
	if( !mFreeBufferList.empty() ) {
		decodeBuffer = (VideoBuffer *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		decodeBuffer = new VideoBuffer();
	}
	mFreeBufferList.unlock();

	decodeBuffer->ResetFrame();
	decodeBuffer->RenewBufferSize(size);

	bool bFlag = false;
	bFlag = EncodeVideoFrame(data, size, decodeBuffer);
	if( bFlag ) {
		mFinishBufferList.lock();
		mFinishBufferList.push_back(decodeBuffer);
		mFinishBufferList.unlock();

	} else {
		mFreeBufferList.lock();
		mFreeBufferList.push_back(decodeBuffer);
		mFreeBufferList.unlock();
	}

}

bool VideoEncoderH264::EncodeVideoFrame(const char* data, int size, VideoBuffer* bufferFrame) {
	bool bFlag = false;

    if ( NULL != data &&
    		size > 0 &&
			NULL != bufferFrame &&
			NULL != mContext ) {

    	// 原始图像数据
    	AVFrame *pFrame = av_frame_alloc();
        pFrame->width = mContext->width;
        pFrame->height = mContext->height;
        pFrame->format = (AVPixelFormat)mDecoderFormat;

        // 编码后数据
        AVPacket packet = {0};
        av_init_packet(&packet);

        packet.data = (uint8_t*)bufferFrame->GetBuffer();
        packet.size = bufferFrame->mBufferLen;

        int gotFrame = 0;
    	int ret = avcodec_encode_video2(mContext, &packet, pFrame, &gotFrame);
    	if ( ret == 0 && gotFrame == 1 ) {
    		// 编码得到一帧
    		bFlag = true;
    	}

    	if( pFrame ) {
    		av_free(pFrame);
    	}
    }

	return bFlag;
}
