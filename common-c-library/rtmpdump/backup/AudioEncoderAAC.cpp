/*
 * AudioEncoderAAC.cpp
 *
 *  Created on: 2017年5月9日
 *      Author: max
 */

#include "AudioEncoderAAC.h"

#include <common/KLog.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavutil/opt.h>
#include <libavutil/channel_layout.h>
#include <libavutil/samplefmt.h>
#include <libswresample/swresample.h>
}

#define SAMPLE_RATE 44100
#define CHANNELS 1
#define BIT_PER_SAMPLE 16

static void my_log_callback(void *ptr, int level, const char *fmt, va_list vargs) {
//	FileLog("rtmpdump",
//			fmt,
//			vargs
//			);
}

AudioEncoderAAC::AudioEncoderAAC() {
	// TODO Auto-generated constructor stub
	mCodec = NULL;
	mContext = NULL;
	mSwrCtx = NULL;

	mSrcData = NULL;
	mDstData = NULL;

}

AudioEncoderAAC::~AudioEncoderAAC() {
	// TODO Auto-generated destructor stub
	Destroy();
}

bool AudioEncoderAAC::Create(int sampleRate, int channelsPerFrame, int bitPerSample) {
	FileLog("rtmpdump", "AudioEncoderAAC::Create( "
			"this : %p, "
			"avcodec_version : %d, "
			"sampleRate : %d, "
			"channelsPerFrame : %d, "
			"bitPerSample : %d "
			")",
			this,
			avcodec_version(),
			sampleRate,
			channelsPerFrame,
			bitPerSample
			);

    bool result = true;
    int ret = 0;

	avcodec_register_all();
    av_log_set_level(AV_LOG_ERROR);
    av_log_set_callback(my_log_callback);

    // 类型(精度/多声道采样顺序)
    AVSampleFormat src_sample_fmt = AV_SAMPLE_FMT_NONE, dst_sample_fmt = AV_SAMPLE_FMT_FLTP;
    // 单声道的帧大小
    int src_frame_size = 0;
    // 声道
    int src_nb_channels = channelsPerFrame, dst_nb_channels = CHANNELS;
    // 采样率
    int src_rate = sampleRate, dst_rate = SAMPLE_RATE;

    // 查找编码器
    mCodec = avcodec_find_encoder(AV_CODEC_ID_AAC);
    if ( !mCodec ) {
    	FileLog("rtmpdump",
    			"AudioEncoderAAC::Create( "
    			"[Codec Not Found], "
    			"this : %p "
    			")",
				this
				);
    	result = false;
    }

    // 创建编码器
    if( result ) {
        mContext = avcodec_alloc_context3(mCodec);

        // 编码器输入源
        // 类型
        mContext->codec_type = AVMEDIA_TYPE_AUDIO;
        // 配置PCM格式
        mContext->sample_fmt = dst_sample_fmt;
        // 采样率
        mContext->sample_rate = dst_rate;
        // 声道数
        mContext->channels = dst_nb_channels;
        mContext->channel_layout = av_get_default_channel_layout(dst_nb_channels);
//        // 码率
//        mContext->bit_rate = 64000;
        // AAC授权
        mContext->strict_std_compliance = FF_COMPLIANCE_EXPERIMENTAL;
    }

    // 打开编码器
    if( result ) {
    	ret = avcodec_open2(mContext, mCodec, NULL);

    	FileLog("rtmpdump",
    			"AudioEncoderAAC::Create( "
    			"[Codec Open], "
    			"this : %p, "
    			"name : %s, "
    			"sample_fmt : %d, "
    			"sample_rate : %d, "
    			"channels : %d, "
    			"channel_layout : %llu, "
    			"bit_rate : %d, "
    			"frame_size : %d "
    			")",
				this,
				mCodec->name,
				mContext->sample_fmt,
				mContext->sample_rate,
				mContext->channels,
				mContext->channel_layout,
				mContext->bit_rate,
				mContext->frame_size
				);

    	if( ret != 0 ) {
			FileLog("rtmpdump",
					"AudioEncoderAAC::Create( "
					"[Codec Could Not Open], "
					"this : %p, "
					"ret : %d "
					")",
					this,
					ret
					);
        	result = false;
        }
    }

    // 输入源重采样
    if ( result ) {
    	mSwrCtx = swr_alloc();

    	// 采集器输入源格式(精度/如果双声道还有顺序)
        if( (channelsPerFrame == 1) && (bitPerSample == 8) ) {
        	// 单声道/精度8bit
        	src_sample_fmt = AV_SAMPLE_FMT_U8;
        } else if( (channelsPerFrame == 1) && (bitPerSample == 16) ) {
        	// 单声道/精度16bit
        	src_sample_fmt = AV_SAMPLE_FMT_S16;
        }

        src_frame_size = av_get_bytes_per_sample(src_sample_fmt);

        av_opt_set_int(mSwrCtx, "in_channel_layout", mContext->channel_layout, 0);
        av_opt_set_int(mSwrCtx, "in_sample_rate", mContext->sample_rate, 0);
        av_opt_set_sample_fmt(mSwrCtx, "in_sample_fmt", src_sample_fmt, 0);

        av_opt_set_int(mSwrCtx, "out_channel_layout", mContext->channel_layout, 0);
        av_opt_set_int(mSwrCtx, "out_sample_rate", mContext->sample_rate, 0);
        av_opt_set_sample_fmt(mSwrCtx, "out_sample_fmt", mContext->sample_fmt, 0);

    	FileLog("rtmpdump",
    			"AudioEncoderAAC::Create( "
    			"[Resample], "
    			"this : %p, "
    			"src_sample_fmt : %d, "
    			"src_sample_rate : %d, "
    			"src_channels : %d, "
    			"src_frame_size : %d, "
    			"dst_sample_fmt : %d, "
    			"dst_frame_size : %d, "
    			"dst_channels : %d, "
    			"dst_frame_size : %d  "
    			")",
				this,
				src_sample_fmt,
				sampleRate,
				channelsPerFrame,
				src_frame_size,
				mContext->sample_fmt,
				mContext->sample_rate,
				mContext->channels,
				mContext->frame_size
				);

        ret = swr_init(mSwrCtx);
    	if( ret != 0 ) {
			FileLog("rtmpdump",
					"AudioEncoderAAC::Create( "
					"[Resample Init Fail], "
					"this : %p, "
					"ret : %d "
					")",
					this,
					ret
					);
        	result = false;
        }

    }

    if( result ) {
    	// 初始化重采样的Buffer
    	int src_linesize, dst_linesize;
    	int src_nb_samples = 1024;
//
//        ret = av_samples_alloc_array_and_samples(
//        		&mSrcData,
//				&src_linesize,
//				channelsPerFrame,
//				src_nb_samples,
//				src_sample_fmt,
//				0
//				);

//        result = (buffer_size > 0);
//        if( !result ) {
//        	FileLog("rtmpdump",
//        			"AudioEncoderAAC::Create( "
//        			"[Sample Buffer Size Not found], "
//        			"this : %p "
//        			")",
//    				this
//    				);
//        }
    }

	if( !result ) {
		Destroy();

    	FileLog("rtmpdump",
    			"AudioEncoderAAC::Create( "
    			"[Fail], "
    			"this : %p "
    			")",
				this
				);
	} else {
    	FileLog("rtmpdump",
    			"AudioEncoderAAC::Create( "
    			"[Success], "
    			"this : %p "
    			")",
				this
				);
	}

	return result;
}

void AudioEncoderAAC::Destroy() {
	if( mContext ) {
		avcodec_close(mContext);
		mContext = NULL;
	}

	mCodec = NULL;
}

EncodeDecodeBuffer* AudioEncoderAAC::GetBuffer() {
	EncodeDecodeBuffer* decoderBuffer = NULL;
	mFinishBufferList.lock();
	if( !mFinishBufferList.empty() ) {
		decoderBuffer = (EncodeDecodeBuffer *)mFinishBufferList.front();
		mFinishBufferList.pop_front();
	}
	mFinishBufferList.unlock();
	return decoderBuffer;
}

void AudioEncoderAAC::ReleaseBuffer(EncodeDecodeBuffer* decoderBuffer) {
	mFreeBufferList.lock();
	mFreeBufferList.push_back(decoderBuffer);
	mFreeBufferList.unlock();
}

void AudioEncoderAAC::EncodeAudioFrame(const char* data, int size, u_int32_t timestamp) {
	mFreeBufferList.lock();
	EncodeDecodeBuffer* decodeBuffer = NULL;
	if( !mFreeBufferList.empty() ) {
		decodeBuffer = (EncodeDecodeBuffer *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		decodeBuffer = new EncodeDecodeBuffer();
	}
	mFreeBufferList.unlock();

	decodeBuffer->ResetFrame();
	decodeBuffer->RenewBufferSize(size);

	bool bFlag = false;
	bFlag = EncodeAudioFrame(data, size, decodeBuffer);
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

bool AudioEncoderAAC::EncodeAudioFrame(const char* data, int size, EncodeDecodeBuffer* bufferFrame) {
	bool bFlag = false;

    if ( NULL != data &&
    		size > 0 &&
			NULL != bufferFrame &&
			NULL != mContext ) {
    	// 原始PCM数据
    	AVFrame *pFrame = av_frame_alloc();
        pFrame->nb_samples = mContext->frame_size;
        pFrame->format = mContext->sample_fmt;
        pFrame->channel_layout = mContext->channel_layout;

        // 填充
        avcodec_fill_audio_frame(
        		pFrame,
				mContext->channels,
				mContext->sample_fmt,
				(const uint8_t*)data,
				size,
				0
				);

		// 编码后数据
		AVPacket packet = {0};
		av_init_packet(&packet);

		packet.data = NULL;//(uint8_t*)bufferFrame->GetBuffer();
		packet.size = 0;//bufferFrame->mBufferLen;

		int gotFrame = 0;
		int ret = avcodec_encode_audio2(mContext, &packet, pFrame, &gotFrame);

		FileLog("rtmpdump",
				"AudioEncoderAAC::EncodeAudioFrame( "
				"[Encode Frame], "
				"this : %p, "
				"ret : %d, "
				"gotFrame : %d, "
				"size : %d "
				")",
				this,
				ret,
				gotFrame,
				size
				);

		if ( ret == 0 && gotFrame == 1 ) {
			// 编码得到一帧
			FileLog("rtmpdump",
					"AudioEncoderAAC::EncodeAudioFrame( "
					"[Got Frame], "
					"this : %p, "
					"packet.size : %d "
					")",
					this,
					packet.size
					);
			bFlag = true;

			bufferFrame->SetBuffer(packet.data, packet.size);
			av_free_packet(&packet);
		}

    	if( pFrame ) {
    		av_free(pFrame);
    	}
    }

    return bFlag;
}

bool AudioEncoderAAC::CheckBitPerSample(AVCodec *codec, int fmt) {
	AVSampleFormat sample_fmt = (AVSampleFormat)fmt;
	bool bFlag = false;
    const enum AVSampleFormat *p = codec->sample_fmts;
    while (*p != AV_SAMPLE_FMT_NONE) {
        if (*p == sample_fmt) {
        	// 可以接收的精度
        	FileLog("rtmpdump", "AudioEncoderAAC::CheckBitPerSample( "
        			"format : %s "
        			")",
					av_get_sample_fmt_name(*p)
        			);
        	bFlag = true;
        	break;
        }
        p++;
    }
    return bFlag;
}

int AudioEncoderAAC::SelectSampleRate(AVCodec *codec) {
    const int *p;
    int best_samplerate = 0;

    if (!codec->supported_samplerates) {
    	best_samplerate = 44100;
    } else {
        p = codec->supported_samplerates;
        while (*p) {
            best_samplerate = FFMAX(*p, best_samplerate);
            p++;
        }
    }

	FileLog("rtmpdump", "AudioEncoderAAC::SelectSampleRate( "
			"best_samplerate : %d "
			")",
			best_samplerate
			);

    return best_samplerate;
}

int AudioEncoderAAC::SelectChannelLayout(AVCodec *codec) {
    const uint64_t *p;
    uint64_t best_ch_layout = 0;
    int best_nb_channels   = 0;

    if (!codec->channel_layouts) {
    	best_nb_channels = AV_CH_LAYOUT_STEREO;
    } else {
        p = codec->channel_layouts;
        while (*p) {
            int nb_channels = av_get_channel_layout_nb_channels(*p);

            if (nb_channels > best_nb_channels) {
                best_ch_layout    = *p;
                best_nb_channels = nb_channels;
            }
            p++;
        }
    }

	FileLog("rtmpdump", "AudioEncoderAAC::SelectChannelLayout( "
			"best_ch_layout : %llu "
			")",
			best_ch_layout
			);

    return best_ch_layout;
}
