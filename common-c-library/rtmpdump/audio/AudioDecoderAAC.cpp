/*
 * AudioDecoderAAC.cpp
 *
 *  Created on: 2017年4月25日
 *      Author: max
 */

#include "AudioDecoderAAC.h"

#include <common/KLog.h>
#include <common/CommonFunc.h>

extern "C" {
#include <libavformat/avformat.h>
#include <libswresample/swresample.h>
#include <libavcodec/avcodec.h>
}

//static void ffmpeg_log_callbck(void *ptr, int level, const char *fmt, va_list va_list) {
//    FileLevelLog("rtmpdump", KLog::LOG_WARNING, fmt, va_list);
//};

namespace coollive {
// 解码线程
class DecodeAudioRunnable : public KRunnable {
  public:
    DecodeAudioRunnable(AudioDecoderAAC *container) {
        mContainer = container;
    }
    virtual ~DecodeAudioRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->DecodeAudioHandle();
    }

  private:
    AudioDecoderAAC *mContainer;
};

AudioDecoderAAC::AudioDecoderAAC()
    : mRuningMutex(KMutex::MutexType_Recursive) {
    // TODO Auto-generated constructor stub
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioDecoderAAC::AudioDecoderAAC( this : %p )", this);

    avcodec_register_all();
    //    av_log_set_level(AV_LOG_TRACE);
    //    av_log_set_callback(ffmpeg_log_callbck);

    mCodec = NULL;
    mContext = NULL;
    mpCallback = NULL;
    mbRunning = false;

    mpDecodeAudioRunnable = new DecodeAudioRunnable(this);
}

AudioDecoderAAC::~AudioDecoderAAC() {
    // TODO Auto-generated destructor stub
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioDecoderAAC::~AudioDecoderAAC( this : %p )", this);

    Stop();

    if (mpDecodeAudioRunnable) {
        delete mpDecodeAudioRunnable;
        mpDecodeAudioRunnable = NULL;
    }

    DestroyContext();
}

bool AudioDecoderAAC::Create(AudioDecoderCallback *callback) {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderAAC::Create( this : %p )", this);

    mpCallback = callback;

    bool bFlag = true;

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderAAC::Create( "
                                                "this : %p, "
                                                "[%s] "
                                                ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

bool AudioDecoderAAC::Reset() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderAAC::Reset( this : %p )", this);

    bool bFlag = Start();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioDecoderAAC::Reset( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void AudioDecoderAAC::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderAAC::Pause( this : %p )", this);

    Stop();

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioDecoderAAC::Pause( this : %p, [Success] )", this);
}

bool AudioDecoderAAC::Start() {
    bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::Start( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        Stop();
    }

    bFlag = CreateContext();
    if (bFlag) {
        mbRunning = true;
        
        AudioFrame *frame = NULL;
        mFreeBufferList.lock();
        mBufferListSize = 0;
        for (int i = 0; i < DEFAULT_AUDIO_BUFFER_COUNT; i++) {
            frame = new AudioFrame();
            frame->ResetFrame();
            mFreeBufferList.push_back(frame);
        }
        mFreeBufferList.unlock();

        // 开启解码线程
        mDecodeAudioThread.Start(mpDecodeAudioRunnable);
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::Start( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void AudioDecoderAAC::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::Stop( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        mbRunning = false;

        // 停止编码线程
        mDecodeAudioThread.Stop();

        // 清空队列
        ClearAudioFrame();

        DestroyContext();
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

bool AudioDecoderAAC::CreateContext() {
    bool bFlag = false;
    int ret = 0;

    //    mCodec = avcodec_find_decoder(AV_CODEC_ID_AAC);
    mCodec = avcodec_find_decoder_by_name("libfdk_aac");
    if (mCodec) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "AudioDecoderAAC::CreateContext( "
                     "this : %p, "
                     "[Codec Found], "
                     "%s "
                     ")",
                     this,
                     mCodec->name);
        bFlag = true;
    } else {
        FileLevelLog("rtmpdump",
                     KLog::LOG_ERR_SYS,
                     "AudioDecoderAAC::CreateContext( "
                     "this : %p, "
                     "[Codec Not Found] "
                     ")",
                     this);
    }

    if (bFlag) {
        bFlag = false;

        mContext = avcodec_alloc_context3(mCodec);

        ret = avcodec_open2(mContext, mCodec, NULL);
        if (ret == 0) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "AudioDecoderAAC::CreateContext( "
                         "this : %p, "
                         "[Codec opened], "
                         "sample_fmt : %d, "
                         "sample_rate : %d, "
                         "channel_layout : %d, "
                         "channels : %d, "
                         "bit_rate : %d, "
                         "frame_size : %d, "
                         "profile : %d "
                         ")",
                         this,
                         mContext->sample_fmt,
                         mContext->sample_rate,
                         mContext->channel_layout,
                         mContext->channels,
                         mContext->bit_rate,
                         mContext->frame_size,
                         mContext->profile);
            bFlag = true;
        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_ERR_SYS,
                         "AudioDecoderAAC::CreateContext( "
                         "this : %p, "
                         "[Codec could not open], "
                         "ret : %d "
                         ")",
                         this,
                         ret);
        }
    }

    if (bFlag) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "AudioDecoderAAC::CreateContext( "
                     "this : %p, "
                     "[Success] "
                     ")",
                     this);
    } else {
        FileLevelLog("rtmpdump",
                     KLog::LOG_ERR_SYS,
                     "AudioDecoderAAC::CreateContext( "
                     "this : %p, "
                     "[Fail] "
                     ")",
                     this);
    }

    return bFlag;
}

void AudioDecoderAAC::DestroyContext() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::DestroyContext( "
                 "this : %p "
                 ")",
                 this);

    if (mContext) {
        avcodec_close(mContext);
        avcodec_free_context(&mContext);
        mContext = NULL;
    }

    mCodec = NULL;
}

void AudioDecoderAAC::ReleaseAudioFrame(void *frame) {
    AudioFrame *audioFrame = (AudioFrame *)frame;

    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "AudioDecoderAAC::ReleaseAudioFrame( "
                 "this : %p, "
                 "audioFrame : %p, "
                 "ts : %lld "
                 ")",
                 this,
                 audioFrame,
                 audioFrame->mTS);

    mFreeBufferList.lock();
    if (mFreeBufferList.size() >= DEFAULT_AUDIO_BUFFER_MAX_COUNT) {
        delete audioFrame;
    } else {
        mFreeBufferList.push_back(audioFrame);
    }
    mBufferListSize--;
    mFreeBufferList.unlock();
}

void AudioDecoderAAC::ClearAudioFrame() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::ClearAudioFrame( "
                 "this : %p, "
                 "mDecodeBufferList.size() : %d, "
                 "mFreeBufferList.size() : %d "
                 ")",
                 this,
                 mDecodeBufferList.size(),
                 mFreeBufferList.size());

    AudioFrame *frame = NULL;
    // 释放未解码Buffer
    mDecodeBufferList.lock();
    while (!mDecodeBufferList.empty()) {
        frame = (AudioFrame *)mDecodeBufferList.front();
        mDecodeBufferList.pop_front();
        if (frame != NULL) {
            mBufferListSize--;
            delete frame;
        } else {
            break;
        }
    }
    mDecodeBufferList.unlock();

    // 释放空闲Buffer
    mFreeBufferList.lock();
    while (!mFreeBufferList.empty()) {
        frame = (AudioFrame *)mFreeBufferList.front();
        mFreeBufferList.pop_front();
        if (frame != NULL) {
            delete frame;
        } else {
            break;
        }
    }
    mFreeBufferList.unlock();
}

void AudioDecoderAAC::DecodeAudioFormat(
    AudioFrameFormat format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type) {
}

void AudioDecoderAAC::DecodeAudioFrame(
    AudioFrameFormat format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type,
    const char *data,
    int size,
    int64_t ts) {
    bool bFlag = false;

    if (mbRunning) {
        mFreeBufferList.lock();
        AudioFrame *audioFrame = NULL;
        if (!mFreeBufferList.empty()) {
            audioFrame = (AudioFrame *)mFreeBufferList.front();
            mFreeBufferList.pop_front();

        } else {
            audioFrame = new AudioFrame();
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "AudioDecoderAAC::DecodeAudioFrame( "
                         "this : %p, "
                         "[New Audio Frame], "
                         "frame : %p, "
                         "ts : %lld, "
                         "bufferListSize : %u, "
                         "mDecodeBufferList.size() : %d "
                         ")",
                         this,
                         audioFrame,
                         ts,
                         mBufferListSize,
                         mDecodeBufferList.size());
        }
        mBufferListSize++;
        mFreeBufferList.unlock();

        // 更新数据格式
        audioFrame->ResetFrame();
        audioFrame->mTS = ts;
        audioFrame->InitFrame(format, sound_rate, sound_size, sound_type);

        // 增加ADTS头部
        char *frame = (char *)audioFrame->GetBuffer();
        int headerCapacity = audioFrame->GetBufferCapacity();
        int frameHeaderSize = 0;

        bFlag = mAudioMuxer.GetADTS(size, format, sound_rate, sound_size, sound_type, frame, headerCapacity, frameHeaderSize);
        if (bFlag) {
            // 计算已用的ADTS
            audioFrame->mBufferLen = frameHeaderSize;
            // 计算帧大小是否足够
            if (frameHeaderSize + size > headerCapacity) {
                audioFrame->RenewBufferSize(frameHeaderSize + size);
            }
            // 增加帧内容
            audioFrame->AddBuffer((unsigned char *)data, size);

            // 放进解码队列
            mDecodeBufferList.lock();
            mDecodeBufferList.push_back(audioFrame);
            mDecodeBufferList.unlock();
        }
    }
}

bool AudioDecoderAAC::DecodeAudioFrame(AudioFrame *audioFrame, AudioFrame *newAudioFrame) {
    bool bFlag = false;

    long long curTime = getCurrentTime();
    const char *data = (const char *)audioFrame->GetBuffer();
    int size = audioFrame->mBufferLen;

    // 更新帧参数
    *newAudioFrame = *audioFrame;

    if (NULL != data &&
        size > 0 &&
        NULL != newAudioFrame &&
        NULL != mContext) {

        AVPacket pkt = {0};
        av_init_packet(&pkt);

        int bGotFrame = 0;

        pkt.data = (uint8_t *)data;
        pkt.size = size;

        AVFrame *decodeFrame = audioFrame->mpAVFrame;
        int ret = avcodec_decode_audio4(mContext, decodeFrame, &bGotFrame, &pkt);

        // 计算处理时间
        long long now = getCurrentTime();
        long long handleTime = now - curTime;
        FileLevelLog(
            "rtmpdump",
            KLog::LOG_MSG,
            "AudioDecoderAAC::DecodeAudioFrame( "
            "this : %p, "
            "[Decode Frame], "
            "ret : %d, "
            "ts : %lld, "
            "handleTime : %lld, "
            "size : %d, "
            "data : (Hex)%02x,%02x,%02x,%02x,%02x "
            ")",
            this,
            ret,
            audioFrame->mTS,
            handleTime,
            size,
            pkt.data[0], pkt.data[1], pkt.data[2], pkt.data[3], pkt.data[4]);

        if (ret >= 0) {
            if (bGotFrame) {
                // 解码成功后格式为 AV_SAMPLE_FMT_S16
                int bufferSize = av_samples_get_buffer_size(
                    NULL,
                    decodeFrame->channels,
                    decodeFrame->nb_samples,
                    mContext->sample_fmt,
                    1);
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_STAT,
                    "AudioDecoderAAC::DecodeAudioFrame( "
                    "this : %p, "
                    "[Got Audio Frame], "
                    "bufferSize : %d, "
                    "sample_fmt : %d, "
                    "sample_rate : %d, "
                    "channels : %d, "
                    "nb_samples : %d "
                    ")",
                    this,
                    bufferSize,
                    mContext->sample_fmt,
                    decodeFrame->sample_rate,
                    decodeFrame->channels,
                    decodeFrame->nb_samples);

                // Copy解码Buffer
                newAudioFrame->SetBuffer(decodeFrame->data[0], bufferSize);

                // 用解码器的参数覆盖协议解析的参数
                newAudioFrame->mSoundRate = AFSR_KHZ_44;
                newAudioFrame->mSoundType = (decodeFrame->channels == 2) ? AFST_STEREO : AFST_MONO;
                newAudioFrame->mSoundSize = AFSS_BIT_16;

                bFlag = true;
            }

        } else {
            char errbuf[1024];
            av_strerror(ret, errbuf, sizeof(errbuf));
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "AudioDecoderAAC::DecodeAudioFrame( "
                         "this : %p, "
                         "[Fail], "
                         "ts : %lld, "
                         "ret : %d, "
                         "errbuf : %s "
                         ")",
                         this,
                         audioFrame->mTS,
                         ret,
                         errbuf);
        }
    }

    return bFlag;
}

void AudioDecoderAAC::DecodeAudioHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::DecodeAudioHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    AudioFrame *srcFrame = NULL;
    AudioFrame *dstFrame = NULL;

    while (mbRunning) {
        // 获取解码帧
        srcFrame = NULL;

        mDecodeBufferList.lock();
        if (!mDecodeBufferList.empty()) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "AudioDecoderAAC::DecodeAudioHandle( "
                         "this : %p, "
                         "mDecodeBufferList.size() : %d "
                         ")",
                         this,
                         mDecodeBufferList.size());

            srcFrame = (AudioFrame *)mDecodeBufferList.front();
            mDecodeBufferList.pop_front();
        }
        mDecodeBufferList.unlock();

        if (srcFrame) {
            // 获取空闲Buffer
            mFreeBufferList.lock();
            if (!mFreeBufferList.empty()) {
                dstFrame = (AudioFrame *)mFreeBufferList.front();
                mFreeBufferList.pop_front();
            } else {
                dstFrame = new AudioFrame();
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "AudioDecoderAAC::DecodeAudioHandle( "
                             "this : %p, "
                             "[New Audio Frame], "
                             "frame : %p, "
                             "ts : %lld "
                             ")",
                             this,
                             dstFrame,
                             srcFrame->mTS);
            }
            mFreeBufferList.unlock();

            // 解码码帧
            bool bFlag = DecodeAudioFrame(srcFrame, dstFrame);
            if (bFlag && mpCallback) {
                mpCallback->OnDecodeAudioFrame(this, dstFrame, dstFrame->mTS);
            } else {
                // 释放空闲Buffer
                ReleaseAudioFrame(dstFrame);
            }

            // 释放待编码帧
            ReleaseAudioFrame(srcFrame);
        }

        Sleep(1);
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioDecoderAAC::DecodeAudioHandle( "
				 "this : %p, "
                 "[Exit] "
                 ")",
                 this
                 );
}
}
