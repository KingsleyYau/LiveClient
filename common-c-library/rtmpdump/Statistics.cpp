//
//  Statistics.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "Statistics.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

namespace coollive {
Statistics::Statistics()
    : mStatusMutex(KMutex::MutexType_Recursive) {
    mVideoRecvFrameCount = 0;
    mVideoPlayFrameCount = 0;
    mAudioRecvFrameCount = 0;
    mAudioPlayFrameCount = 0;
}

Statistics::~Statistics() {
}

void Statistics::Start() {
    //    FileLevelLog("rtmpdump",
    //                 KLog::LOG_WARNING,
    //                 "Statistics::Start()"
    //                 );

    mStatusMutex.lock();
    mbRunning = true;
    mVideoRecvFrameCount = 0;
    mVideoPlayFrameCount = 0;
    mAudioRecvFrameCount = 0;
    mAudioPlayFrameCount = 0;
    
    mVideoPlayFrameCountPre = 0;
    mFpsTime = 0;
    mFps = 0;
    
    mVideoRecvBytesPre = 0;
    mVideoRecvBytes = 0;
    mVideoBytesTime = 0;
    mBitrate = 0;
    mStatusMutex.unlock();
}

void Statistics::Stop() {
    //    FileLevelLog("rtmpdump",
    //                 KLog::LOG_WARNING,
    //                 "Statistics::Stop()"
    //                 );

    mStatusMutex.lock();
    mbRunning = false;
    mVideoRecvFrameCount = 0;
    mVideoPlayFrameCount = 0;
    mAudioRecvFrameCount = 0;
    mAudioPlayFrameCount = 0;
    mStatusMutex.unlock();
}

bool Statistics::AddVideoRecvFrame(int size) {
    bool bFlag = false;
    
    mStatusMutex.lock();
    mVideoRecvFrameCount++;
    
    mVideoRecvBytes += size;
    long long now = (long long)getCurrentTime();
    if ( mVideoBytesTime == 0 ) {
        mVideoBytesTime = now;
    }
    if ( now - mVideoBytesTime > 1000 ) {
        mBitrate = 8.0 * (mVideoRecvBytes - mVideoRecvBytesPre) / 1000;
        mVideoRecvBytesPre = mVideoRecvBytes;
        mVideoBytesTime = now;
        bFlag = true;
    }
    
    mStatusMutex.unlock();

    if (!CanRecvAudio() && !CanRecvVideo()) {
        Sleep(100);
    }
    
    return bFlag;
}

bool Statistics::AddVideoPlayFrame() {
    bool bFlag = false;
    
    mStatusMutex.lock();
    mVideoPlayFrameCount++;
    
    long long now = (long long)getCurrentTime();
    if ( mFpsTime == 0 ) {
        mFpsTime = now;
    }
    if ( now - mFpsTime > 1000 ) {
        mFps = mVideoPlayFrameCount - mVideoPlayFrameCountPre;
        mVideoPlayFrameCountPre = mVideoPlayFrameCount;
        mFpsTime = now;
        bFlag = true;
    }
    
    mStatusMutex.unlock();
    
    return bFlag;
}

void Statistics::AddAudioRecvFrame() {
    mStatusMutex.lock();
    mAudioRecvFrameCount++;
    mStatusMutex.unlock();

    if (!CanRecvAudio() && !CanRecvVideo()) {
        Sleep(100);
    }
}

void Statistics::AddAudioPlayFrame() {
    mStatusMutex.lock();
    mAudioPlayFrameCount++;
    mStatusMutex.unlock();
}

bool Statistics::IsDropVideoFrame() {
    bool bFlag = false;
    return bFlag;
}

int Statistics::IsDisconnect() {
    bool bFlag = false;

    if (mVideoRecvFrameCount - mVideoPlayFrameCount >= 720) {
        bFlag = true;
    }

    if (mAudioRecvFrameCount - mAudioPlayFrameCount >= 1200) {
        bFlag = true;
    }

    return bFlag;
}

bool Statistics::CanRecvVideo() {
    bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "Statistics::CanRecvVideo( "
                 "videoFrameCount : %d "
                 ")",
                 mVideoRecvFrameCount - mVideoPlayFrameCount);

    mStatusMutex.lock();
    if (mbRunning && mVideoRecvFrameCount - mVideoPlayFrameCount >= 360) {
        bFlag = false;
    }
    mStatusMutex.unlock();

    return bFlag;
}

bool Statistics::CanRecvAudio() {
    bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "Statistics::CanRecvAudio( "
                 "audioFrameCount : %d "
                 ")",
                 mAudioRecvFrameCount - mAudioPlayFrameCount);

    mStatusMutex.lock();
    if (mbRunning && mAudioRecvFrameCount - mAudioPlayFrameCount >= 600) {
        bFlag = false;
    }
    mStatusMutex.unlock();

    return bFlag;
}

unsigned int Statistics::Fps() {
    return mFps;
}

unsigned int Statistics::Bitrate() {
    return mBitrate;
}
}
