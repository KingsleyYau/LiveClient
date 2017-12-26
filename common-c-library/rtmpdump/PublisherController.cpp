//
//  PublisherController.cpp
//  RtmpClient
//
//  Created by Max on 2017/7/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "PublisherController.h"

namespace coollive {

PublisherController::PublisherController() {
    mpVideoEncoder = NULL;
    mpAudioEncoder = NULL;
    mpPublisherStatusCallback = NULL;
    
    mRtmpDump.SetCallback(this);
    mRtmpPublisher.SetRtmpDump(&mRtmpDump);
}

PublisherController::~PublisherController() {
    
}

void PublisherController::SetVideoEncoder(VideoEncoder* videoEncoder) {
    if( mpVideoEncoder != videoEncoder ) {
        mpVideoEncoder = videoEncoder;
    }
    
    if( mpVideoEncoder ) {
        mpVideoEncoder->SetCallback(this);
    }
}

void PublisherController::SetAudioEncoder(AudioEncoder* audioEncoder) {
    if( mpAudioEncoder != audioEncoder ) {
        mpAudioEncoder = audioEncoder;
    }
    
    if( mpAudioEncoder ) {
        mpAudioEncoder->SetCallback(this);
    }
}

void PublisherController::SetStatusCallback(PublisherStatusCallback* pc) {
    mpPublisherStatusCallback = pc;
}
    
void PublisherController::SetVideoParam(int width, int height) {
    mRtmpDump.SetVideoParam(width, height);
}
    
bool PublisherController::PublishUrl(const string& url, const string& recordH264FilePath, const string& recordAACFilePath) {
    bool bFlag = false;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::PublishUrl( "
                 "url : %s "
                 ")",
                 url.c_str()
                 );
    
    // 开始发布
    bFlag = mRtmpPublisher.PublishUrl(url);
    // 开始编码
    if( bFlag ) {
        bFlag = mpVideoEncoder->Reset();
    }
    if( bFlag ) {
        bFlag = mpAudioEncoder->Reset();
    }
    
    // 开始录制
    mVideoRecorderH264.Start(recordH264FilePath);
    mAudioRecorderAAC.Start(recordAACFilePath);
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::PublishUrl( "
                 "[%s], "
                 "url : %s "
                 ")",
                 bFlag?"Success":"Fail",
                 url.c_str()
                 );
    
    return bFlag;
}
    
void PublisherController::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::Stop( "
                 "this : %p "
                 ")",
                 this
                 );
    
    // 停止发布
    mRtmpPublisher.Stop();
    if( mpVideoEncoder ) {
        mpVideoEncoder->Pause();
    }
    if( mpAudioEncoder ) {
        mpAudioEncoder->Pause();
    }
    mVideoRecorderH264.Stop();
    mAudioRecorderAAC.Stop();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::Stop( "
                 "[Success], "
                 "this : %p "
                 ")",
                 this
                 );
}
   
void PublisherController::PushVideoFrame(void* data, int size, void* frame) {
//    FileLevelLog("rtmpdump",
//                 KLog::LOG_MSG,
//                 "PublisherController::PushVideoFrame( "
//                 "data : %p, "
//                 "size : %d, "
//                 "frame : %p "
//                 ")",
//                 data,
//                 size,
//                 frame
//                 );
    
    if( mpVideoEncoder ) {
        mpVideoEncoder->EncodeVideoFrame(data, size, frame);
    }
}

void PublisherController::PushAudioFrame(void* data, int size, void* frame) {
//    FileLevelLog("rtmpdump",
//                 KLog::LOG_MSG,
//                 "PublisherController::PushAudioFrame( "
//                 "data : %p, "
//                 "size : %d, "
//                 "frame : %p "
//                 ")",
//                 data,
//                 size,
//                 frame
//                 );
    
    if( mpAudioEncoder ) {
        mpAudioEncoder->EncodeAudioFrame(data, size, frame);
    }
}

void PublisherController::AddVideoBackgroundTime(u_int32_t timestamp) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::AddVideoBackgroundTime( "
                 "timestamp : %u "
                 ")",
                 timestamp
                 );
    
    mRtmpDump.AddVideoTimestamp(timestamp);
}

/*********************************************** 编码器回调处理 *****************************************************/
void PublisherController::OnEncodeVideoFrame(VideoEncoder* encoder, char* data, int size, u_int32_t timestamp) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::OnEncodeVideoFrame( "
                 "timestamp : %u, "
                 "size : %d, "
                 "frameType : 0x%x "
                 ")",
                 timestamp,
                 size,
                 data[0]
                 );
    
    // 录制视频帧
    mVideoRecorderH264.RecordVideoNaluFrame(data, size);
    
    // 发送视频帧
    mRtmpPublisher.SendVideoFrame(data, size, timestamp);
}
    
void PublisherController::OnEncodeAudioFrame(
                                             AudioEncoder* encoder,
                                             AudioFrameFormat format,
                                             AudioFrameSoundRate sound_rate,
                                             AudioFrameSoundSize sound_size,
                                             AudioFrameSoundType sound_type,
                                             char* frame,
                                             int size,
                                             u_int32_t timestamp
                                             ) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::OnEncodeAudioFrame( "
                 "timestamp : %u, "
                 "size : %d "
                 ")",
                 timestamp,
                 size
                 );
    // 录制音频帧
    mAudioRecorderAAC.ChangeAudioFormat(format, sound_rate, sound_size, sound_type);
    mAudioRecorderAAC.RecordAudioFrame(frame, size);
    
    // 发送音频帧
    mRtmpPublisher.SendAudioFrame(format, sound_rate, sound_size, sound_type, frame, size, timestamp);
}

/*********************************************** 编码器回调处理 End *****************************************************/
    
/*********************************************** 传输器回调处理 *****************************************************/
void PublisherController::OnConnect(RtmpDump* rtmpDump) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnConnect()"
                 );
    if( mpPublisherStatusCallback ) {
        mpPublisherStatusCallback->OnPublisherConnect(this);
    }
}

void PublisherController::OnDisconnect(RtmpDump* rtmpDump) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnDisconnect()"
                 );
    if( mpPublisherStatusCallback ) {
        mpPublisherStatusCallback->OnPublisherDisconnect(this);
    }
}
    
void PublisherController::OnChangeVideoSpsPps(RtmpDump* rtmpDump, const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnChangeVideoSpsPps( "
                 "sps_size : %d, "
                 "pps_size : %d, "
                 "nalUnitHeaderLength : %d "
                 ")",
                 sps_size,
                 pps_size,
                 nalUnitHeaderLength
                 );
}

void PublisherController::OnRecvVideoFrame(RtmpDump* rtmpDump, const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "PublisherController::OnRecvVideoFrame( "
                 "timestamp : %u "
                 ")",
                 timestamp
                 );
}

void PublisherController::OnChangeAudioFormat(
                                              RtmpDump* rtmpDump,
                                              AudioFrameFormat format,
                                              AudioFrameSoundRate sound_rate,
                                              AudioFrameSoundSize sound_size,
                                              AudioFrameSoundType sound_type
                                              ) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnChangeAudioFormat( "
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
}

void PublisherController::OnRecvAudioFrame(
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
                 "PublisherController::OnRecvAudioFrame( "
                 "timestamp : %u "
                 ")",
                 timestamp
                 );
}
/*********************************************** 传输器回调处理 End *****************************************************/
    
}
