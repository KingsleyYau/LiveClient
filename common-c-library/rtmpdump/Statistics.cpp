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
    :mStatusMutex(KMutex::MutexType_Recursive)
    {
    mVideoRecvFrameCount = 0;
    mVideoPlayFrameCount = 0;
    mAudioRecvFrameCount = 0;
    mAudioPlayFrameCount = 0;
}
    
Statistics::~Statistics() {
    
}
    
void Statistics::Start() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "Statistics::Start()"
                 );
    
    mStatusMutex.lock();
    mbRunning = true;
    mVideoRecvFrameCount = 0;
    mVideoPlayFrameCount = 0;
    mAudioRecvFrameCount = 0;
    mAudioPlayFrameCount = 0;
    mStatusMutex.unlock();
}
    
void Statistics::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "Statistics::Stop()"
                 );
    
    mStatusMutex.lock();
    mbRunning = false;
    mVideoRecvFrameCount = 0;
    mVideoPlayFrameCount = 0;
    mAudioRecvFrameCount = 0;
    mAudioPlayFrameCount = 0;
    mStatusMutex.unlock();
}

void Statistics::AddVideoRecvFrame() {
    mStatusMutex.lock();
    mVideoRecvFrameCount++;
    mStatusMutex.unlock();
    
    // 不需要准确
    while( mbRunning && !CanRecvVideo() ) {
        // 等待帧播放
        Sleep(100);
    }
}

void Statistics::AddVideoPlayFrame() {
    mStatusMutex.lock();
    mVideoPlayFrameCount++;
    mStatusMutex.unlock();
}

void Statistics::AddAudioRecvFrame() {
    mStatusMutex.lock();
    mAudioRecvFrameCount++;
    mStatusMutex.unlock();
    
    // 不需要准确
    while( mbRunning && !CanRecvAudio() ) {
        // 等待帧播放
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
    
bool Statistics::CanRecvVideo() {
    bool bFlag = true;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "Statistics::CanRecvVideo( "
                 "videoFrameCount : %d "
                 ")",
                 mVideoRecvFrameCount - mVideoPlayFrameCount
                 );
    
    if( mVideoRecvFrameCount - mVideoPlayFrameCount >= 90 ) {
        bFlag = false;
    }
    
    return bFlag;
}
    
bool Statistics::CanRecvAudio() {
    bool bFlag = true;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "Statistics::CanRecvAudio( "
                 "audioFrameCount : %d "
                 ")",
                 mAudioRecvFrameCount - mAudioPlayFrameCount
                 );
    
    if( mAudioRecvFrameCount - mAudioPlayFrameCount >= 150 ) {
        bFlag = false;
    }
    
    return bFlag;
}
    
}
