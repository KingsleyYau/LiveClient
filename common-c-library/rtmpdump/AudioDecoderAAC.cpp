/*
 * AudioDecoderAAC.cpp
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#include "AudioDecoderAAC.h"

#include <common/KLog.h>

extern "C" {
#include "libavformat/avformat.h"
#include "libswresample/swresample.h"
#include "libavcodec/avcodec.h"
}

AudioDecoderAAC::AudioDecoderAAC() {
	// TODO Auto-generated constructor stub
	mCodec = NULL;
	mContext = NULL;
	mDecodeFrame = NULL;

	mFilePath = "";//"/sdcard/livestream/play.pcm";
}

AudioDecoderAAC::~AudioDecoderAAC() {
	// TODO Auto-generated destructor stub
	Destroy();
}

bool AudioDecoderAAC::Create() {
	bool bFlag = false;
	int ret = 0;

    avcodec_register_all();
    av_log_set_level(AV_LOG_ERROR);

	mCodec = avcodec_find_decoder(AV_CODEC_ID_AAC);
	if ( mCodec ) {
		bFlag = true;

	} else {
		FileLog("rtmpdump",
				"AudioDecoderAAC::Create( "
				"[Codec not found], "
				"this : %p "
				")",
				this
				);
	}

	if( bFlag ) {
		bFlag = false;

		mContext = avcodec_alloc_context3(mCodec);

	    ret = avcodec_open2(mContext, mCodec, NULL);
		if ( ret == 0 ) {
	    	FileLog("rtmpdump",
	    			"AudioDecoderAAC::Create( "
	    			"[Codec Found], "
	    			"this : %p, "
	    			"sample_fmt : %d, "
	    			"sample_rate : %d, "
	    			"channel_layout : %d, "
	    			"channels : %d, "
	    			"bit_rate : %d, "
	    			"frame_size : %d "
	    			")",
					this,
					mContext->sample_fmt,
					mContext->sample_rate,
					mContext->channel_layout,
					mContext->channels,
					mContext->bit_rate,
					mContext->frame_size
					);

			bFlag = true;

		} else {
			FileLog("rtmpdump",
					"AudioDecoderAAC::Create( "
					"[Codec could not open], "
					"this : %p, "
					"ret : %d "
					")",
					this,
					ret
					);
		}
	}

	if( bFlag ) {
		mDecodeFrame = av_frame_alloc();

		FileLog("rtmpdump",
				"AudioDecoderAAC::Create( "
				"[Success], "
				"this : %p "
				")",
				this
				);
	} else {
		FileLog("rtmpdump",
				"AudioDecoderAAC::Create( "
				"[Fail], "
				"this : %p "
				")",
				this
				);
	}

	return bFlag;
}

void AudioDecoderAAC::Destroy() {
	if( mDecodeFrame ) {
		av_frame_free(&mDecodeFrame);
		mDecodeFrame = NULL;
	}

	if( mContext ) {
		avcodec_close(mContext);
		mContext = NULL;
	}

	mCodec = NULL;
}

EncodeDecodeBuffer* AudioDecoderAAC::GetBuffer() {
	EncodeDecodeBuffer* decoderBuffer = NULL;
	mFinishBufferList.lock();
	if( !mFinishBufferList.empty() ) {
		decoderBuffer = (EncodeDecodeBuffer *)mFinishBufferList.front();
		mFinishBufferList.pop_front();
	}
	mFinishBufferList.unlock();
	return decoderBuffer;
}

void AudioDecoderAAC::ReleaseBuffer(EncodeDecodeBuffer* decoderBuffer) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(decoderBuffer);
	mFreeBufferList.unlock();
}

void AudioDecoderAAC::CreateAudioDecoder(
		AudioFrameFormat format,
		AudioFrameSoundRate sound_rate,
		AudioFrameSoundSize sound_size,
		AudioFrameSoundType sound_type
		) {

}

void AudioDecoderAAC::DecodeAudioFrame(
		AudioFrameFormat format,
		AudioFrameSoundRate sound_rate,
		AudioFrameSoundSize sound_size,
		AudioFrameSoundType sound_type,
		const char* data,
		int size,
		u_int32_t timestamp
		) {
	mFreeBufferList.lock();
	EncodeDecodeBuffer* encodeDecodeBuffer = NULL;
	if( !mFreeBufferList.empty() ) {
		encodeDecodeBuffer = (EncodeDecodeBuffer *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		encodeDecodeBuffer = new EncodeDecodeBuffer();
	}
	mFreeBufferList.unlock();

	encodeDecodeBuffer->ResetFrame();

	bool bFlag = false;
	bFlag = DecodeAudioFrame(data, size, encodeDecodeBuffer);
	if( bFlag ) {
		mFinishBufferList.lock();
		mFinishBufferList.push_back(encodeDecodeBuffer);
		mFinishBufferList.unlock();

	} else {
		mFreeBufferList.lock();
		mFreeBufferList.push_back(encodeDecodeBuffer);
		mFreeBufferList.unlock();
	}
}

bool AudioDecoderAAC::DecodeAudioFrame(const char* data, int size, EncodeDecodeBuffer* bufferFrame) {
	bool bFlag = false;

    if ( NULL != data &&
    		size > 0 &&
			NULL != bufferFrame &&
			NULL != mContext ) {

		AVPacket packet = {0};
		av_init_packet(&packet);

		int bGotFrame = 0;
	    const char *frame = data;
	    int frameSize = size;

	    packet.data = (uint8_t*)frame;
	    packet.size = frameSize;

	    int useLen = avcodec_decode_audio4(mContext, mDecodeFrame, &bGotFrame, &packet);

//		FileLog("rtmpdump",
//				"AudioDecoderAAC::DecodeAudioFrame( "
//				"this : %p, "
//				"size : %d, "
//				"useLen : %d "
//				")",
//				this,
//				size,
//				useLen
//				);

	    if( bGotFrame ) {
			// 解码成功后格式为 AV_SAMPLE_FMT_FLTP
			int bufferSize = av_samples_get_buffer_size(
					NULL,
					mContext->channels,
					mDecodeFrame->nb_samples,
					mContext->sample_fmt,
					1
					);

//			FileLog("rtmpdump",
//					"AudioDecoderAAC::DecodeAudioFrame( "
//					"[Got Frame], "
//					"this : %p, "
//					"useLen : %d, "
//					"bufferSize : %d, "
//					"sample_fmt : %d, "
//					"sample_rate : %d, "
//					"channels : %d, "
//					"nb_samples : %d "
//					")",
//					this,
//					useLen,
//					bufferSize,
//					mContext->sample_fmt,
//					mDecodeFrame->sample_rate,
//					mDecodeFrame->channels,
//					mDecodeFrame->nb_samples
//					);

			bufferFrame->SetBuffer(mDecodeFrame->data[0], bufferSize);

    		// 录制文件
    		if( mFilePath.length() > 0 ) {
    			FILE* file = fopen(mFilePath.c_str(), "a+b");
    		    if( file != NULL ) {
    		    	int iLen = -1;
    		    	fseek(file, 0L, SEEK_END);
    				iLen = fwrite(mDecodeFrame->data[0], 1, bufferSize, file);
    		    	fclose(file);
    		    }
    		}

			bFlag = true;
	    }
    }

    return bFlag;
}
