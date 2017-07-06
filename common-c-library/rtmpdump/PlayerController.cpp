//
//  PlayerController.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "PlayerController.h"

#include "VideoDecoderH264.h"
#include "AudioDecoderAAC.h"

namespace coollive {
PlayerController::PlayerController() {
    mpVideoRenderer = NULL;
    mpAudioRenderer = NULL;
    
    mpVideoDecoder = NULL;
    mpAudioDecoder = NULL;

    mpPlayerStatusCallback = NULL;
    
    mUseHardDecoder = false;
    mbSkipDelayFrame = true;
    
    mRtmpDump.SetCallback(this);
    mRtmpPlayer.SetRtmpDump(&mRtmpDump);
    mRtmpPlayer.SetCallback(this);
}

PlayerController::~PlayerController() {
    Stop();
}
 
void PlayerController::SetVideoRenderer(VideoRenderer* videoRenderer) {
    mpVideoRenderer = videoRenderer;
    if( mpVideoRenderer != videoRenderer ) {
        mpVideoRenderer = videoRenderer;
    }
    
}

void PlayerController::SetAudioRenderer(AudioRenderer* audioRenderer) {
    mpAudioRenderer = audioRenderer;
}
    
void PlayerController::SetVideoDecoder(VideoDecoder* videDecoder) {
    if( mpVideoDecoder != videDecoder ) {
        if( mpVideoDecoder ) {
            mpVideoDecoder->Pause();
        }
        
        mpVideoDecoder = videDecoder;
        mpVideoDecoder->Create(this);
    }
}
    
void PlayerController::SetAudioDecoder(AudioDecoder* audioDecoder) {
    if( mpAudioDecoder != audioDecoder ) {
        if( mpAudioDecoder ) {
            mpAudioDecoder->Destroy();
        }
        
        mpAudioDecoder = audioDecoder;
        mpAudioDecoder->Create(this);
    }
}
    
void PlayerController::SetStatusCallback(PlayerStatusCallback* pc) {
    mpPlayerStatusCallback = pc;
}
    
bool PlayerController::PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath) {
    bool bFlag = false;
    
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "PlayerController::PlayUrl( "
                "url : %s "
                ")",
                url.c_str()
                );
    
    // 开始播放
    bFlag = mRtmpPlayer.PlayUrl(url, recordFilePath, recordH264FilePath, recordAACFilePath);
    
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "PlayerController::PlayUrl( "
                "[Finish], "
                "url : %s, "
                "bFlag : %s "
                ")",
                url.c_str(),
                bFlag?"true":"false"
                );
    
    return bFlag;
}
    
void PlayerController::Stop() {
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "PlayerController::Stop( "
                "this : %p "
                ")",
                this
                );
    
    // 停止播放
    mRtmpPlayer.Stop();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::Stop( "
                 "[Finish], "
                 "this : %p "
                 ")",
                 this
                 );
}

/*********************************************** 传输器回调处理 *****************************************************/
void PlayerController::OnDisconnect(RtmpDump* rtmpDump) {
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "PlayerController::OnDisconnect()"
                );
    if( mpPlayerStatusCallback ) {
        mpPlayerStatusCallback->OnPlayerDisconnect(this);
    }
}

void PlayerController::OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    FileLevelLog("rtmpdump",
                KLog::LOG_WARNING,
                "PlayerController::OnChangeVideoSpsPps( "
                "sps_size : %d, "
                "pps_size : %d, "
                "nalUnitHeaderLength : %d "
                ")",
                sps_size,
                pps_size,
                nalUnitHeaderLength
                );
    if( mpVideoDecoder ) {
        mpVideoDecoder->DecodeVideoKeyFrame(sps, sps_size, pps, pps_size, nalUnitHeaderLength);
    }
}

void PlayerController::OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
    FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "PlayerController::OnRecvVideoFrame( "
                "[Start], "
                "timestamp : %u "
                ")",
                timestamp
                );
    
    // 解码一帧
    if( mpVideoDecoder ) {
        mpVideoDecoder->DecodeVideoFrame(data, size, timestamp, video_type);
    }

//    FileLog("rtmpdump",
//            "PlayerController::OnRecvVideoFrame( "
//            "[End], "
//            "timestamp : %u "
//            ")",
//            timestamp
//            );
}

void PlayerController::OnChangeAudioFormat(RtmpDump* rtmpDump,
                                     AudioFrameFormat format,
                                     AudioFrameSoundRate sound_rate,
                                     AudioFrameSoundSize sound_size,
                                     AudioFrameSoundType sound_type
                                     ) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnChangeAudioFormat( "
                 "format : %d, "
                 "sound_rate : %d, "
                 "sound_size : %d, "
                 "sound_type : %d "
                 ")",
                 format,
                 sound_rate,
                 sound_size,
                 sound_type
                 );
    
    if( mpAudioDecoder ) {
        mpAudioDecoder->DecodeAudioFormat(format, sound_rate, sound_size, sound_type);
    }

}

void PlayerController::OnRecvAudioFrame(
                                  RtmpDump* rtmpDump,
                                  AudioFrameFormat format,
                                  AudioFrameSoundRate sound_rate,
                                  AudioFrameSoundSize sound_size,
                                  AudioFrameSoundType sound_type,
                                  char* data,
                                  int size,
                                  u_int32_t timestamp
                                  ) {
    FileLevelLog("rtmpdump",
                KLog::LOG_MSG,
                "PlayerController::OnRecvAudioFrame( "
                "[Start], "
                "timestamp : %u "
                ")",
                timestamp
                );
//    long long curTime = getCurrentTime();
    
    // 解码一帧
    if( mpAudioDecoder ) {
        mpAudioDecoder->DecodeAudioFrame(format, sound_rate, sound_size, sound_type, data, size, timestamp);
    }
    
//    long long diff = getCurrentTime() - curTime;
//    FileLog("rtmpdump",
//            "PlayerController::OnRecvAudioFrame( "
//            "[End], "
//            "time : %lld, "
//            "timestamp : %u "
//            ")",
//            diff,
//            timestamp
//            );
}
/*********************************************** 传输器回调处理 End *****************************************************/
    
/*********************************************** 解码器回调处理 *****************************************************/
void PlayerController::OnDecodeVideoFrame(VideoDecoder* decoder, void* frame, u_int32_t timestamp) {
    mRtmpPlayer.PushVideoFrame(frame, timestamp);
}
    
void PlayerController::OnDecodeAudioFrame(AudioDecoder* decoder, void* frame, u_int32_t timestamp) {
    mRtmpPlayer.PushAudioFrame(frame, timestamp);
}
/*********************************************** 解码器回调处理 End *****************************************************/
    
/*********************************************** 播放器回调处理 *****************************************************/
void PlayerController::OnPlayVideoFrame(RtmpPlayer* player, void* frame) {   
    if( mpVideoRenderer ) {
        mpVideoRenderer->RenderVideoFrame(frame);
    }

    // 释放内存
    mpVideoDecoder->ReleaseVideoFrame(frame);
}
    
void PlayerController::OnDropVideoFrame(RtmpPlayer* player, void* frame) {
    if( mbSkipDelayFrame ) {
        // 需要丢的帧不显示, 效果为[瞬间移动]
        
    } else {
        // 需要丢的帧照样显示, 效果为[快速播放]
        if( mpVideoRenderer ) {
            mpVideoRenderer->RenderVideoFrame(frame);
        }
    }
    
    // 释放内存
    mpVideoDecoder->ReleaseVideoFrame(frame);
}
    
void PlayerController::OnPlayAudioFrame(RtmpPlayer* player, void* frame) {
    if( mpAudioRenderer ) {
        mpAudioRenderer->RenderAudioFrame(frame);
    }
    
    // 释放内存
    mpAudioDecoder->ReleaseAudioFrame(frame);
}
    
void PlayerController::OnDropAudioFrame(RtmpPlayer* player, void* frame) {
    if( mpAudioRenderer ) {
//        mpAudioRenderer->Reset();
    }
    
    // 释放内存
    mpAudioDecoder->ReleaseAudioFrame(frame);
}
    
void PlayerController::OnResetVideoStream(RtmpPlayer* player) {
    
}
    
void PlayerController::OnResetAudioStream(RtmpPlayer* player) {
    if( mpAudioRenderer ) {
        mpAudioRenderer->Reset();
    }
}

/*********************************************** 播放器回调处理 End *****************************************************/

}
