//
//  PlayerController.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "PlayerController.h"

#include "video/VideoDecoderH264.h"
#include "audio/AudioDecoderAAC.h"

namespace coollive {
PlayerController::PlayerController() {
    mpVideoRenderer = NULL;
    mpAudioRenderer = NULL;
    
    mpVideoDecoder = NULL;
    mpAudioDecoder = NULL;

    mpPlayerStatusCallback = NULL;
    
    mUseHardDecoder = false;
    mbSkipDelayFrame = true;
    
    mbNeedResetAudioRenderer = false;
    
    mRtmpDump.SetCallback(this);
    mRtmpPlayer.SetRtmpDump(&mRtmpDump);
    mRtmpPlayer.SetCallback(this);
}

PlayerController::~PlayerController() {
}
 
void PlayerController::SetCacheMS(int cacheMS) {
    mRtmpPlayer.SetCacheMS(cacheMS);
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
        mpVideoDecoder = videDecoder;
    }
    
    if( mpVideoDecoder ) {
        mpVideoDecoder->Create(this);
    }
}
    
void PlayerController::SetAudioDecoder(AudioDecoder* audioDecoder) {
    if( mpAudioDecoder != audioDecoder ) {
        mpAudioDecoder = audioDecoder;
    }
    
    if( mpAudioDecoder ) {
        mpAudioDecoder->Create(this);
    }
}
    
void PlayerController::SetStatusCallback(PlayerStatusCallback* pc) {
    mpPlayerStatusCallback = pc;
}
    
bool PlayerController::PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath) {
    bool bFlag = true;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::PlayUrl( "
                 "this : %p, "
                 "url : %s "
                 ")",
                 this,
                 url.c_str()
                 );
    
    // 重置分析器
    mStatistics.Start();
    // 重置解码器
    if( bFlag ) {
        bFlag = mpVideoDecoder->Reset();
    }
    if( bFlag ) {
        bFlag = mpAudioDecoder->Reset();
    }
    // 重置音频播放器
    mpAudioRenderer->Start();
    // 开始播放
    if( bFlag ) {
        bFlag = mRtmpPlayer.PlayUrl(url, recordFilePath);
    }
    // 开始录制
    if( bFlag ) {
        mVideoRecorderH264.Start(recordH264FilePath);
        mAudioRecorderAAC.Start(recordAACFilePath);
    }
    if( bFlag ) {
        // 开始连接
        bFlag = mRtmpDump.PlayUrl(url, recordFilePath);
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::PlayUrl( "
                 "this : %p, "
                 "[%s], "
                 "url : %s "
                 ")",
                 this,
                 bFlag?"Success":"Fail",
                 url.c_str()
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
    
    // 停止分析
    mStatistics.Stop();
    // 停止网络
    mRtmpDump.Stop();
    // 停止解码
    if( mpVideoDecoder ) {
        mpVideoDecoder->Pause();
    }
    if( mpAudioDecoder ) {
        mpAudioDecoder->Pause();
    }
    // 停止播放
    mRtmpPlayer.Stop();
    // 停止录制
    mVideoRecorderH264.Stop();
    mAudioRecorderAAC.Stop();
    // 停止音频播放
    mpAudioRenderer->Stop();
    // 重置参数
    mbNeedResetAudioRenderer = false;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this
                 );
}

/*********************************************** 传输器回调处理 *****************************************************/
void PlayerController::OnConnect(RtmpDump* rtmpDump) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnConnect( "
                 "this : %p "
                 ")",
                 this
                 );
    if( mpPlayerStatusCallback ) {
        mpPlayerStatusCallback->OnPlayerConnect(this);
    }
}
    
void PlayerController::OnDisconnect(RtmpDump* rtmpDump) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnDisconnect( "
                 "this : %p "
                 ")",
                 this
                 );
    if( mpPlayerStatusCallback ) {
        mpPlayerStatusCallback->OnPlayerDisconnect(this);
    }
}

void PlayerController::OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnChangeVideoSpsPps( "
                 "this : %p, "
                 "sps_size : %d, "
                 "pps_size : %d, "
                 "nalUnitHeaderLength : %d "
                 ")",
                 this,
                 sps_size,
                 pps_size,
                 nalUnitHeaderLength
                 );
    // 录制视频帧
    mVideoRecorderH264.RecordVideoKeyFrame(sps, sps_size, pps, pps_size, nalUnitHeaderLength);
    
    // 解码视频帧
    if( mpVideoDecoder ) {
        mpVideoDecoder->DecodeVideoKeyFrame(sps, sps_size, pps, pps_size, nalUnitHeaderLength);
    }
}

void PlayerController::OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PlayerController::OnRecvVideoFrame( "
                 "this : %p, "
                 "timestamp : %u, "
                 "size : %d, "
                 "video_type : %d "
                 ")",
                 this,
                 timestamp,
                 size,
                 video_type
                 );
    // 增加分析处理
    mStatistics.AddVideoRecvFrame();
    
    // 录制视频帧
    mVideoRecorderH264.RecordVideoFrame(data, size);
    
    // 解码视频帧
    if( mpVideoDecoder ) {
        mpVideoDecoder->DecodeVideoFrame(data, size, timestamp, video_type);
    }
}

void PlayerController::OnChangeAudioFormat(RtmpDump* rtmpDump,
                                           AudioFrameFormat format,
                                           AudioFrameSoundRate sound_rate,
                                           AudioFrameSoundSize sound_size,
                                           AudioFrameSoundType sound_type
                                           ) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "PlayerController::OnChangeAudioFormat( "
                 "this : %p, "
                 "format : %d, "
                 "sound_rate : %d, "
                 "sound_size : %d, "
                 "sound_type : %d "
                 ")",
                 this,
                 format,
                 sound_rate,
                 sound_size,
                 sound_type
                 );
    // 录制音频帧
    mAudioRecorderAAC.ChangeAudioFormat(format, sound_rate, sound_size, sound_type);
    
    // 解码音频帧
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
                KLog::LOG_STAT,
                "PlayerController::OnRecvAudioFrame( "
                "this : %p, "
                "timestamp : %u, "
                "size : %d "
                ")",
                this,
                timestamp,
                size
                );
    // 增加分析处理
    mStatistics.AddAudioRecvFrame();
    
    // 录制音频帧
    mAudioRecorderAAC.RecordAudioFrame(data, size);
    
    // 解码音频帧
    if( mpAudioDecoder ) {
        mpAudioDecoder->DecodeAudioFrame(format, sound_rate, sound_size, sound_type, data, size, timestamp);
    }
}
/*********************************************** 传输器回调处理 End *****************************************************/
    
/*********************************************** 解码器回调处理 *****************************************************/
void PlayerController::OnDecodeVideoFrame(VideoDecoder* decoder, void* frame, u_int32_t timestamp) {
    // 播放视频帧
    mRtmpPlayer.PushVideoFrame(frame, timestamp);
}
    
void PlayerController::OnDecodeAudioFrame(AudioDecoder* decoder, void* frame, u_int32_t timestamp) {
    // 播放音频帧
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
    
    // 增加分析处理
    mStatistics.AddVideoPlayFrame();
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
    
    // 增加分析处理
    mStatistics.AddVideoPlayFrame();
}
    
void PlayerController::OnPlayAudioFrame(RtmpPlayer* player, void* frame) {
    if( mbNeedResetAudioRenderer ) {
        if( mpAudioRenderer ) {
            mpAudioRenderer->Reset();
        }
        mbNeedResetAudioRenderer = false;
    } else {
        if( mpAudioRenderer ) {
            mpAudioRenderer->RenderAudioFrame(frame);
        }
    }
    
    // 释放内存
    mpAudioDecoder->ReleaseAudioFrame(frame);
    
    // 增加分析处理
    mStatistics.AddAudioPlayFrame();
}
    
void PlayerController::OnDropAudioFrame(RtmpPlayer* player, void* frame) {
    // 标记需要重置
    mbNeedResetAudioRenderer = true;
    
    // 释放内存
    mpAudioDecoder->ReleaseAudioFrame(frame);
    
    // 增加分析处理
    mStatistics.AddAudioPlayFrame();
}
    
void PlayerController::OnResetVideoStream(RtmpPlayer* player) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnResetVideoStream( "
                 "this : %p "
                 ")",
                 this
                 );
}
    
void PlayerController::OnResetAudioStream(RtmpPlayer* player) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnResetAudioStream( "
                 "this : %p "
                 ")",
                 this
                 );
    
    // 标记需要重置
    mbNeedResetAudioRenderer = true;
//    if( mpAudioRenderer ) {
//        mpAudioRenderer->Reset();
//    }
}

void PlayerController::OnDelayMaxTime(RtmpPlayer* player) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PlayerController::OnDelayMaxTime( "
                 "this : %p "
                 ")",
                 this
                 );
    
    // 可以断开连接
    if( mpPlayerStatusCallback ) {
        mpPlayerStatusCallback->OnPlayerOnDelayMaxTime(this);
    }
}
/*********************************************** 播放器回调处理 End *****************************************************/

}
