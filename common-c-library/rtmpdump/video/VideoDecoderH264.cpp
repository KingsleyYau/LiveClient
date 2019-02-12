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
    :mRuningMutex(KMutex::MutexType_Recursive),
    mDropFrameMutex(KMutex::MutexType_Recursive)
{
	// TODO Auto-generated constructor stub
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::VideoDecoderH264( this : %p )", this);
        
	mCodec = NULL;
	mContext = NULL;

	mGotPicture = 0;
	mLen = 0;

    mDecoderFormat = AV_PIX_FMT_BGRA;//AV_PIX_FMT_RGB565;

    mCorpFrame = NULL;
    mCorpBuffer = NULL;

    mNaluHeaderSize = 0;
    
    mpCallback = NULL;
        
    mbRunning = false;
        
    mbDropFrame = false;
    mbWaitForInterFrame = true;
    mbCanDropFrame = false;
        
    mpDecodeVideoRunnable = new DecodeVideoRunnable(this);
    mpConvertVideoRunnable = new ConvertVideoRunnable(this);
}

VideoDecoderH264::~VideoDecoderH264() {
	// TODO Auto-generated destructor stub
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::~VideoDecoderH264( this : %p )", this);
    
    Stop();
    
    if( mpDecodeVideoRunnable ) {
        delete mpDecodeVideoRunnable;
        mpDecodeVideoRunnable = NULL;
    }
    
    if( mpConvertVideoRunnable ) {
        delete mpConvertVideoRunnable;
        mpConvertVideoRunnable = NULL;
    }
}

bool VideoDecoderH264::Create(VideoDecoderCallback* callback) {
	FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::Create( this : %p )", this);

    mpCallback = callback;

    bool bFlag = true;
    
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoDecoderH264::Create( "
    			 "this : %p, "
                 "[%s] "
                 ")",
				 this,
                 bFlag?"Success":"Fail"
                 );
    
	return bFlag;
}

bool VideoDecoderH264::Reset() {
    FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "VideoDecoderH264::Reset( "
                "this : %p "
                ")",
                this
                );
    
    bool bFlag = Start();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::Reset( "
                 "this : %p, "
				 "[%s] "
                 ")",
				 this,
                 bFlag?"Success":"Fail"
                 );
    
    return bFlag;
}

void VideoDecoderH264::Pause() {
	FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "VideoDecoderH264::Pause( "
                "this : %p "
                ")",
                this
                );

    Stop();

	FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderH264::Pause( "
                "this : %p, "
                "[Success] "
                ")",
                this
                );
}

void VideoDecoderH264::ResetStream() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "VideoDecoderH264::ResetStream( "
                 "this : %p "
                 ")",
                 this
                 );
    
}
    
void VideoDecoderH264::ReleaseVideoFrame(void* frame) {
    VideoFrame* videoFrame = (VideoFrame *)frame;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "VideoDecoderH264::ReleaseVideoFrame( "
                 "this : %p, "
                 "videoFrame : %p, "
                 "timestamp : %u "
                 ")",
                 this,
                 videoFrame,
                 videoFrame->mTimestamp
                 );
    
    mFreeBufferList.lock();
    mFreeBufferList.push_back(videoFrame);
    mFreeBufferList.unlock();
    
}
    
bool VideoDecoderH264::Start() {
    bool bFlag = false;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::Start( "
                 "this : %p "
                 ")",
                 this
                 );
    
    mRuningMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    // 创建解码器
    bFlag = CreateContext();
    if( bFlag ) {
        mbRunning = true;
        
        VideoFrame* frame = NULL;
        mFreeBufferList.lock();
        for(int i = 0; i < DEFAULT_VIDEO_BUFFER_COUNT; i++) {
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
                 bFlag?"Success":"Fail"
                 );
    
    return bFlag;
}
    
void VideoDecoderH264::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "VideoDecoderH264::Stop( "
                 "this : %p "
                 ")",
                 this
                 );
    
    mRuningMutex.lock();
    if( mbRunning ) {
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
                 this
                 );
}
    
bool VideoDecoderH264::CreateContext() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "VideoDecoderH264::CreateContext( this : %p )", this);
    
    bool bFlag = true;
    avcodec_register_all();
//    av_log_set_level(AV_LOG_ERROR);
    
    mCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
    if ( !mCodec ) {
        // codec not found
    	FileLevelLog(
    			"rtmpdump",
				KLog::LOG_ERR_SYS,
                "VideoDecoderH264::CreateContext( "
				"this : %p, "
                "[Codec not found] "
                ")",
                this
                );
        
        bFlag = false;
    }
    
    if( bFlag ) {
        mContext = avcodec_alloc_context3(mCodec);
        if( (mCodec->capabilities & CODEC_CAP_TRUNCATED) ) {
            mContext->flags |= CODEC_FLAG_TRUNCATED;
        }
        
        AVDictionary* options = NULL;
//        av_dict_set(&options, "threads", "2", 0);
        
        if ( avcodec_open2(mContext, mCodec, &options) == 0 ) {
        	FileLevelLog(
        			"rtmpdump",
					KLog::LOG_MSG,
                    "VideoDecoderH264::CreateContext( "
					"this : %p, "
                    "[Codec opened] "
                    ")",
                    this
                    );
        } else {
        	FileLevelLog(
        			"rtmpdump",
					KLog::LOG_ERR_SYS,
                    "VideoDecoderH264::CreateContext( "
					"this : %p, "
                    "[Could not open codec] "
                    ")",
                    this
                    );
            bFlag = false;
        }
    }
    
    if( !bFlag ) {
        DestroyContext();
        
        FileLevelLog("rtmpdump",
                    KLog::LOG_ERR_SYS,
                    "VideoDecoderH264::CreateContext( "
					"this : %p, "
                    "[Fail] "
                    ")",
                    this
                    );
    }
    
    return bFlag;
}
    
void VideoDecoderH264::DestroyContext() {
    FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "VideoDecoderH264::DestroyContext( "
                "this : %p "
                ")",
                this
                );
    
    if( mContext ) {
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
    
void VideoDecoderH264::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int naluHeaderSize) {
	FileLog("rtmpdump",
			"VideoDecoderH264::DecodeVideoKeyFrame( "
			"this : %p, "
			"sps_size : %d, "
			"pps_size : %d "
			")",
			this,
			sps_size,
			pps_size
			);

	mNaluHeaderSize = naluHeaderSize;

	mSPS_PPS_IDR.SetBuffer(sync_bytes, sizeof(sync_bytes));
	mSPS_PPS_IDR.AddBuffer((const unsigned char*)sps, sps_size);

	mSPS_PPS_IDR.AddBuffer(sync_bytes, sizeof(sync_bytes));
	mSPS_PPS_IDR.AddBuffer((const unsigned char*)pps, pps_size);
}

void VideoDecoderH264::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
	mFreeBufferList.lock();
	VideoFrame* videoFrame = NULL;
	if( !mFreeBufferList.empty() ) {
		videoFrame = (VideoFrame *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		videoFrame = new VideoFrame();
        FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoDecoderH264::DecodeVideoFrame( this : %p, [New View Frame], frame : %p )", this, videoFrame);
	}
	mFreeBufferList.unlock();

    // 更新数据格式
	videoFrame->ResetFrame();
    videoFrame->mTimestamp = timestamp;
    videoFrame->mVideoType = video_type;
//    videoFrame->SetBuffer((const unsigned char*)data, size);
    
    // Mux
    Nalu naluArray[16];
    int naluArraySize = _countof(naluArray);
    bool bFlag = mVideoMuxer.GetNalus(data, size, mNaluHeaderSize, naluArray, naluArraySize);
    if( bFlag && naluArraySize > 0 ) {
        FileLevelLog("rtmpdump",
                     KLog::LOG_STAT,
                     "VideoDecoderH264::DecodeVideoFrame( "
					 "this : %p, "
                     "[Got Nalu Array], "
                     "timestamp : %u, "
                     "size : %d, "
                     "naluArraySize : %d "
                     ")",
					 this,
                     timestamp,
                     size,
                     naluArraySize
                     );
        
        int naluIndex = 0;
        while( naluIndex < naluArraySize ) {
            Nalu* nalu = naluArray + naluIndex;
            naluIndex++;
            
            FileLevelLog("rtmpdump",
                         KLog::LOG_STAT,
                         "VideoDecoderH264::DecodeVideoFrame( "
						 "this : %p,"
                         "[Got Nalu], "
                         "naluSize : %d, "
                         "naluBodySize : %d, "
                         "frameType : %d "
                         ")",
						 this,
                         nalu->GetNaluSize(),
                         nalu->GetNaluBodySize(),
                         nalu->GetNaluType()
                         );
            
            videoFrame->AddBuffer(sync_bytes, sizeof(sync_bytes));
            videoFrame->AddBuffer((const unsigned char*)nalu->GetNaluBody(), nalu->GetNaluBodySize());
        }
    }
    
    // 放进解码队列
    mDecodeBufferList.lock();
    mDecodeBufferList.push_back(videoFrame);
    mDecodeBufferList.unlock();
    
}

bool VideoDecoderH264::DecodeVideoFrame(VideoFrame* videoFrame, VideoFrame* newVideoFrame) {
    bool bFlag = false;

    long long curTime = getCurrentTime();
    
    const char* data = (const char *)videoFrame->GetBuffer();
    int size = videoFrame->mBufferLen;
    VideoFrameType video_type = videoFrame->mVideoType;
    
    if ( NULL != data &&
    		size > 0 &&
			NULL != newVideoFrame &&
			NULL != mContext ) {
		AVPacket packet = {0};
		av_init_packet(&packet);

		bool bGotPPS = false;
	    const char *frame = NULL;
	    int frameSize = 0;

		if( video_type == VFT_IDR && mSPS_PPS_IDR.mBufferLen > 0 ) {
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
                    "timestamp : %u, "
                    "frameSize : %d "
                    ")",
                    this,
                    newVideoFrame->mTimestamp,
                    frameSize
                    );
            
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

		packet.data = (uint8_t*)frame;
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

        AVFrame* pictureFrame = newVideoFrame->mpAVFrame;
		int useLen = avcodec_decode_video2(mContext, pictureFrame, &mGotPicture, &packet);
		if ( useLen >= 0 && mGotPicture ) {
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
					destSize
					);

		    // 更新帧参数
		    *newVideoFrame = *videoFrame;
		    newVideoFrame->mFormat = VIDEO_FORMATE_YUV420P;
		    newVideoFrame->mWidth = pictureFrame->width;
		    newVideoFrame->mHeight = pictureFrame->height;

			bFlag = true;
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
	                 "timestamp : %u, "
	                 "handleTime : %lld "
	                 ")",
	                 this,
	                 videoFrame,
					 newVideoFrame,
					 newVideoFrame->mTimestamp,
	                 handleTime
	                 );

		if( bGotPPS ) {
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
            this
            );
    
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
                 mFreeBufferList.size()
                 );
    
    // 释放解码Buffer
    VideoFrame* frame = NULL;
    
    mDecodeBufferList.lock();
    while( !mDecodeBufferList.empty() ) {
        frame = (VideoFrame* )mDecodeBufferList.front();
        mDecodeBufferList.pop_front();
        if( frame != NULL ) {
            delete frame;
        } else {
            break;
        }
    }
    mDecodeBufferList.unlock();
    
    // 释放转换Buffer
    mConvertBufferList.lock();
    while( !mConvertBufferList.empty() ) {
        frame = (VideoFrame* )mConvertBufferList.front();
        mConvertBufferList.pop_front();
        if( frame != NULL ) {
            delete frame;
        } else {
            break;
        }
    }
    mConvertBufferList.unlock();
    
    // 释放空闲Buffer
    mFreeBufferList.lock();
    while( !mFreeBufferList.empty() ) {
        frame = (VideoFrame* )mFreeBufferList.front();
        mFreeBufferList.pop_front();
        if( frame != NULL ) {
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
                this
                );
    
    VideoFrame* videoFrame = NULL;
    VideoFrame* decodedVideoFrame = NULL;
    
    // 开始解码帧时间戳
    unsigned int startTimestamp = 0;
    // 上一帧视频播放时间戳
    unsigned int preTimestamp = 0;
    // 当前帧时间
    unsigned int timestamp = 0;
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
    
    while ( mbRunning ) {
        bFlag = false;
        videoFrame = NULL;
        decodedVideoFrame = NULL;
        timestamp = 0;
        decodeTime = 0;
        
        mDecodeBufferList.lock();
        if( !mDecodeBufferList.empty() ) {
            videoFrame = (VideoFrame *)mDecodeBufferList.front();
            if( videoFrame ) {
                // 去除解码的Buffer
                mDecodeBufferList.pop_front();
                
                long long curTime = getCurrentTime();
                timestamp = videoFrame->mTimestamp;
                
                // 更新开始帧时间戳
                if( preTimestamp == 0 || preTimestamp >= videoFrame->mTimestamp ) {
                    FileLog("rtmpdump",
                            "VideoDecoderH264::DecodeVideoHandle( "
                    		"this : %p, "
                            "[Reset Start Timestamp], "
                            "startDecodeTime : %lld, "
                            "startTimestamp : %u, "
                            "preTimestamp : %u, "
                            "timestamp : %u "
                            ")",
                            this,
                            curTime,
                            startTimestamp,
                            preTimestamp,
                            videoFrame->mTimestamp
                            );
                    
                    startTimestamp = videoFrame->mTimestamp;
                    preTimestamp = videoFrame->mTimestamp;
                    
                    startDecodeTime = curTime;
                    decodeTotalTime = 0;
                    decodeTotalMS = 0;
                    
                    mDropFrameMutex.lock();
                    mbDropFrame = false;
                    mbWaitForInterFrame = true;
                    mDropFrameMutex.unlock();
                }
                
//                FileLog("rtmpdump",
//                        "VideoDecoderH264::DecodeVideoHandle( "
//                        "[Get Decode Frame], "
//                        "this : %p, "
//                        "videoFrame : %p, "
//                        "timestamp : %u, "
//                        "mbDropFrame : %s, "
//                        "bWaitForInterFrame : %s, "
//                        "videoType : %d, "
//                        "mDecodeBufferList size : %d "
//                        ")",
//                        this,
//                        videoFrame,
//                        timestamp,
//                        mbDropFrame?"true":"false",
//                        mbWaitForInterFrame?"true":"false",
//                        videoFrame->mVideoType,
//                        mDecodeBufferList.size()
//                        );
                
                bool bStartDecode = false;
                mDropFrameMutex.lock();
                if( mbDropFrame ) {
//                    if( mbWaitForInterFrame ) {
                        // 等待InterFrame
                        if( videoFrame->mVideoType == VFT_IDR ) {
                            mDropFrameMutex.lock();
                            mbWaitForInterFrame = false;
                            mbDropFrame = false;
                            mDropFrameMutex.unlock();
                            
                            bStartDecode = true;
                        }
                        
//                    } else {
//                        // 不用等待, 直接解码
//                        bStartDecode = true;
//                    }
                } else {
                    // 不用等待, 直接解码
                    bStartDecode = true;
                }
                mDropFrameMutex.unlock();
                
                if( bStartDecode ) {
                    // 真正解码
                    // 获取空闲Buffer
                    mFreeBufferList.lock();
                    if( !mFreeBufferList.empty() ) {
                        decodedVideoFrame = (VideoFrame *)mFreeBufferList.front();
                        mFreeBufferList.pop_front();
                    } else {
                        decodedVideoFrame = new VideoFrame();
                        FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoDecoderH264::DecodeVideoHandle( this : %p, [New View Frame], frame : %p )", this, decodedVideoFrame);
                    }
                    mFreeBufferList.unlock();
                    
                    bFlag = DecodeVideoFrame(videoFrame, decodedVideoFrame);
                }
                
                long long now = getCurrentTime();
                // 计算解码时间
                decodeTime = now - curTime;
                // 总帧时间差
                decodeTotalMS = videoFrame->mTimestamp - startTimestamp;
                // 总解码时间
                decodeTotalTime += decodeTime;//now - startDecodeTime;
                // 两帧时间差
//                int diffMS = videoFrame->mTimestamp - preTimestamp;
                
//                if( decodeTotalMS > 0 ) {
//                    bool bDropDecodeFrame = false;
//                    
//                    bDropDecodeFrame = (mDecodeBufferList.size() > 15);
//                    bDropDecodeFrame = (bDropDecodeFrame) && (decodeTotalTime > decodeTotalMS);
//                    
//                    mDropFrameMutex.lock();
//                    if( mbCanDropFrame && bDropDecodeFrame ) {
//                        // 总解码时间 > 总帧时间戳
//                        if( !mbDropFrame ) {
//                            // 开始丢帧
//                            mbDropFrame = true;
//                            mbWaitForInterFrame = true;
//                        }
//                    }
//                    mDropFrameMutex.unlock();
//                }
                
                if( bFlag ) {
                    // 解码成功
//                    FileLog("rtmpdump",
//                            "VideoDecoderH264::DecodeVideoHandle( "
//                            "[Decode Frame Finish], "
//                            "this : %p, "
//                            "timestamp : %u, "
//                            "decodeTime : %lld, "
//                            "decodeTotalTime : %lld, "
//                            "decodeTotalMS : %lld "
//                            ")",
//                            this,
//                            timestamp,
//                            decodeTime,
//                            decodeTotalTime,
//                            decodeTotalMS
//                            );
                } else {
                    // 直接丢帧
                    FileLog("rtmpdump",
                            "VideoDecoderH264::DecodeVideoHandle( "
                    		"this : %p, "
                            "[Drop Frame], "
                            "timestamp : %u, "
                            "decodeTime : %lld, "
                            "decodeTotalTime : %lld, "
                            "decodeTotalMS : %lld "
                            ")",
                            this,
                            timestamp,
                            decodeTime,
                            decodeTotalTime,
                            decodeTotalMS
                            );
                }

            }

            // 归还空闲Buffer
            ReleaseVideoFrame(videoFrame);
            
        } else {
            // 没有更多帧
        }
        mDecodeBufferList.unlock();
        
        if( bFlag && decodedVideoFrame ) {
            // 放到转换队列
            mConvertBufferList.lock();
            mConvertBufferList.push_back(decodedVideoFrame);
            mConvertBufferList.unlock();
            
        } else {
            // 归还没使用Buffer
            if( decodedVideoFrame ) {
                ReleaseVideoFrame(decodedVideoFrame);
                decodedVideoFrame = NULL;
            }
        }
        
        if( bSleep ) {
            Sleep(1);
        }
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoDecoderH264::DecodeVideoHandle( "
				"this : %,p "
                "[Exit] "
                ")",
                this
                );
}
    
void VideoDecoderH264::ConvertVideoHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                "VideoDecoderH264::ConvertVideoHandle( "
				"this : %p, "
                "[Start] "
                ")",
                this
                );
    
    VideoFrame* videoFrame = NULL;
    VideoFrame* displayFrame = NULL;
    // 当前帧时间
    unsigned int timestamp = 0;
    
    while ( mbRunning ) {
        videoFrame = NULL;
        
        mConvertBufferList.lock();
        if( !mConvertBufferList.empty() ) {
            videoFrame = (VideoFrame *)mConvertBufferList.front();
            if( videoFrame ) {
                // 去除解码的Buffer
                mConvertBufferList.pop_front();
            }
        } else {
            // 没有更多帧
        }
        mConvertBufferList.unlock();
        
        if( videoFrame ) {
            timestamp = videoFrame->mTimestamp;
            
//            FileLog("rtmpdump",
//                    "VideoDecoderH264::ConvertVideoHandle( "
//                    "[Get Frame], "
//                    "this : %p, "
//                    "videoFrame : %p, "
//                    "timestamp : %u, "
//                    "videoType : %d, "
//                    "mConvertBufferList size : %d "
//                    ")",
//                    this,
//                    videoFrame,
//                    timestamp,
//                    videoFrame->mVideoType,
//                    mConvertBufferList.size()
//                    );
            
            // 获取空闲Buffer
            mFreeBufferList.lock();
            if( !mFreeBufferList.empty() ) {
                displayFrame = (VideoFrame *)mFreeBufferList.front();
                mFreeBufferList.pop_front();
            } else {
                displayFrame = new VideoFrame();
                FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoDecoderH264::ConvertVideoHandle( this : %p, [New View Frame], frame : %p )", this, displayFrame);
            }
            mFreeBufferList.unlock();
            
            // 格式转换
            mVideoFormatConverter.ConvertFrame(videoFrame, displayFrame);
            
            // 回调播放
            if( mpCallback && displayFrame ) {
                // 放进播放器
                mpCallback->OnDecodeVideoFrame(this, displayFrame, displayFrame->mTimestamp);
                
            } else {
                // 归还没使用Buffer
                if( displayFrame ) {
                    ReleaseVideoFrame(displayFrame);
                    displayFrame = NULL;
                }
            }
            
            // 归还解码Buffer
            ReleaseVideoFrame(videoFrame);
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
