/*
 * VideoDecoderImp.cpp
 *
 *  Created on: 2017年4月21日
 *      Author: max
 */

#include "VideoDecoderImp.h"

#include <rtmpdump/RtmpPlayer.h>

#include <common/KLog.h>

namespace coollive {
#define DEFAULT_VIDEO_BUFFER_SIZE 480 * 640 * 4
VideoDecoderImp::VideoDecoderImp() {
	// TODO Auto-generated constructor stub
    FileLog("rtmpdump", "VideoDecoderImp::VideoDecoderImp( decoder : %p )", this);
        
    mpCallback = NULL;

    VideoFrame* frame = NULL;
    mFreeBufferList.lock();
    for(int i = 0; i < 30; i++) {
        frame = new VideoFrame();
        frame->RenewBufferSize(DEFAULT_VIDEO_BUFFER_SIZE);
        mFreeBufferList.push_back(frame);
    }
    mFreeBufferList.unlock();
}

VideoDecoderImp::~VideoDecoderImp() {
	// TODO Auto-generated destructor stub
    FileLog("rtmpdump", "VideoDecoderImp::~VideoDecoderImp( decoder : %p )", this);
    
    Stop();
}

bool VideoDecoderImp::Create(VideoDecoderCallback* callback) {
	FileLevelLog("rtmpdump", KLog::LOG_WARNING, "VideoDecoderImp::Destroy( this : %p )", this);

    mpCallback = callback;

    bool bFlag = true;
	return bFlag;
}

void VideoDecoderImp::Reset() {
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderImp::Reset( "
                "this : %p "
                ")",
                this
                );

}

void VideoDecoderImp::Pause() {
	FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderImp::Pause( "
                "this : %p "
                ")",
                this
                );

}

void VideoDecoderImp::ResetStream() {
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderImp::ResetStream( "
                "this : %p "
                ")",
                this
                );
    
}
    
void VideoDecoderImp::ReleaseVideoFrame(void* frame) {
    VideoFrame* videoFrame = (VideoFrame *)frame;
    ReleaseBuffer(videoFrame);
}
    
void VideoDecoderImp::Stop() {
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderImp::Stop( "
                "this : %p "
                ")",
                this
                );
    
    VideoFrame* frame = NULL;

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
    
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "VideoDecoderImp::Stop( "
                "[Success], "
                "this : %p "
                ")",
                this
                );
}
    
void VideoDecoderImp::ReleaseBuffer(VideoFrame* videoFrame) {
//    FileLog("rtmpdump",
//            "VideoDecoderImp::ReleaseBuffer( "
//            "this : %p, "
//            "frame : %p, "
//            "timestamp : %u "
//            ")",
//            this,
//            videoFrame,
//            videoFrame->mTimestamp
//            );
    
	mFreeBufferList.lock();
	mFreeBufferList.push_back(videoFrame);
	mFreeBufferList.unlock();
}

void VideoDecoderImp::DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
	FileLog("rtmpdump",
			"VideoDecoderImp::DecodeVideoKeyFrame( "
			"sps_size : %d, "
			"pps_size : %d "
			")",
			sps_size,
			pps_size
			);
}

void VideoDecoderImp::DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
	mFreeBufferList.lock();
	VideoFrame* videoFrame = NULL;
	if( !mFreeBufferList.empty() ) {
		videoFrame = (VideoFrame *)mFreeBufferList.front();
		mFreeBufferList.pop_front();

	} else {
		videoFrame = new VideoFrame();
	}
	mFreeBufferList.unlock();

    // 更新数据格式
	videoFrame->ResetFrame();
    videoFrame->mTimestamp = timestamp;
    videoFrame->mVideoType = video_type;
    videoFrame->SetBuffer((const unsigned char*)data, size);
    
    // 回调播放
    if( mpCallback && videoFrame ) {
        // 放进播放器
        mpCallback->OnDecodeVideoFrame(this, videoFrame, videoFrame->mTimestamp);

    } else {
        // 归还没使用Buffer
        if( videoFrame ) {
            ReleaseBuffer(videoFrame);
            videoFrame = NULL;
        }
    }
}

void VideoDecoderImp::StartDropFrame() {
    FileLog("rtmpdump",
            "VideoDecoderImp::StartDropFrame( "
            "this : %p "
            ")",
            this
            );
}
}
