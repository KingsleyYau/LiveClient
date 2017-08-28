/*
 * AudioEncoderAAC.cpp
 *
 *  Created on: 2017年8月9日
 *      Author: max
 */

#include "AudioEncoderAAC.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

extern "C" {
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/opt.h>
#include <libavutil/channel_layout.h>
#include <libavutil/samplefmt.h>
#include <libswresample/swresample.h>
}

namespace coollive {
// 编码线程
class EncodeAudioRunnable : public KRunnable {
public:
    EncodeAudioRunnable(AudioEncoderAAC *container) {
        mContainer = container;
    }
    virtual ~EncodeAudioRunnable() {
        mContainer = NULL;
    }
protected:
    void onRun() {
        mContainer->EncodeAudioHandle();
    }

private:
    AudioEncoderAAC *mContainer;
};

AudioEncoderAAC::AudioEncoderAAC()
:mRuningMutex(KMutex::MutexType_Recursive)
    {
	// TODO Auto-generated constructor stub
	FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioEncoderAAC::AudioEncoderAAC( this : %p )", this);

    avcodec_register_all();
    av_log_set_level(AV_LOG_ERROR);

    // 参数
    mSampleRate = 0;
    mChannelsPerFrame = 0;
    mBitPerSample = 0;
    mSamplesPerChannel = 1024;

    mpCallback = NULL;

	mCodec = NULL;
	mContext = NULL;

	mbRunning = false;
	mPts = 0;

    mpEncodeAudioRunnable = new EncodeAudioRunnable(this);
}

AudioEncoderAAC::~AudioEncoderAAC() {
	// TODO Auto-generated destructor stub
	FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioEncoderAAC::~AudioEncoderAAC( this : %p )", this);

    Stop();

    if( mpEncodeAudioRunnable ) {
        delete mpEncodeAudioRunnable;
        mpEncodeAudioRunnable = NULL;
    }

    // 销毁旧的编码器
    DestroyContext();
}

bool AudioEncoderAAC::Create(int sampleRate, int channelsPerFrame, int bitPerSample) {
	bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Create( "
                 "this : %p, "
                 "sampleRate : %d, "
                 "channelsPerFrame : %d, "
                 "bitPerSample : %d "
                 ")",
                 this,
				 sampleRate,
				 channelsPerFrame,
				 bitPerSample
                 );

	mSampleRate = sampleRate;
	mChannelsPerFrame = channelsPerFrame;
	mBitPerSample = bitPerSample;

    // 创建编码器
    bFlag = CreateContext();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Create( "
                 "[%s], "
                 "this : %p "
                 ")",
				 bFlag?"Success":"Fail",
                 this
                 );

    return bFlag;
}

void AudioEncoderAAC::SetCallback(AudioEncoderCallback* callback) {
	mpCallback = callback;
}

bool AudioEncoderAAC::Reset() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Reset( "
                 "this : %p "
                 ")",
                 this
                 );

	bool bFlag = Start();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Reset( "
                 "[%s], "
                 "this : %p "
                 ")",
				 bFlag?"Succcess":"Fail",
                 this
                 );

	return bFlag;
}

void AudioEncoderAAC::Pause() {
	FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioEncoderAAC::Pause( this : %p )", this);

	Stop();
    
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioEncoderAAC::Pause( [Success], this : %p )", this);
}

void AudioEncoderAAC::EncodeAudioFrame(void* data, int size, void* frame) {
    mRuningMutex.lock();
    if( mbRunning ) {
    	mFreeBufferList.lock();
    	AudioFrame* srcFrame = NULL;
    	if( !mFreeBufferList.empty() ) {
    		srcFrame = (AudioFrame *)mFreeBufferList.front();
    		mFreeBufferList.pop_front();

    	} else {
    		srcFrame = new AudioFrame();
    	}
    	mFreeBufferList.unlock();

    	srcFrame->SetBuffer((unsigned char *)data, size);

    	AudioFrameSoundRate soundRate = (mSampleRate == 44100)?AFSR_KHZ_44:AFSR_UNKNOWN;
    	AudioFrameSoundSize soundSize = (mBitPerSample == 16)?AFSS_BIT_16:AFSS_BIT_8;
    	AudioFrameSoundType soundType = (mChannelsPerFrame == 2)?AFST_STEREO:AFST_MONO;
    	srcFrame->InitFrame(AFF_AAC, soundRate, soundSize, soundType);

    	FileLevelLog("rtmpdump",
    				 KLog::LOG_MSG,
    				 "AudioEncoderAAC::EncodeAudioFrame( "
    				 "this : %p, "
    				 "srcFrame : %p, "
                     "size : %d, "
    				 "frame : %p "
    				 ")",
    				 this,
    				 srcFrame,
                     size,
    				 frame
    				 );

    	// 放进编码队列
    	mEncodeBufferList.lock();
    	mEncodeBufferList.push_back(srcFrame);
    	mEncodeBufferList.unlock();
    }
    mRuningMutex.unlock();
}

bool AudioEncoderAAC::Start() {
	bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Start( "
                 "this : %p "
                 ")",
                 this
                 );

    mRuningMutex.lock();
    if( mbRunning ) {
        Stop();
    }

	mbRunning = true;
	mPts = 0;

	AudioFrame* frame = NULL;
	mFreeBufferList.lock();
	for(int i = 0; i < DEFAULT_AUDIO_BUFFER_COUNT; i++) {
		frame = new AudioFrame();
		frame->ResetFrame();
		mFreeBufferList.push_back(frame);
	}
	mFreeBufferList.unlock();

	// 开启编码线程
	mEncodeAudioThread.Start(mpEncodeAudioRunnable);

	bFlag = true;

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Start( "
                 "[%s], "
                 "this : %p "
                 ")",
				 bFlag?"Success":"Fail",
                 this
                 );
    
    return bFlag;
}

void AudioEncoderAAC::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Stop( "
                 "this : %p "
                 ")",
                 this
                 );

    mRuningMutex.lock();
    if( mbRunning ) {
        mbRunning = false;

        // 停止编码线程
        mEncodeAudioThread.Stop();

        AudioFrame* frame = NULL;
        // 释放未编码Buffer
        mEncodeBufferList.lock();
        while( !mEncodeBufferList.empty() ) {
            frame = (AudioFrame* )mEncodeBufferList.front();
            mEncodeBufferList.pop_front();
            if( frame != NULL ) {
                ReleaseAudioFrame(frame);
            } else {
                break;
            }
        }
        mEncodeBufferList.unlock();

        // 释放空闲Buffer
        mFreeBufferList.lock();
        while( !mFreeBufferList.empty() ) {
            frame = (AudioFrame* )mFreeBufferList.front();
            mFreeBufferList.pop_front();
            if( frame != NULL ) {
                delete frame;
            } else {
                break;
            }
        }
        mFreeBufferList.unlock();
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioEncoderAAC::Stop( "
                 "[Success], "
                 "this : %p "
                 ")",
                 this
                 );
}

bool AudioEncoderAAC::EncodeAudioFrame(AudioFrame* srcFrame, AudioFrame* dstFrame) {
    bool bFlag = false;
    int ret = 0;
    long long curTime = getCurrentTime();

    // 填充帧数据
    AVFrame* pcmFrame = srcFrame->mpAVFrame;
    pcmFrame->nb_samples = mSamplesPerChannel;
    pcmFrame->format = mContext->sample_fmt;
    pcmFrame->channels = mContext->channels;
    pcmFrame->channel_layout = mContext->channel_layout;
    ret = avcodec_fill_audio_frame(
    		pcmFrame,
			mContext->channels,
			mContext->sample_fmt,
			(const uint8_t*)srcFrame->GetBuffer(),
			srcFrame->mBufferLen,
			0);

    // 复制帧参数
    *dstFrame = *srcFrame;

    // 编码帧
    AVPacket pkt = {0};
    av_init_packet(&pkt);
    pkt.data = NULL;
    pkt.size = 0;

    int bGotFrame = 0;
    ret = avcodec_encode_audio2(mContext, &pkt, pcmFrame, &bGotFrame);

    // 计算处理时间
    long long now = getCurrentTime();
    long long handleTime = now - curTime;
    FileLevelLog(
                 "rtmpdump",
                 KLog::LOG_STAT,
                 "AudioEncoderAAC::EncodeAudioFrame( "
                 "[Encode Frame], "
                 "this : %p, "
                 "ret : %d, "
                 "bGotFrame : %d, "
                 "srcFrame : %p, "
                 "dstFrame : %p, "
				 "timestamp : %u, "
                 "handleTime : %lld "
                 ")",
                 this,
				 ret,
                 bGotFrame,
                 srcFrame,
                 dstFrame,
				 dstFrame->mTimestamp,
                 handleTime
                 );

    if ( ret >= 0 && bGotFrame ) {
        // 填充数据, (已经包含ADTS头部, 不需要Mux）
        dstFrame->SetBuffer(pkt.data, pkt.size);

        // 重新计算timestamp
        pcmFrame->pts = mPts;
        dstFrame->mTimestamp = (unsigned int)(1000.0 * pcmFrame->pts / mContext->time_base.den);
        mPts += pcmFrame->nb_samples * pcmFrame->channels;
        
        FileLevelLog(
                     "rtmpdump",
                     KLog::LOG_STAT,
                     "AudioEncoderAAC::EncodeAudioFrame( "
                     "[Got Audio Frame], "
                     "this : %p, "
                     "srcFrame : %p, "
                     "dstFrame : %p, "
                     "timestamp : %u, "
                     "size : %d "
                     ")",
                     this,
                     srcFrame,
                     dstFrame,
                     dstFrame->mTimestamp,
                     pkt.size
                     );

        av_free_packet(&pkt);
        
        bFlag = true;
    }

    return bFlag;
}

bool AudioEncoderAAC::CreateContext() {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "AudioEncoderAAC::CreateContext( this : %p )", this);

    bool bFlag = true;
    char errbuf[1024];

    mCodec = avcodec_find_encoder(AV_CODEC_ID_AAC);
    if ( !mCodec ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_ERR_SYS,
                     "AudioEncoderAAC::CreateContext( "
                    "[Codec not found], "
                    "this : %p "
                    ")",
                    this
                    );

        bFlag = false;
    }

    if( bFlag ) {
        mContext = avcodec_alloc_context3(mCodec);

//        // 类型(精度/多声道采样顺序)
//        AVSampleFormat src_sample_fmt = AV_SAMPLE_FMT_NONE, dst_sample_fmt = AV_SAMPLE_FMT_FLTP;

        // 采样格式
        mContext->sample_fmt = AV_SAMPLE_FMT_S16;
        // 采样率
        mContext->sample_rate = mSampleRate;
        // 声道
        mContext->channels = mChannelsPerFrame;
        mContext->channel_layout = av_get_default_channel_layout(mContext->channels);
        // 码率
        mContext->bit_rate = 64000;
        // AAC授权
        mContext->strict_std_compliance = FF_COMPLIANCE_EXPERIMENTAL;

        AVDictionary* options = NULL;
        int ret = avcodec_open2(mContext, mCodec, &options);
        if ( ret == 0 ) {
            FileLevelLog(
            		"rtmpdump",
					KLog::LOG_MSG,
                    "AudioEncoderAAC::CreateContext( "
                    "[Codec opened], "
                    "this : %p, "
                    "sample_fmt : %d, "
                    "sample_rate : %d, "
                    "channels : %d, "
					"bit_rate : %d, "
                    "frame_size : %d, "
                    "time_base.num : %d, "
                    "time_base.den : %d, "
                    "profile : %d "
                    ")",
                    this,
                    mContext->sample_fmt,
                    mContext->sample_rate,
                    mContext->channels,
					mContext->bit_rate,
                    mContext->frame_size,
					mContext->time_base.num,
					mContext->time_base.den,
					mContext->profile
                    );
        } else {
        	av_strerror(ret, errbuf, sizeof(errbuf));

            FileLevelLog("rtmpdump",
                        KLog::LOG_ERR_SYS,
                        "AudioEncoderAAC::CreateContext( "
                        "[Could not open codec], "
                        "this : %p, "
                        "ret : %d, "
                        "errbuf : %s "
                        ")",
                        this,
                        ret,
						errbuf
                        );
            mContext = NULL;
            bFlag = false;
        }
    }

    if( !bFlag ) {
        DestroyContext();

        FileLevelLog("rtmpdump",
                     KLog::LOG_ERR_SYS,
                     "AudioEncoderAAC::CreateContext( "
                     "[Fail], "
                     "this : %p "
                     ")",
                     this
                     );
    }

    return bFlag;
}


void AudioEncoderAAC::DestroyContext() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioEncoderAAC::DestroyContext( "
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

void AudioEncoderAAC::ReleaseAudioFrame(AudioFrame* audioFrame) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "AudioEncoderAAC::ReleaseAudioFrame( "
                 "this : %p, "
                 "audioFrame : %p, "
                 "mFreeBufferList.size() : %d "
                 ")",
                 this,
				 audioFrame,
                 mFreeBufferList.size()
                 );

    mFreeBufferList.lock();
    mFreeBufferList.push_back(audioFrame);
    mFreeBufferList.unlock();
}

void AudioEncoderAAC::EncodeAudioHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "AudioEncoderAAC::EncodeAudioHandle( "
                "[Start], "
                "this : %p "
                ")",
                this
                );

    AudioFrame* srcFrame = NULL;
    AudioFrame tmpFrame;
    AudioFrame* dstFrame = &tmpFrame;

    while ( mbRunning ) {
        // 获取编码帧
        srcFrame = NULL;

        mEncodeBufferList.lock();
        if( !mEncodeBufferList.empty() ) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "AudioEncoderAAC::EncodeAudioHandle( "
                         "this : %p, "
                         "mEncodeBufferList.size() : %d "
                         ")",
                         this,
                         mEncodeBufferList.size()
                         );

            srcFrame = (AudioFrame* )mEncodeBufferList.front();
            mEncodeBufferList.pop_front();
        }
        mEncodeBufferList.unlock();

        if( srcFrame ) {
            // 编码帧
            if( EncodeAudioFrame(srcFrame, dstFrame) ) {
            	if( mpCallback ) {
            		mpCallback->OnEncodeAudioFrame(
                                                   this,
                                                   dstFrame->mSoundFormat,
                                                   dstFrame->mSoundRate,
                                                   dstFrame->mSoundSize,
                                                   dstFrame->mSoundType,
                                                   (char *)dstFrame->GetBuffer(),
                                                   dstFrame->mBufferLen,
                                                   dstFrame->mTimestamp
                                                   );
            	}
            }

            // 释放待编码帧
            ReleaseAudioFrame(srcFrame);
        }

        Sleep(1);
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "AudioEncoderAAC::EncodeAudioHandle( "
                "[Exit], "
                "this : %p "
                ")",
                this
                );
}

} /* namespace coollive */
