/*
 * VideoDecoderH264.cpp
 *
 *  Created on: 2017年4月21日
 *      Author: max
 */

#include "VideoDecoderH264.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>
#include <libavutil/pixfmt.h>
}

namespace coollive {

// 解码线程
class DecodeVideoRunnable : public KRunnable {
  public:
    DecodeVideoRunnable(VideoDecoderH264 *container) {
        mContainer = container;
    }
    virtual ~DecodeVideoRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->DecodeVideoHandle();
    }

  private:
    VideoDecoderH264 *mContainer;
};

// 格式转换线程
class ConvertVideoRunnable : public KRunnable {
  public:
    ConvertVideoRunnable(VideoDecoderH264 *container) {
        mContainer = container;
    }
    virtual ~ConvertVideoRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->ConvertVideoHandle();
    }

  private:
    VideoDecoderH264 *mContainer;
};

VideoDecoderH264::VideoDecoderH264()
    : mRuningMutex(KMutex::MutexType_Recursive),
      mDropFrameMutex(KMutex::MutexType_Recursive) {
    // TODO Auto-generated constructor stub
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::VideoDecoderH264( this : %p )", this);

    mCodec = NULL;
    mContext = NULL;

    mGotPicture = 0;
    mLen = 0;

    mDecoderFormat = AV_PIX_FMT_BGRA; //AV_PIX_FMT_RGB565;

    mCorpFrame = NULL;
    mCorpBuffer = NULL;

    mNaluHeaderSize = 0;

    mpCallback = NULL;

    mbRunning = false;

    mbDropFrame = false;
    mbWaitForInterFrame = true;
    mbCanDropFrame = false;

    mbHEVC = false;
          
    mpDecodeVideoRunnable = new DecodeVideoRunnable(this);
    mpConvertVideoRunnable = new ConvertVideoRunnable(this);
}

VideoDecoderH264::~VideoDecoderH264() {
    // TODO Auto-generated destructor stub
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::~VideoDecoderH264( this : %p )", this);

    Stop();

    if (mpDecodeVideoRunnable) {
        delete mpDecodeVideoRunnable;
        mpDecodeVideoRunnable = NULL;
    }

    if (mpConvertVideoRunnable) {
        delete mpConvertVideoRunnable;
        mpConvertVideoRunnable = NULL;
    }
}

bool VideoDecoderH264::Create(VideoDecoderCallback *callback) {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::Create( this : %p )", this);

    mpCallback = callback;

    bool bFlag = true;

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoDecoderH264::Create( "
                                                "this : %p, "
                                                "[%s] "
                                                ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

bool VideoDecoderH264::Reset() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::Reset( "
                 "this : %p "
                 ")",
                 this);

    bool bFlag = Start();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::Reset( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail");

    return bFlag;
}

void VideoDecoderH264::Pause() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::Pause( "
                 "this : %p "
                 ")",
                 this);

    Stop();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::Pause( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

void VideoDecoderH264::ResetStream() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::ResetStream( "
                 "this : %p "
                 ")",
                 this);
}

void VideoDecoderH264::ReleaseVideoFrame(void *frame) {
    VideoFrame *videoFrame = (VideoFrame *)frame;

    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "VideoDecoderH264::ReleaseVideoFrame( "
                 "this : %p, "
                 "videoFrame : %p, "
                 "ts : %lld "
                 ")",
                 this,
                 videoFrame,
                 videoFrame->mTS);

    mFreeBufferList.lock();
    if (mFreeBufferList.size() >= DEFAULT_VIDEO_BUFFER_MAX_COUNT) {
        delete videoFrame;
    } else {
        mFreeBufferList.push_back(videoFrame);
    }
    mFreeBufferList.unlock();
}

bool VideoDecoderH264::Start() {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::Start( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        Stop();
    }

    // 创建解码器
    bFlag = CreateContext();
    if (bFlag) {
        mbRunning = true;

        VideoFrame *frame = NULL;
        mFreeBufferList.lock();
        for (int i = 0; i < DEFAULT_VIDEO_BUFFER_COUNT; i++) {
            frame = new VideoFrame();
            frame->RenewBufferSize(DEFAULT_VIDEO_BUFFER_SIZE);
            mFreeBufferList.push_back(frame);
        }
        mFreeBufferList.unlock();

        // 开启解码线程
        mDecodeVideoThread.Start(mpDecodeVideoRunnable);

        // 开启格式转换线程
        mConvertVideoThread.Start(mpConvertVideoRunnable);
    }

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

void VideoDecoderH264::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::Stop( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        mbRunning = false;

        // 停止解码线程
        mDecodeVideoThread.Stop();

        // 停止转换线程
        mConvertVideoThread.Stop();

        // 清空队列
        ClearVideoFrame();

        // 销毁旧的解码器
        DestroyContext();

        // 重置参数
        mbDropFrame = false;
        mbWaitForInterFrame = true;
        mbCanDropFrame = false;
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

bool VideoDecoderH264::CreateContext() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::CreateContext( this : %p )", this);

    bool bFlag = true;
    avcodec_register_all();
    //    av_log_set_level(AV_LOG_ERROR);

    mCodec = avcodec_find_decoder(mbHEVC?AV_CODEC_ID_HEVC:AV_CODEC_ID_H264);
    if (mCodec) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoDecoderH264::CreateContext( "
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
                     "VideoDecoderH264::CreateContext( "
                     "this : %p, "
                     "[Codec Not Found] "
                     ")",
                     this);
        bFlag = false;
    }

    if (bFlag) {
        mContext = avcodec_alloc_context3(mCodec);
        //        if( (mCodec->capabilities & CODEC_CAP_TRUNCATED) ) {
        //            mContext->flags |= CODEC_FLAG_TRUNCATED;
        //        }

        AVDictionary *options = NULL;
        //        av_dict_set(&options, "threads", "2", 0);

        if (avcodec_open2(mContext, mCodec, &options) == 0) {
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_MSG,
                "VideoDecoderH264::CreateContext( "
                "this : %p, "
                "[Codec opened] "
                ")",
                this);
        } else {
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_ERR_SYS,
                "VideoDecoderH264::CreateContext( "
                "this : %p, "
                "[Could not open codec] "
                ")",
                this);
            bFlag = false;
        }
    }

    if (!bFlag) {
        DestroyContext();

        FileLevelLog("rtmpdump",
                     KLog::LOG_ERR_SYS,
                     "VideoDecoderH264::CreateContext( "
                     "this : %p, "
                     "[Fail] "
                     ")",
                     this);
    }

    return bFlag;
}

void VideoDecoderH264::DestroyContext() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::DestroyContext( "
                 "this : %p "
                 ")",
                 this);

    if (mContext) {
        avcodec_close(mContext);
        avcodec_free_context(&mContext);
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

void VideoDecoderH264::DecodeVideoKeyFrame(const char *sps, int sps_size, const char *pps, int pps_size, int naluHeaderSize, int64_t ts, const char *vps, int vps_size) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::DecodeVideoKeyFrame( "
                 "this : %p, "
                 "sps : %p, "
                 "sps_size : %d, "
                 "pps : %p, "
                 "pps_size : %d, "
                 "vps : %p, "
                 "vps_size : %d, "
                 "naluHeaderSize : %d, "
                 "ts : %lld "
                 ")",
                 this,
                 sps,
                 sps_size,
                 pps,
                 pps_size,
                 vps,
                 vps_size,
                 naluHeaderSize,
                 ts);

    mNaluHeaderSize = naluHeaderSize;

    mSPS_PPS_IDR.ResetFrame();
    if ( vps_size > 0 && vps ) {
        if ( !mbHEVC ) {
            mbHEVC = true;
            mRuningMutex.lock();
            DestroyContext();
            CreateContext();
            mRuningMutex.unlock();
        }
        mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
        mSPS_PPS_IDR.AddBuffer((const unsigned char *)vps, vps_size);
    } else {
        if ( mbHEVC ) {
            mbHEVC = false;
            mRuningMutex.lock();
            DestroyContext();
            CreateContext();
            mRuningMutex.unlock();
        }
    }
    
    mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
    mSPS_PPS_IDR.AddBuffer((const unsigned char *)sps, sps_size);

    mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
    mSPS_PPS_IDR.AddBuffer((const unsigned char *)pps, pps_size);
}

void VideoDecoderH264::DecodeVideoFrame(const char *data, int size, int64_t dts, int64_t pts, VideoFrameType video_type) {
    mFreeBufferList.lock();
    VideoFrame *videoFrame = NULL;
    if (!mFreeBufferList.empty()) {
        videoFrame = (VideoFrame *)mFreeBufferList.front();
        mFreeBufferList.pop_front();

    } else {
        videoFrame = new VideoFrame();
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "VideoDecoderH264::DecodeVideoFrame( "
                     "this : %p, "
                     "[New Video Frame], "
                     "frame : %p "
                     ")",
                     this,
                     videoFrame);
    }
    mFreeBufferList.unlock();

    // 更新数据格式, 因为ffmpeg里面会对帧重排序, 所以将DTS记录为时间戳
    videoFrame->ResetFrame();
    videoFrame->mTS = dts;
    videoFrame->mVideoType = video_type;
    //    videoFrame->SetBuffer((const unsigned char*)data, size);

    // Mux
    Nalu naluArray[16];
    int naluArraySize = _countof(naluArray);
    bool bFlag = mVideoMuxer.GetNalus(data, size, mNaluHeaderSize, naluArray, naluArraySize);
    if (bFlag && naluArraySize > 0) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "VideoDecoderH264::DecodeVideoFrame( "
                     "this : %p, "
                     "[Got Nalu Array], "
                     "ts : %lld, "
                     "size : %d, "
                     "naluArraySize : %d "
                     ")",
                     this,
                     dts,
                     size,
                     naluArraySize);

        int naluIndex = 0;
        while (naluIndex < naluArraySize) {
            Nalu *nalu = naluArray + naluIndex;
            naluIndex++;

            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoDecoderH264::DecodeVideoFrame( "
                         "this : %p, "
                         "[Got Nalu], "
                         "naluSize : %d, "
                         "naluBodySize : %d, "
                         "frameType : %d "
                         ")",
                         this,
                         nalu->GetNaluSize(),
                         nalu->GetNaluBodySize(),
                         nalu->GetNaluType());

            videoFrame->AddBuffer(sync_bytes, sizeof(sync_bytes));
            videoFrame->AddBuffer((const unsigned char *)nalu->GetNaluBody(), nalu->GetNaluBodySize());
        }
    }

    // 放进解码队列
    mDecodeBufferList.lock();
    mDecodeBufferList.push_back(videoFrame);
    mDecodeBufferList.unlock();
}

bool VideoDecoderH264::DecodeVideoFrame(VideoFrame *videoFrame, VideoFrame *newVideoFrame) {
    bool bFlag = false;

    long long curTime = getCurrentTime();

    const char *data = (const char *)videoFrame->GetBuffer();
    int size = videoFrame->mBufferLen;
    VideoFrameType video_type = videoFrame->mVideoType;

    if (NULL != data &&
        size > 0 &&
        NULL != newVideoFrame &&
        NULL != mContext) {
        AVPacket packet = {0};
        av_init_packet(&packet);

        bool bGotPPS = false;
        const char *frame = NULL;
        int frameSize = 0;

        if (video_type == VFT_IDR && mSPS_PPS_IDR.mBufferLen > 0) {
            //			mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
            //			mSPS_PPS_IDR.AddBuffer((const unsigned char*)data + mNaluHeaderSize, size - mNaluHeaderSize);
            mSPS_PPS_IDR.AddBuffer((const unsigned char *)data, size);

            frame = (const char *)mSPS_PPS_IDR.GetBuffer();
            frameSize = mSPS_PPS_IDR.mBufferLen;

            bGotPPS = true;

            FileLog("rtmpdump",
                    "VideoDecoderH264::DecodeVideoFrame( "
                    "this : %p, "
                    "[Got Key Frame], "
                    "ts : %lld, "
                    "frameSize : %d "
                    ")",
                    this,
                    newVideoFrame->mTS,
                    frameSize);

        } else {
            //			mSyncBuffer.SetBuffer(sync_bytes, sizeof(sync_bytes));
            //			mSyncBuffer.AddBuffer((const unsigned char*)data + mNaluHeaderSize, size - mNaluHeaderSize);
            mSyncBuffer.SetBuffer((const unsigned char *)data, size);

            frame = (const char *)mSyncBuffer.GetBuffer();
            frameSize = mSyncBuffer.mBufferLen;

            //			FileLog("rtmpdump",
            //					"VideoDecoderH264::DecodeVideoFrame( "
            //					"[Got Frame], "
            //					"this : %p, "
            //                    "timestamp : %u, "
            //					"frameSize : %d "
            //					")",
            //					this,
            //                    newVideoFrame->mTimestamp,
            //					frameSize
            //					);
        }

        packet.data = (uint8_t *)frame;
        packet.size = frameSize;

        //		FileLog("rtmpdump",
        //				"VideoDecoderH264::DecodeVideoFrame( "
        //				"[Decode Frame], "
        //				"this : %p, "
        //                "timestamp : %u, "
        //				")",
        //				this,
        //                newVideoFrame->mTimestamp
        //				);

        AVFrame *pictureFrame = newVideoFrame->mpAVFrame;
        int useLen = avcodec_decode_video2(mContext, pictureFrame, &mGotPicture, &packet);
        if (useLen >= 0 && mGotPicture) {
            //		    newVideoFrame->mFormat = VIDEO_FORMATE_YUV420P;
            //			newVideoFrame->mWidth = mContext->width;
            //			newVideoFrame->mHeight = mContext->height;

            int destSize = avpicture_get_size((AVPixelFormat)pictureFrame->format, pictureFrame->width, pictureFrame->height);

            // 填充帧内容
            newVideoFrame->ResetFrame();
            newVideoFrame->RenewBufferSize(destSize);
            newVideoFrame->mBufferLen = destSize;
            avpicture_layout(
                (AVPicture *)pictureFrame,
                (AVPixelFormat)pictureFrame->format,
                pictureFrame->width,
                pictureFrame->height,
                newVideoFrame->GetBuffer(),
                destSize);

            // 更新帧参数
            *newVideoFrame = *videoFrame;
            newVideoFrame->mFormat = VIDEO_FORMATE_YUV420P;
            newVideoFrame->mWidth = pictureFrame->width;
            newVideoFrame->mHeight = pictureFrame->height;
            
            bFlag = true;
        } else if ( useLen < 0 ) {
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderH264::DecodeVideoFrame( "
                "this : %p, "
                "[Decode Frame Error], "
                "srcFrame : %p, "
                "dstFrame : %p, "
                "ts : %lld, "
                "error : %ld "
                ")",
                this,
                videoFrame,
                newVideoFrame,
                newVideoFrame->mTS,
                useLen
                );
        }

        // 计算处理时间
        long long now = getCurrentTime();
        long long handleTime = now - curTime;
        FileLevelLog(
            "rtmpdump",
            KLog::LOG_STAT,
            "VideoDecoderH264::DecodeVideoFrame( "
            "this : %p, "
            "[Decode Frame], "
            "srcFrame : %p, "
            "dstFrame : %p, "
            "ts : %lld, "
            "handleTime : %lld "
            ")",
            this,
            videoFrame,
            newVideoFrame,
            newVideoFrame->mTS,
            handleTime);

        if (bGotPPS) {
            mSPS_PPS_IDR.ResetFrame();
        }
    }

    return bFlag;
}

void VideoDecoderH264::StartDropFrame() {
    FileLog("rtmpdump",
            "VideoDecoderH264::StartDropFrame( "
            "this : %p "
            ")",
            this);

    mDropFrameMutex.lock();
    mbCanDropFrame = true;
    //    mbDropFrame = true;
    //    mbWaitForInterFrame = true;
    mDropFrameMutex.unlock();

    //    mDecodeBufferList.lock();
    //    mbMaxDecodeBufferCount = mDecodeBufferList.size();
    //    mDecodeBufferList.unlock();
}

void VideoDecoderH264::ClearVideoFrame() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::ClearVideoFrame( "
                 "this : %p, "
                 "mDecodeBufferList.size() : %d, "
                 "mConvertBufferList.size() : %d, "
                 "mFreeBufferList.size() : %d "
                 ")",
                 this,
                 mDecodeBufferList.size(),
                 mConvertBufferList.size(),
                 mFreeBufferList.size());

    // 释放解码Buffer
    VideoFrame *frame = NULL;

    mDecodeBufferList.lock();
    while (!mDecodeBufferList.empty()) {
        frame = (VideoFrame *)mDecodeBufferList.front();
        mDecodeBufferList.pop_front();
        if (frame != NULL) {
            delete frame;
        } else {
            break;
        }
    }
    mDecodeBufferList.unlock();

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

void VideoDecoderH264::SetDecoderVideoFormat(VIDEO_FORMATE_TYPE type) {
    mVideoFormatConverter.SetDstFormat(type);
}

void VideoDecoderH264::DecodeVideoHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::DecodeVideoHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    VideoFrame *srcFrame = NULL;
    VideoFrame *dstFrame = NULL;

    // 开始解码帧时间戳
    int64_t startTS = 0;
    // 上一帧视频播放时间戳
    int64_t preTS = 0;
    // 当前帧时间
    int64_t ts = 0;
    // 开始解码时间
    long long startDecodeTime = 0;
    // 解码总用时
    long long decodeTotalTime = 0;
    // 总帧时间差
    long long decodeTotalMS = 0;
    // 解码一帧时间
    long long decodeTime = 0;

    bool bFlag = false;
    bool bSleep = true;
    //    bool bDropFrame = false;
    //    bool bWaitForInterFrame = true;

    while (mbRunning) {
        bFlag = false;
        srcFrame = NULL;
        dstFrame = NULL;
        ts = 0;
        decodeTime = 0;

        mDecodeBufferList.lock();
        if (!mDecodeBufferList.empty()) {
            srcFrame = (VideoFrame *)mDecodeBufferList.front();
            if (srcFrame) {
                // 去除解码的Buffer
                mDecodeBufferList.pop_front();

                long long curTime = getCurrentTime();
                ts = srcFrame->mTS;

                // 更新开始帧时间戳
                if (preTS == 0 || preTS >= srcFrame->mTS) {
                    FileLog("rtmpdump",
                            "VideoDecoderH264::DecodeVideoHandle( "
                            "this : %p, "
                            "[Reset Start Timestamp], "
                            "startDecodeTime : %lld, "
                            "startTS : %lld, "
                            "preTS : %lld, "
                            "ts : %lld "
                            ")",
                            this,
                            curTime,
                            startTS,
                            preTS,
                            srcFrame->mTS);

                    startTS = srcFrame->mTS;
                    preTS = srcFrame->mTS;

                    startDecodeTime = curTime;
                    decodeTotalTime = 0;
                    decodeTotalMS = 0;

                    mDropFrameMutex.lock();
                    mbDropFrame = false;
                    mbWaitForInterFrame = true;
                    mDropFrameMutex.unlock();
                }

                bool bStartDecode = false;
                mDropFrameMutex.lock();
                if (mbDropFrame) {
                    // 等待InterFrame
                    if (srcFrame->mVideoType == VFT_IDR) {
                        mDropFrameMutex.lock();
                        mbWaitForInterFrame = false;
                        mbDropFrame = false;
                        mDropFrameMutex.unlock();

                        bStartDecode = true;
                    }
                } else {
                    // 不用等待, 直接解码
                    bStartDecode = true;
                }
                mDropFrameMutex.unlock();

                if (bStartDecode) {
                    // 真正解码
                    // 获取空闲Buffer
                    mFreeBufferList.lock();
                    if (!mFreeBufferList.empty()) {
                        dstFrame = (VideoFrame *)mFreeBufferList.front();
                        mFreeBufferList.pop_front();
                    } else {
                        dstFrame = new VideoFrame();
                        FileLevelLog("rtmpdump",
                                     KLog::LOG_WARNING,
                                     "VideoDecoderH264::DecodeVideoHandle( "
                                     "this : %p, "
                                     "[New Video Frame], "
                                     "frame : %p "
                                     ")",
                                     this,
                                     dstFrame);
                    }
                    mFreeBufferList.unlock();

                    long long curTime = getCurrentTime();
                    bFlag = DecodeVideoFrame(srcFrame, dstFrame);
                    // 计算处理时间
                    long long now = getCurrentTime();
                    long long handleTime = now - curTime;
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_MSG,
                                 "VideoDecoderH264::DecodeVideoHandle( "
                                 "this : %p, "
                                 "srcFrame : %p, "
                                 "dstFrame : %p, "
                                 "handleTime : %lld, "
                                 "mDecodeBufferList : %u, "
                                 "mConvertBufferList : %u "
                                 ")",
                                 this,
                                 srcFrame,
                                 dstFrame,
                                 handleTime,
                                 mDecodeBufferList.size(),
                                 mConvertBufferList.size());
                }
            }

            // 归还空闲Buffer
            ReleaseVideoFrame(srcFrame);

        } else {
            // 没有更多帧
        }
        mDecodeBufferList.unlock();

        if (bFlag && dstFrame) {
            // 放到转换队列
            mConvertBufferList.lock();
            mConvertBufferList.push_back(dstFrame);
            mConvertBufferList.unlock();

        } else {
            // 归还没使用Buffer
            if (dstFrame) {
                ReleaseVideoFrame(dstFrame);
                dstFrame = NULL;
            }
        }

        if (bSleep) {
            Sleep(1);
        }
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::DecodeVideoHandle( "
                 "this : %p, "
                 "[Exit] "
                 ")",
                 this);
}

void VideoDecoderH264::ConvertVideoHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::ConvertVideoHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    VideoFrame *srcFrame = NULL;
    VideoFrame *dstFrame = NULL;
    // 当前帧时间
    int64_t ts = 0;

    while (mbRunning) {
        srcFrame = NULL;

        mConvertBufferList.lock();
        if (!mConvertBufferList.empty()) {
            srcFrame = (VideoFrame *)mConvertBufferList.front();
            if (srcFrame) {
                // 去除解码的Buffer
                mConvertBufferList.pop_front();
            }
        } else {
            // 没有更多帧
        }
        mConvertBufferList.unlock();

        if (srcFrame) {
            ts = srcFrame->mTS;

            // 获取空闲Buffer
            mFreeBufferList.lock();
            if (!mFreeBufferList.empty()) {
                dstFrame = (VideoFrame *)mFreeBufferList.front();
                mFreeBufferList.pop_front();
            } else {
                dstFrame = new VideoFrame();
                FileLevelLog(
                    "rtmpdump",
                    KLog::LOG_WARNING,
                    "VideoDecoderH264::ConvertVideoHandle( "
                    "this : %p, "
                    "[New Video Frame], "
                    "frame : %p "
                    ")",
                    this,
                    dstFrame);
            }
            mFreeBufferList.unlock();

            long long curTime = getCurrentTime();
            // 格式转换
            bool bChangeSize = mVideoFormatConverter.ConvertFrame(srcFrame, dstFrame);
            // 计算处理时间
            long long now = getCurrentTime();
            long long handleTime = now - curTime;
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoDecoderH264::ConvertVideoHandle( "
                         "this : %p, "
                         "srcFrame : %p, "
                         "dstFrame : %p, "
                         "handleTime : %lld, "
                         "mDecodeBufferList : %u, "
                         "mConvertBufferList : %u "
                         ")",
                         this,
                         srcFrame,
                         dstFrame,
                         handleTime,
                         mDecodeBufferList.size(),
                         mConvertBufferList.size());

            if ( mpCallback && bChangeSize ) {
                mpCallback->OnDecodeVideoChangeSize(this, mVideoFormatConverter.GetWidth(), mVideoFormatConverter.GetHeight());
            }
            
            // 回调播放
            if (mpCallback && dstFrame) {
                // 放进播放器
                mpCallback->OnDecodeVideoFrame(this, dstFrame, dstFrame->mTS);

            } else {
                // 归还没使用Buffer
                if( dstFrame ) {
                    ReleaseVideoFrame(dstFrame);
                    dstFrame = NULL;
                }
            }
            
            // 归还解码Buffer
            ReleaseVideoFrame(srcFrame);
        }

        Sleep(1);

    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::ConvertVideoHandle( "
				 "this : %p, "
                 "[Exit] "
				 ")",
				 this
				 );
}

}
