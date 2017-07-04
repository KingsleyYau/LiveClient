/*
 * AudioDecoderAAC.cpp
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#include "AudioDecoderAAC.h"

#include <common/KLog.h>

#include <rtmpdump/RtmpPlayer.h>

extern "C" {
#include "libavformat/avformat.h"
#include "libswresample/swresample.h"
#include "libavcodec/avcodec.h"
}

namespace coollive {
AudioDecoderAAC::AudioDecoderAAC() {
	// TODO Auto-generated constructor stub
	mCodec = NULL;
	mContext = NULL;
	mDecodeFrame = NULL;

	mFilePath = "";//"/sdcard/livestream/play.pcm";
    
    mpCallback = NULL;
}

AudioDecoderAAC::~AudioDecoderAAC() {
	// TODO Auto-generated destructor stub
	DestroyContext();
}

bool AudioDecoderAAC::Create(AudioDecoderCallback* callback) {
	FileLog("rtmpdump", "AudioDecoderAAC::Create( this : %p )", this);
    
    mpCallback = callback;
    
    return CreateContext();
}

void AudioDecoderAAC::Destroy() {
}
    
bool AudioDecoderAAC::CreateContext() {
    bool bFlag = false;
    int ret = 0;

    avcodec_register_all();
    av_log_set_level(AV_LOG_ERROR);
    
    mCodec = avcodec_find_decoder(AV_CODEC_ID_AAC);
    if ( mCodec ) {
        bFlag = true;
        
    } else {
        FileLog("rtmpdump",
                "AudioDecoderAAC::CreateContext( "
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
                    "AudioDecoderAAC::CreateContext( "
                    "[Codec opened], "
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
                    "AudioDecoderAAC::CreateContext( "
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
                "AudioDecoderAAC::CreateContext( "
                "[Success], "
                "this : %p "
                ")",
                this
                );
    } else {
        FileLog("rtmpdump",
                "AudioDecoderAAC::CreateContext( "
                "[Fail], "
                "this : %p "
                ")",
                this
                );
    }
    
    return bFlag;
}
    
void AudioDecoderAAC::DestroyContext() {
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
    
void AudioDecoderAAC::ReleaseAudioFrame(void* frame) {
    AudioFrame* audioFrame = (AudioFrame *)frame;
    ReleaseBuffer(audioFrame);
}

void AudioDecoderAAC::ReleaseBuffer(AudioFrame* audioFrame) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(audioFrame);
	mFreeBufferList.unlock();
}

void AudioDecoderAAC::DecodeAudioFormat(
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
	AudioFrame* audioFrame = NULL;
	if( !mFreeBufferList.empty() ) {
		audioFrame = (AudioFrame *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		audioFrame = new AudioFrame();
	}
	mFreeBufferList.unlock();

    // 更新数据格式
	audioFrame->ResetFrame();
    audioFrame->mTimestamp = timestamp;
    audioFrame->mFormat = format;
    audioFrame->mSoundRate = sound_rate;
    audioFrame->mSoundSize = sound_size;
    audioFrame->mSoundType = sound_type;
    
	bool bFlag = false;
	bFlag = DecodeAudioFrame(data, size, audioFrame);
	if( bFlag ) {
        if( mpCallback ) {
            mpCallback->OnDecodeAudioFrame(this, audioFrame, audioFrame->mTimestamp);
        }

	} else {
		mFreeBufferList.lock();
		mFreeBufferList.push_back(audioFrame);
		mFreeBufferList.unlock();
	}
}

bool AudioDecoderAAC::DecodeAudioFrame(const char* data, int size, AudioFrame* audioFrame) {
	bool bFlag = false;

    if ( NULL != data &&
    		size > 0 &&
			NULL != audioFrame &&
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

        if( useLen >=0 ) {
            if( bGotFrame ) {
                // 解码成功后格式为 AV_SAMPLE_FMT_S16
                int bufferSize = av_samples_get_buffer_size(
                                                            NULL,
                                                            mContext->channels,
                                                            mDecodeFrame->nb_samples,
                                                            mContext->sample_fmt,
                                                            1
                                                            );
                
//                FileLog("rtmpdump",
//                        "AudioDecoderAAC::DecodeAudioFrame( "
//                        "[Got Frame], "
//                        "this : %p, "
//                        "useLen : %d, "
//                        "bufferSize : %d, "
//                        "sample_fmt : %d, "
//                        "sample_rate : %d, "
//                        "channels : %d, "
//                        "nb_samples : %d "
//                        ")",
//                        this,
//                        useLen,
//                        bufferSize,
//                        mContext->sample_fmt,
//                        mDecodeFrame->sample_rate,
//                        mDecodeFrame->channels,
//                        mDecodeFrame->nb_samples
//                        );
                
                audioFrame->SetBuffer(mDecodeFrame->data[0], bufferSize);
                
//                // 录制文件
//                if( mFilePath.length() > 0 ) {
//                    FILE* file = fopen(mFilePath.c_str(), "a+b");
//                    if( file != NULL ) {
//                        int iLen = -1;
//                        fseek(file, 0L, SEEK_END);
//                        iLen = fwrite(mDecodeFrame->data[0], (size_t)1, (size_t)bufferSize, file);
//                        fclose(file);
//                    }
//                }
                
                // 用解码器的参数覆盖协议解析的参数
                audioFrame->mSoundRate = AFSR_KHZ_44;
                audioFrame->mSoundType = (mDecodeFrame->channels==2)?AFST_STEREO:AFST_MONO;
                audioFrame->mSoundSize = AFSS_BIT_16;
                
                bFlag = true;
            }
            
        } else {
            char errMsg[1024];
            av_strerror(useLen, errMsg, sizeof(errMsg));
            FileLog("rtmpdump",
                    "AudioDecoderAAC::DecodeAudioFrame( "
                    "[Fail, %s], "
                    "this : %p, "
                    "useLen : %d, "
                    "sample_fmt : %d, "
                    "sample_rate : %d, "
                    "channels : %d, "
                    "nb_samples : %d "
                    ")",
                    errMsg,
                    this,
                    useLen,
                    mContext->sample_fmt,
                    mDecodeFrame->sample_rate,
                    mDecodeFrame->channels,
                    mDecodeFrame->nb_samples
                    );

        }
    }

    return bFlag;
}
}
