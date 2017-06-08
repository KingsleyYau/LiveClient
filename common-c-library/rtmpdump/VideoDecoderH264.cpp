/*
 * VideoDecoderH264.cpp
 *
 *  Created on: 2017年4月21日
 *      Author: max
 */

#include "VideoDecoderH264.h"

#include <common/KLog.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
}

const static unsigned char sync_bytes[] = {0x0, 0x0, 0x0, 0x1};

VideoDecoderH264::VideoDecoderH264() {
	// TODO Auto-generated constructor stub
	mCodec = NULL;
	mContext = NULL;

	mGotPicture = 0;
	mLen = 0;

    mDecoderFormat = AV_PIX_FMT_RGB565;

    mCorpFrame = NULL;
    mCorpBuffer = NULL;

    mNaluHeaderSize = 0;
}

VideoDecoderH264::~VideoDecoderH264() {
	// TODO Auto-generated destructor stub
	Destroy();
}

bool VideoDecoderH264::Create() {
	FileLog("rtmpdump", "VideoDecoderH264::Create( this : %p, avcodec_version : %d )", this, avcodec_version());

    bool result = true;
    avcodec_register_all();
    av_log_set_level(AV_LOG_ERROR);

	mCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
	if ( !mCodec ) {
		// codec not found
		FileLog("rtmpdump",
				"VideoDecoderH264::Create( "
				"[Codec not found], "
				"this : %p "
				")",
				this
				);

		result = false;
	}

	if( result ) {
		mContext = avcodec_alloc_context3(mCodec);
		if( (mCodec->capabilities & CODEC_CAP_TRUNCATED) ) {
			mContext->flags |= CODEC_FLAG_TRUNCATED;
		}

		if ( avcodec_open2(mContext, mCodec, NULL) < 0 ) {
			FileLog("rtmpdump",
					"VideoDecoderH264::Create( "
					"[Could not open codec], "
					"this : %p "
					")",
					this
					);
	        mContext = NULL;
			result = false;
		}
	}

	if( !result ) {
		Destroy();

		FileLog("rtmpdump",
				"VideoDecoderH264::Create( "
				"[Fail], "
				"this : %p "
				")",
				this
				);
	}

	return result;
}

void VideoDecoderH264::Destroy() {
	FileLog("rtmpdump",
			"VideoDecoderH264::Destroy( "
			"this : %p "
			")",
			this
			);

	if( mContext ) {
		avcodec_close(mContext);
		mContext = NULL;
	}

	mCodec = NULL;

    if (mCorpFrame) {
        av_free(mCorpFrame);
        mCorpFrame = NULL;
    }

    if (mCorpBuffer) {
        av_free(mCorpBuffer);
        mCorpBuffer = NULL;
    }

}

VideoBuffer* VideoDecoderH264::GetBuffer() {
	VideoBuffer* decoderBuffer = NULL;
	mFinishBufferList.lock();
	if( !mFinishBufferList.empty() ) {
		decoderBuffer = (VideoBuffer *)mFinishBufferList.front();
		mFinishBufferList.pop_front();
	}
	mFinishBufferList.unlock();
	return decoderBuffer;
}

void VideoDecoderH264::ReleaseBuffer(VideoBuffer* decoderBuffer) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(decoderBuffer);
	mFreeBufferList.unlock();
}

void VideoDecoderH264::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
	FileLog("rtmpdump",
			"VideoDecoderH264::DecodeVideoKeyFrame( "
			"sps_size : %d, "
			"pps_size : %d "
			")",
			sps_size,
			pps_size
			);

	mNaluHeaderSize = nalUnitHeaderLength;

	mSPS_PPS_IDR.SetBuffer(sync_bytes, sizeof(sync_bytes));
	mSPS_PPS_IDR.AddBuffer((const unsigned char*)sps, sps_size);

	mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
	mSPS_PPS_IDR.AddBuffer((const unsigned char*)pps, pps_size);
}

void VideoDecoderH264::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
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

	bool bFlag = false;
	bFlag = DecodeVideoFrame(data, size, decodeBuffer, video_type);
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

bool VideoDecoderH264::DecodeVideoFrame(const char* data, int size, VideoBuffer* bufferFrame, VideoFrameType video_type) {
    bool bFlag = false;

    if ( NULL != data &&
    		size > 0 &&
			NULL != bufferFrame &&
			NULL != mContext ) {
		AVPacket packet = {0};
		av_init_packet(&packet);

		bool bGotPPS = false;
	    const char *frame = NULL;
	    int frameSize = 0;

		if( video_type == VFT_IDR && mSPS_PPS_IDR.mBufferLen > 0 ) {
			mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
			mSPS_PPS_IDR.AddBuffer((const unsigned char*)data + mNaluHeaderSize, size - mNaluHeaderSize);

			frame = (const char *)mSPS_PPS_IDR.GetBuffer();
			frameSize = mSPS_PPS_IDR.mBufferLen;

			bGotPPS = true;

		} else {
			mSyncBuffer.SetBuffer(sync_bytes, sizeof(sync_bytes));
			mSyncBuffer.AddBuffer((const unsigned char*)data + mNaluHeaderSize, size - mNaluHeaderSize);

			frame = (const char *)mSyncBuffer.GetBuffer();
			frameSize = mSyncBuffer.mBufferLen;

//			FileLog("rtmpdump",
//					"VideoDecoderH264::DecodeVideoFrame( "
//					"[Got Frame], "
//					"this : %p, "
//					"frameSize : %d "
//					")",
//					this,
//					frameSize
//					);
		}

		packet.data = (uint8_t*)frame;
		packet.size = frameSize;

//		FileLog("rtmpdump",
//				"VideoDecoderH264::DecodeVideoFrame( "
//				"[Decode Frame], "
//				"this : %p "
//				")",
//				this
//				);

		AVFrame* pictureFrame = av_frame_alloc();
		int useLen = avcodec_decode_video2(mContext, pictureFrame, &mGotPicture, &packet);
		if (mGotPicture) {
			int frameOffset = 0;

			AVFrame *rgbFrame = av_frame_alloc();
			AVPixelFormat decoderFormat = (AVPixelFormat)mDecoderFormat;

			int numBytes = avpicture_get_size(decoderFormat, mContext->width, mContext->height);
			uint8_t* buffer = (uint8_t *)av_malloc(numBytes);
			avpicture_fill((AVPicture *)rgbFrame, (uint8_t *)buffer, decoderFormat,
					mContext->width, mContext->height);
			struct SwsContext *img_convert_ctx = sws_getContext(mContext->width, mContext->height, mContext->pix_fmt,
					mContext->width, mContext->height, decoderFormat, SWS_BICUBIC, NULL, NULL, NULL);

			sws_scale(img_convert_ctx,
					(const uint8_t* const *)pictureFrame->data,
					pictureFrame->linesize, 0, mContext->height, rgbFrame->data,
					rgbFrame->linesize);

//			FileLog("rtmpdump",
//					"VideoDecoderH264::DecodeVideoFrame( "
//					"[Got Picture], "
//					"this : %p, "
//					"bufferFrame : %p, "
//					"mContext : %p, "
//					"width : %d, "
//					"height : %d, "
//					"pix_fmt : %d, "
//					"decoderFormat : %d, "
//					"numBytes : %d "
//					")",
//					this,
//					bufferFrame,
//					mContext,
//					mContext->width,
//					mContext->height,
//					mContext->pix_fmt,
//					decoderFormat,
//					numBytes
//					);

			// 转换格式
			if (decoderFormat == AV_PIX_FMT_YUV420P)
			{
				// YUV
				// copy Y Data
                int rgbYLen = mContext->width * mContext->height;
                bufferFrame->SetBuffer(rgbFrame->data[0], rgbYLen);

                // copy U Data
                int rgbULen = mContext->width * mContext->height * 1 / 4;
                bufferFrame->AddBuffer(rgbFrame->data[1], rgbULen);

                // copy V Data
                int rgbVLen = mContext->width * mContext->height * 1 / 4;
                bufferFrame->AddBuffer(rgbFrame->data[2], rgbVLen);
			}
			else {
				// RGB
				bufferFrame->SetBuffer(rgbFrame->data[0], numBytes);
			}

			bufferFrame->mWidth = mContext->width;
			bufferFrame->mHeight = mContext->height;

			bFlag = true;

			av_free(buffer);
			av_free(rgbFrame);
			sws_freeContext(img_convert_ctx);
		}

		av_free(pictureFrame);

		if( bGotPPS ) {
			mSPS_PPS_IDR.ResetFrame();
		}
    }

	return bFlag;
}

bool VideoDecoderH264::SetDecoderVideoFormat(VIDEO_FORMATE_TYPE type) {
    bool result = false;
    switch (type) {
        case VIDEO_FORMATE_RGB565: {
            mDecoderFormat = AV_PIX_FMT_RGB565;
            result = true;
        }break;
        case VIDEO_FORMATE_RGB24: {
            mDecoderFormat = AV_PIX_FMT_RGB24;
            result = true;
        }break;
        case VIDEO_FORMATE_YUV420P: {
            mDecoderFormat = AV_PIX_FMT_YUV420P;
            result = true;
        }break;
        default:
            break;
    }
    return result;
}
