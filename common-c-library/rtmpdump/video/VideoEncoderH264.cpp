//
//  VideoEncoderH264.cpp
//  RtmpClient
//
//  Created by Max on 2017/7/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoEncoderH264.h"
#include "VideoMuxer.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

#include <string.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>

#include <libavutil/opt.h>
#include <libavcodec/avcodec.h>
#include <libavutil/channel_layout.h>
#include <libavutil/common.h>
#include <libavutil/imgutils.h>
#include <libavutil/mathematics.h>
#include <libavutil/samplefmt.h>
}

#define MAX_VIDEO_ENCODE_BUFFER_FRAME 10
#define MIN_VIDEO_ENCODE_BUFFER_FRAME 2

namespace coollive {
// 重采样线程
class ConvertEncodeVideoRunnable : public KRunnable {
  public:
    ConvertEncodeVideoRunnable(VideoEncoderH264 *container) {
        mContainer = container;
    }
    virtual ~ConvertEncodeVideoRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->ConvertVideoHandle();
    }

  private:
    VideoEncoderH264 *mContainer;
};

// 编码线程
class EncodeVideoRunnable : public KRunnable {
  public:
    EncodeVideoRunnable(VideoEncoderH264 *container) {
        mContainer = container;
    }
    virtual ~EncodeVideoRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->EncodeVideoHandle();
    }

  private:
    VideoEncoderH264 *mContainer;
};

VideoEncoderH264::VideoEncoderH264()
    : mRuningMutex(KMutex::MutexType_Recursive) {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoEncoderH264::VideoEncoderH264( this : %p )", this);

    mbSpsChange = false;
    mpSps = NULL;
    mSpsSize = 0;
    mbPpsChange = false;
    mpPps = NULL;
    mPpsSize = 0;
    mNaluHeaderSize = 0;

    mpCallback = NULL;
    mWidth = 480;
    mHeight = 640;
    mBitrate = 1000000;
    mKeyFrameInterval = 20;
    mFPS = 20;

    mbRunning = false;

    mCodec = NULL;
    mContext = NULL;

    mSrcFormat = VIDEO_FORMATE_NV21;
    mPts = 0;

    mVideoFormatConverter.SetDstFormat(VIDEO_FORMATE_YUV420P);

    mpConvertEncodeVideoRunnable = new ConvertEncodeVideoRunnable(this);
    mpEncodeVideoRunnable = new EncodeVideoRunnable(this);
}

VideoEncoderH264::~VideoEncoderH264() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoEncoderH264::~VideoEncoderH264( this : %p )", this);

    Stop();

    if (mpConvertEncodeVideoRunnable) {
        delete mpConvertEncodeVideoRunnable;
        mpConvertEncodeVideoRunnable = NULL;
    }

    if (mpEncodeVideoRunnable) {
        delete mpEncodeVideoRunnable;
        mpConvertEncodeVideoRunnable = NULL;
    }

    // 销毁旧的编码器
    DestroyContext();
}

bool VideoEncoderH264::Create(int width, int height, int fps, int keyFrameInterval, int bitrate, VIDEO_FORMATE_TYPE type) {
    bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoEncoderH264::Create( "
                 "this : %p, "
                 "width : %d, "
                 "height : %d, "
                 "fps : %d, "
                 "keyFrameInterval : %d, "
                 "bitrate : %d, "
                 "type : %d "
                 ")",
                 this,
                 width,
                 height,
                 fps,
                 keyFrameInterval,
                 bitrate,
                 type);

    mRuningMutex.lock();
    mWidth = width;
    mHeight = height;
    mBitrate = bitrate;
    mKeyFrameInterval = keyFrameInterval;
    mFPS = fps;
    mSrcFormat = type;
    
    // 创建编码器
    DestroyContext();
    bFlag = CreateContext();
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoEncoderH264::Create( "
                 "this : %p, "
                 "[%s], "
                 "width : %d, "
                 "height : %d, "
                 "fps : %d, "
                 "keyFrameInterval : %d, "
                 "bitrate : %d, "
                 "type : %d "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail",
                 width,
                 height,
                 fps,
                 keyFrameInterval,
                 bitrate,
                 type);

    return bFlag;
}

void VideoEncoderH264::SetCallback(VideoEncoderCallback *callback) {
    mpCallback = callback;
}

bool VideoEncoderH264::Reset() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoEncoderH264::Reset( "
                 "this : %p "
                 ")",
                 this);

    bool bFlag = Start();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoEncoderH264::Reset( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void VideoEncoderH264::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoEncoderH264::Pause( this : %p )", this);

    Stop();

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoEncoderH264::Pause( this : %p, [Success] )", this);
}

VideoFrameRateType VideoEncoderH264::EncodeVideoFrame(void *data, int size, void *frame, int64_t ts) {
    VideoFrameRateType type = VIDEO_FRAME_RATE_HOLD;
    
    mRuningMutex.lock();
    if (mbRunning) {
        if ( mEncodeBufferList.size() < MAX_VIDEO_ENCODE_BUFFER_FRAME ) {
            if ( mEncodeBufferList.size() < MIN_VIDEO_ENCODE_BUFFER_FRAME ) {
                type = VIDEO_FRAME_RATE_INC;
            }
            
            mFreeBufferList.lock();
            VideoFrame *srcFrame = NULL;
            if (!mFreeBufferList.empty()) {
                srcFrame = (VideoFrame *)mFreeBufferList.front();
                mFreeBufferList.pop_front();

            } else {
                srcFrame = new VideoFrame();
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "VideoEncoderH264::EncodeVideoFrame( "
                             "this : %p, "
                             "[New Video Frame], "
                             "ts : %lld, "
                             "frame : %p, "
                             "mConvertBufferList : %u, "
                             "mEncodeBufferList : %u "
                             ")",
                             this,
                             ts,
                             srcFrame,
                             mConvertBufferList.size(),
                             mEncodeBufferList.size()
                             );
            }
            mFreeBufferList.unlock();

            srcFrame->SetBuffer((unsigned char *)data, size);
            srcFrame->InitFrame(mWidth, mHeight, mSrcFormat);
            srcFrame->mTS = ts;
            
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoEncoderH264::EncodeVideoFrame( "
                         "this : %p, "
                         "ts : %lld, "
                         "srcFrame : %p, "
                         "frame : %p "
                         ")",
                         this,
                         ts,
                         srcFrame,
                         frame);

            // 放进采样转换队列
            mConvertBufferList.lock();
            mConvertBufferList.push_back(srcFrame);
            mConvertBufferList.unlock();
        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "VideoEncoderH264::EncodeVideoFrame( "
                         "this : %p, "
                         "[Skip Video Frame 4 Too Quick], "
                         "ts : %lld, "
                         "mConvertBufferList : %u, "
                         "mEncodeBufferList : %u "
                         ")",
                         this,
                         ts,
                         mConvertBufferList.size(),
                         mEncodeBufferList.size()
                         );
            type = VIDEO_FRAME_RATE_DEC;
        }
    }
    mRuningMutex.unlock();
    
    return type;
}

bool VideoEncoderH264::Start() {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::Start( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        Stop();
    }

    mbRunning = true;
    mPts = 0;

    VideoFrame *frame = NULL;
    mFreeBufferList.lock();
    for (int i = 0; i < DEFAULT_VIDEO_BUFFER_COUNT; i++) {
        frame = new VideoFrame();
        frame->RenewBufferSize(DEFAULT_VIDEO_BUFFER_SIZE);
        mFreeBufferList.push_back(frame);
    }
    mFreeBufferList.unlock();

    // 开启重采样线程
    mConvertVideoThread.Start(mpConvertEncodeVideoRunnable);

    // 开启编码线程
    mEncodeVideoThread.Start(mpEncodeVideoRunnable);

    bFlag = true;

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::Start( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void VideoEncoderH264::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::Stop( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        mbRunning = false;

        // 停止重采样线程
        mConvertVideoThread.Stop();

        // 停止编码线程
        mEncodeVideoThread.Stop();

        // 清空队列
        ClearVideoFrame();
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

bool VideoEncoderH264::ConvertVideoFrame(VideoFrame *srcFrame, VideoFrame *dstFrame) {
    bool bFlag = false;

    // 转换采样帧格式
    bool bChangeSize = false;
    bFlag = mVideoFormatConverter.ConvertFrame(srcFrame, dstFrame, bChangeSize);
    if (bFlag) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_STAT,
                     "VideoEncoderH264::ConvertVideoFrame( "
                     "this : %p, "
                     "srcFrame : %p, "
                     "dstFrame : %p "
                     ")",
                     this,
                     srcFrame,
                     dstFrame);
    } else {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoEncoderH264::ConvertVideoFrame( "
                     "this : %p, "
					 "[Fail], "
                     "srcFrame : %p, "
                     "dstFrame : %p "
                     ")",
                     this,
                     srcFrame,
                     dstFrame);
    }

    return bFlag;
}

bool VideoEncoderH264::EncodeVideoFrame(VideoFrame *srcFrame, VideoFrame *dstFrame) {
    bool bFlag = false;
    long long curTime = getCurrentTime();

    mRuningMutex.lock();
    // 编码帧
    AVPacket pkt = {0};
    av_init_packet(&pkt);
    pkt.data = NULL;
    pkt.size = 0;

    // 更新timestamp
    AVFrame *yuvFrame = srcFrame->mpAVFrame;
    yuvFrame->format = mContext->pix_fmt;
    yuvFrame->width = mContext->width;
    yuvFrame->height = mContext->height;

    yuvFrame->pts = mPts++;
//    dstFrame->mTS = (int64_t)floor(1000.0 * yuvFrame->pts / mContext->time_base.den);
    dstFrame->mTS = srcFrame->mTS;
    
    // 编码帧
    int bGotFrame = 0;
    int ret = avcodec_encode_video2(mContext, &pkt, yuvFrame, &bGotFrame);

    // 计算处理时间
    long long now = getCurrentTime();
    long long handleTime = now - curTime;
    FileLevelLog(
        "rtmpdump",
        KLog::LOG_STAT,
        "VideoEncoderH264::EncodeVideoFrame( "
        "this : %p, "
        "[Encode Frame], "
        "srcFrame : %p, "
        "dstFrame : %p, "
        "ts : %lld, "
        "handleTime : %lld "
        ")",
        this,
        srcFrame,
        dstFrame,
        dstFrame->mTS,
        handleTime);

    if (ret >= 0 && bGotFrame) {
        // 填充数据
        dstFrame->SetBuffer(pkt.data, pkt.size);

        FileLevelLog(
            "rtmpdump",
            KLog::LOG_STAT,
            "VideoEncoderH264::EncodeVideoFrame( "
            "this : %p, "
            "[Got Video Frame], "
            "srcFrame : %p, "
            "dstFrame : %p, "
            "ts : %lld, "
            "frameSize : %d, "
            "handleTime : %lld "
            ")",
            this,
            srcFrame,
            dstFrame,
            dstFrame->mTS,
            pkt.size,
            handleTime);
        bFlag = true;
    }
    av_free_packet(&pkt);

    mRuningMutex.unlock();
    return bFlag;
}

bool VideoEncoderH264::CreateContext() {
    FileLevelLog("rtmpdump", KLog::LOG_STAT, "VideoEncoderH264::CreateContext( this : %p )", this);
    mRuningMutex.lock();
    bool bFlag = true;
    avcodec_register_all();
    //    av_log_set_level(AV_LOG_ERROR);

    //    mCodec = avcodec_find_encoder(AV_CODEC_ID_H264);
    mCodec = avcodec_find_encoder_by_name("libx264");
    if (mCodec) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "VideoEncoderH264::CreateContext( "
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
                     "VideoEncoderH264::CreateContext( "
                     "this : %p, "
                     "[Codec Not Found] "
                     ")",
                     this);
        bFlag = false;
    }

    if (bFlag) {
        mContext = avcodec_alloc_context3(mCodec);

        // 调节编码速度和质量的平衡(ultrafast[fastest encoding]/veryslow[best compression])
        /**
         编码参数
         ultrafast[不能用, iOS硬解会失败], superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
         */
        av_opt_set(mContext->priv_data, "preset", "superfast", 0);
        /**
         防止编码延迟
         */
        av_opt_set(mContext->priv_data, "tune", "zerolatency", 0);
        /**
         * 设置不分片
         */
        av_opt_set(mContext->priv_data, "x264-params", "sliced-threads=0", 0);
        
        /**
         @description https://trac.ffmpeg.org/wiki/Encode/H.264
         
         iOS Compatability (​source)
         Profile	Level	Devices	Options
         Baseline	3.0	All devices	-profile:v baseline -level 3.0
         Baseline	3.1	iPhone 3G and later, iPod touch 2nd generation and later	-profile:v baseline -level 3.1
         Main	3.1	iPad (all versions), Apple TV 2 and later, iPhone 4 and later	-profile:v main -level 3.1
         Main	4.0	Apple TV 3 and later, iPad 2 and later, iPhone 4s and later	-profile:v main -level 4.0
         High	4.0	Apple TV 3 and later, iPad 2 and later, iPhone 4s and later	-profile:v high -level 4.0
         High	4.1	iPad 2 and later, iPhone 4s and later, iPhone 5c and later	-profile:v high -level 4.1
         High	4.2	iPad Air and later, iPhone 5s and later	-profile:v high -level 4.2
         
         **/
        /**
         baseline的话iPhone6/iPhone6S用VideoToolBox解码会失败，原因未明
         */
//        av_opt_set(mContext->priv_data, "profile", "baseline", 0);
//        av_opt_set(mContext->priv_data, "level", "3.0", 0);

        mContext->bit_rate = mBitrate;
        mContext->width = mWidth;
        mContext->height = mHeight;
        mContext->time_base = (AVRational){1, mFPS};
        mContext->gop_size = mKeyFrameInterval;
        mContext->max_b_frames = 0; // optional param 可选参数，禁用B帧，设置 x264 参数 profile 值为 baseline 时，此参数失效
        AVPixelFormat srcFormat = AV_PIX_FMT_YUV420P;
        mContext->pix_fmt = srcFormat;

        AVDictionary *options = NULL;
        int ret = avcodec_open2(mContext, mCodec, &options);
        if (ret == 0) {
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_MSG,
                "VideoEncoderH264::CreateContext( "
                "this : %p, "
                "[Codec opened] "
                ")",
                this);
        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_ERR_SYS,
                         "VideoEncoderH264::CreateContext( "
                         "this : %p, "
                         "[Could not open codec], "
                         "ret : %d "
                         ")",
                         this,
                         ret);
            bFlag = false;
        }
    }

    if (!bFlag) {
        DestroyContext();

        FileLevelLog("rtmpdump",
                     KLog::LOG_ERR_SYS,
                     "VideoEncoderH264::CreateContext( "
                     "this : %p, "
                     "[Fail] "
                     ")",
                     this);
    }

    mRuningMutex.unlock();
    return bFlag;
}

void VideoEncoderH264::DestroyContext() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::DestroyContext( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mContext) {
        avcodec_close(mContext);
        avcodec_free_context(&mContext);
        mContext = NULL;
    }

    mCodec = NULL;
    mRuningMutex.unlock();
}

void VideoEncoderH264::ReleaseBuffer(VideoFrame *videoFrame) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "VideoEncoderH264::ReleaseBuffer( "
                 "this : %p, "
                 "videoFrame : %p, "
                 "mFreeBufferList.size() : %d "
                 ")",
                 this,
                 videoFrame,
                 mFreeBufferList.size());

    mFreeBufferList.lock();
    mFreeBufferList.push_back(videoFrame);
    mFreeBufferList.unlock();
}

void VideoEncoderH264::ClearVideoFrame() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::ClearVideoFrame( "
                 "this : %p, "
                 "mEncodeBufferList.size() : %d, "
                 "mConvertBufferList.size() : %d, "
                 "mFreeBufferList.size() : %d "
                 ")",
                 this,
                 mEncodeBufferList.size(),
                 mConvertBufferList.size(),
                 mFreeBufferList.size());

    // 释放解码Buffer
    VideoFrame *frame = NULL;

    mEncodeBufferList.lock();
    while (!mEncodeBufferList.empty()) {
        frame = (VideoFrame *)mEncodeBufferList.front();
        mEncodeBufferList.pop_front();
        if (frame != NULL) {
            delete frame;
        } else {
            break;
        }
    }
    mEncodeBufferList.unlock();

    // 释放转换Buffer
    mConvertBufferList.lock();
    while (!mConvertBufferList.empty()) {
        frame = (VideoFrame *)mConvertBufferList.front();
        mConvertBufferList.pop_front();
        if (frame != NULL) {
            delete frame;
        } else {
            break;
        }
    }
    mConvertBufferList.unlock();

    // 释放空闲Buffer
    mFreeBufferList.lock();
    while (!mFreeBufferList.empty()) {
        frame = (VideoFrame *)mFreeBufferList.front();
        mFreeBufferList.pop_front();
        if (frame != NULL) {
            delete frame;
        } else {
            break;
        }
    }
    mFreeBufferList.unlock();
}

char *VideoEncoderH264::FindNalu(char *start, int size, int &startCodeSize) {
    static const char naluStartCode[] = {0x00, 0x00, 0x00, 0x01};
    static const char sliceStartCode[] = {0x00, 0x00, 0x01};
    startCodeSize = 0;
    char *nalu = NULL;
    char frameType = *start & 0x1F;

    for (int i = 0; i < size; i++) {
        // Only SPS or PPS need to seperate by slice start code
        if (frameType == 0x07 || frameType == 0x08) {
            if (i + sizeof(sliceStartCode) < size &&
                memcmp(start + i, sliceStartCode, sizeof(sliceStartCode)) == 0) {
                startCodeSize = sizeof(sliceStartCode);
                nalu = start + i;
                break;
            }
        }

        if (i + sizeof(naluStartCode) < size &&
            memcmp(start + i, naluStartCode, sizeof(naluStartCode)) == 0) {
            startCodeSize = sizeof(naluStartCode);
            nalu = start + i;
            break;
        }
    }

    return nalu;
}

void VideoEncoderH264::ConvertVideoHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::ConvertVideoHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    VideoFrame *srcFrame = NULL;
    VideoFrame *dstFrame = NULL;

    while (mbRunning) {
        // 获取采样帧
        srcFrame = NULL;
        dstFrame = NULL;

        mConvertBufferList.lock();
        if (!mConvertBufferList.empty()) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoEncoderH264::ConvertVideoHandle( "
                         "this : %p, "
                         "mConvertBufferList.size() : %d "
                         ")",
                         this,
                         mConvertBufferList.size());

            srcFrame = (VideoFrame *)mConvertBufferList.front();
            mConvertBufferList.pop_front();
        }
        mConvertBufferList.unlock();

        if (srcFrame) {
            // 获取空闲Buffer
            mFreeBufferList.lock();
            if (!mFreeBufferList.empty()) {
                dstFrame = (VideoFrame *)mFreeBufferList.front();
                mFreeBufferList.pop_front();
            } else {
                dstFrame = new VideoFrame();
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "VideoEncoderH264::ConvertVideoHandle( "
                             "this : %p, "
                             "[New Video Frame], "
                             "frame : %p, "
                             "mConvertBufferList : %u, "
                             "mEncodeBufferList : %u "
                             ")",
                             this,
                             dstFrame,
                             mConvertBufferList.size(),
                             mEncodeBufferList.size()
                             );
            }
            mFreeBufferList.unlock();

            // 重新采样
            long long curTime = getCurrentTime();
            bool bFlag = ConvertVideoFrame(srcFrame, dstFrame);
            if (bFlag) {
                // 放到待编码队列
                mEncodeBufferList.lock();
                mEncodeBufferList.push_back(dstFrame);
                mEncodeBufferList.unlock();

            } else {
                // 释放空闲视频帧
                ReleaseBuffer(dstFrame);
            }
            // 计算处理时间
            long long now = getCurrentTime();
            long long handleTime = now - curTime;
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoEncoderH264::ConvertVideoHandle( "
                         "this : %p, "
						 "[%s], "
                         "srcFrame : %p, "
                         "dstFrame : %p, "
                         "handleTime : %lld, "
                         "mConvertBufferList : %u, "
                         "mEncodeBufferList : %u "
                         ")",
                         this,
						 bFlag?"Success":"Fail",
                         srcFrame,
                         dstFrame,
                         handleTime,
                         mConvertBufferList.size(),
                         mEncodeBufferList.size()
                         );

            // 释放采样视频帧
            ReleaseBuffer(srcFrame);
        }

        Sleep(1);
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::ConvertVideoHandle( "
                 "this : %p, "
				 "[Exit] "
                 ")",
                 this);
}

void VideoEncoderH264::EncodeVideoHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoEncoderH264::EncodeVideoHandle( "
                 "this : %p "
				 "[Start], "
                 ")",
                 this);

    VideoFrame *srcFrame = NULL;
    VideoFrame tmpFrame;
    VideoFrame *dstFrame = &tmpFrame;

    while (mbRunning) {
        // 获取编码帧
        srcFrame = NULL;

        mEncodeBufferList.lock();
        if (!mEncodeBufferList.empty()) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoEncoderH264::EncodeVideoHandle( "
                         "this : %p, "
                         "mEncodeBufferList.size() : %d "
                         ")",
                         this,
                         mEncodeBufferList.size());

            srcFrame = (VideoFrame *)mEncodeBufferList.front();
            mEncodeBufferList.pop_front();
        }
        mEncodeBufferList.unlock();

        if (srcFrame) {
            // 编码帧
            long long curTime = getCurrentTime();
            if (EncodeVideoFrame(srcFrame, dstFrame)) {
                // 分离Nalu
                bool bFinish = false;
                char *buffer = (char *)dstFrame->GetBuffer();
                int leftSize = dstFrame->mBufferLen;
                int naluSize = 0;

                char *naluStart = NULL;
                char *naluEnd = NULL;

                int startCodeSize = 0;

                // 找到第一帧
                naluStart = FindNalu(buffer, dstFrame->mBufferLen, startCodeSize);
                if (naluStart) {
                    naluStart += startCodeSize;
                    leftSize -= (int)(naluStart - buffer);
                }

                while (naluStart) {
                    naluSize = 0;

                    // 寻找Nalu
                    naluEnd = FindNalu(naluStart, leftSize, startCodeSize);
                    if (naluEnd != NULL) {
                        // 找到Nalu
                        naluSize = (int)(naluEnd - naluStart);

                    } else {
                        // 最后一个Nalu
                        naluSize = leftSize;

                        bFinish = true;
                    }

                    FileLevelLog("rtmpdump",
                                 KLog::LOG_STAT,
                                 "VideoEncoderH264::EncodeVideoHandle( "
                                 "this : %p, "
								 "[Got Nalu], "
                                 "frameType : 0x%x, "
                                 "naluSize : %d, "
                                 "leftSize : %d, "
                                 "bFinish : %s "
                                 ")",
                                 this,
                                 (*naluStart & 0x1f),
                                 naluSize,
                                 leftSize,
                                 bFinish ? "true" : "false");

                    // 回调编码成功
                    if (NULL != mpCallback) {
                        mpCallback->OnEncodeVideoFrame(this, naluStart, naluSize, dstFrame->mTS);
                    }

                    // 数据下标偏移
                    naluStart = naluEnd + startCodeSize;
                    leftSize -= naluSize;

                    if (bFinish) {
                        break;
                    }
                }
            }
            
            // 计算处理时间
            long long now = getCurrentTime();
            long long handleTime = now - curTime;
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoEncoderH264::EncodeVideoHandle( "
                         "this : %p, "
                         "srcFrame : %p, "
                         "dstFrame : %p, "
                         "handleTime : %lld, "
                         "mConvertBufferList : %u, "
                         "mEncodeBufferList : %u "
                         ")",
                         this,
                         srcFrame,
                         dstFrame,
                         handleTime,
                         mConvertBufferList.size(),
                         mEncodeBufferList.size()
                         );
            
            // 释放待编码视频帧
            ReleaseBuffer(srcFrame);
        }
        
        Sleep(1);
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoEncoderH264::EncodeVideoHandle( "
                "this : %p, "
				"[Exit] "
                ")",
                this
                );
}
}
