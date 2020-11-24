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

    mVideoFrameLastPushTime = 0;
    mVideoFrameStartPushTime = 0;
    mVideoFrameIndex = 0;
    mVideoFrameInterval = 0;
    mVideoFps = 0;

    mVideoPause = false;
    mVideoResume = true;
}

PublisherController::~PublisherController() {
}

void PublisherController::SetVideoEncoder(VideoEncoder *videoEncoder) {
    if (mpVideoEncoder != videoEncoder) {
        mpVideoEncoder = videoEncoder;
    }

    if (mpVideoEncoder) {
        mpVideoEncoder->SetCallback(this);
    }
}

void PublisherController::SetAudioEncoder(AudioEncoder *audioEncoder) {
    if (mpAudioEncoder != audioEncoder) {
        mpAudioEncoder = audioEncoder;
    }

    if (mpAudioEncoder) {
        mpAudioEncoder->SetCallback(this);
    }
}

void PublisherController::SetStatusCallback(PublisherStatusCallback *pc) {
    mpPublisherStatusCallback = pc;
}

bool PublisherController::SetVideoParam(int width, int height, int fps, int keyFrameInterval, int bitrate, VIDEO_FORMATE_TYPE type) {
    bool bFlag = false;
    
    mPublisherMutex.lock();
    mVideoFps = fps;
    if (fps > 0) {
        mVideoFrameInterval = 1000.0 / fps;
    }
    mRtmpDump.SetVideoParam(width, height);
    
    if (mpVideoEncoder) {
        bFlag = mpVideoEncoder->Create(width, height, fps, keyFrameInterval, bitrate, type);
    }
    mPublisherMutex.unlock();
    
    return bFlag;
}

bool PublisherController::PublishUrl(const string &url, const string &recordH264FilePath, const string &recordAACFilePath) {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::PublishUrl( "
                 "this : %p, "
                 "url : %s "
                 ")",
                 this,
                 url.c_str());

    mVideoFpsExact = mVideoFps;
    mVideoFrameIntervalExact = mVideoFrameInterval;
    
    // 开始发布
    bFlag = mRtmpPublisher.PublishUrl();
    // 开始编码
    if (bFlag) {
        bFlag = mpVideoEncoder->Reset();
    }
    if (bFlag) {
        bFlag = mpAudioEncoder->Reset();
    }
    if (bFlag) {
        // 开始连接
        bFlag = mRtmpDump.PublishUrl(url);
    }

    // 开始录制
    mVideoRecorderH264.Start(recordH264FilePath);
    mAudioRecorderAAC.Start(recordAACFilePath);

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::PublishUrl( "
                 "this : %p， "
                 "[%s], "
                 "url : %s "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail",
                 url.c_str());

    return bFlag;
}

void PublisherController::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::Stop( "
                 "this : %p "
                 ")",
                 this);

    // 停止连接
    mRtmpDump.Stop();
    // 停止发布
    mRtmpPublisher.Stop();
    if (mpVideoEncoder) {
        mpVideoEncoder->Pause();
    }
    if (mpAudioEncoder) {
        mpAudioEncoder->Pause();
    }
    mVideoRecorderH264.Stop();
    mAudioRecorderAAC.Stop();

    // 复位参数
    mPublisherMutex.lock();
    mVideoFrameStartPushTime = 0;
    mVideoFrameIndex = 0;
    mVideoFrameLastPushTime = 0;
    mVideoResume = true;
    mPublisherMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

void PublisherController::PushVideoFrame(void *data, int size, void *frame) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::PushVideoFrame( "
                 "frame : %p, "
                 "data : %p, "
                 "size : %d "
                 ")",
                 frame,
                 data,
                 size);

    mPublisherMutex.lock();
    // 视频是否暂停录制
    if (!mVideoPause) {
        long long now = getCurrentTime();

        // 视频是否恢复
        if (!mVideoResume) {
            // 视频未恢复
            mVideoResume = true;
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_WARNING,
                "PublisherController::PushVideoFrame( "
                "this : %p, "
                "[Video Capture Is Resume] "
                ")",
                this
                );
        }

        bool bPush = false;
        // 控制帧率
        if (mVideoFrameStartPushTime == 0) {
            mVideoFrameStartPushTime = now;
            bPush = true;
        }
        if (mVideoFrameLastPushTime == 0) {
            mVideoFrameLastPushTime = now;
            bPush = true;
        }
        
        long long diffTime = now - mVideoFrameStartPushTime;
        long long videoFrameInterval = now - mVideoFrameLastPushTime - mVideoFrameIntervalExact;
        if (!bPush) {
            bPush = (videoFrameInterval >= 0);
        }
        
        if (bPush) {
            FileLevelLog(
                         "rtmpdump",
                         KLog::LOG_MSG,
                         "PublisherController::PushVideoFrame( "
                         "this : %p, "
                         "[Video Frame Push], "
                         "diffTime : %lld, "
                         "videoFrameIndex : %d "
                         ")",
                         this,
                         diffTime,
                         mVideoFrameIndex
                         );

            // 放到编码器
            if (mpVideoEncoder) {
                VideoFrameRateType type = mpVideoEncoder->EncodeVideoFrame(data, size, frame, diffTime);
                if ( (type == VIDEO_FRAME_RATE_HOLD) || (type == VIDEO_FRAME_RATE_INC) ) {
                    // 更新最后处理帧数目
                    mVideoFrameIndex++;
                    // 更新最后处理时间
                    mVideoFrameLastPushTime = now;
                    
                    if ( type == VIDEO_FRAME_RATE_INC ) {
                        // 增加帧率
                        if ( mVideoFpsExact < mVideoFps ) {
                            mVideoFpsExact++;
                            mVideoFrameIntervalExact = 1000.0 / mVideoFpsExact;
                            
                            FileLevelLog(
                                         "rtmpdump",
                                         KLog::LOG_WARNING,
                                         "PublisherController::PushVideoFrame( "
                                         "this : %p, "
                                         "[Video Frame Rate Increase], "
                                         "mVideoFps : %d, "
                                         "mVideoFpsExact : %d, "
                                         "mVideoFrameIntervalExact : %d "
                                         ")",
                                         this,
                                         mVideoFps,
                                         mVideoFpsExact,
                                         mVideoFrameIntervalExact
                                         );
                        }
                    }
                    
                } else {
                    // 降低帧率
                    mVideoFpsExact--;
                    mVideoFpsExact = MAX(3, mVideoFpsExact);
                    mVideoFrameIntervalExact = 1000.0 / mVideoFpsExact;
                    
                    FileLevelLog(
                                 "rtmpdump",
                                 KLog::LOG_WARNING,
                                 "PublisherController::PushVideoFrame( "
                                 "this : %p, "
                                 "[Video Frame Rate Decrease], "
                                 "mVideoFps : %d, "
                                 "mVideoFpsExact : %d, "
                                 "mVideoFrameIntervalExact : %d "
                                 ")",
                                 this,
                                 mVideoFps,
                                 mVideoFpsExact,
                                 mVideoFrameIntervalExact
                                 );
                }
            }
        }
    } else {
        FileLevelLog(
            "rtmpdump",
            KLog::LOG_WARNING,
            "PublisherController::PushVideoFrame( "
            "this : %p, "
            "[Video Capture Is Pausing] "
            ")",
            this);
    }
    mPublisherMutex.unlock();
}

void PublisherController::PushAudioFrame(void *data, int size, void *frame) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::PushAudioFrame( "
                 "frame : %p, "
                 "data : %p, "
                 "size : %d "
                 ")",
                 frame,
                 data,
                 size);

    if (mpAudioEncoder) {
        mpAudioEncoder->EncodeAudioFrame(data, size, frame);
    }
}

void PublisherController::PausePushVideo() {
    FileLevelLog(
        "rtmpdump",
        KLog::LOG_WARNING,
        "PublisherController::PausePushVideo( "
        "this : %p "
        ")",
        this);
    mPublisherMutex.lock();
    mVideoPause = true;
    mVideoResume = false;
    mPublisherMutex.unlock();
}

void PublisherController::ResumePushVideo() {
    FileLevelLog(
        "rtmpdump",
        KLog::LOG_WARNING,
        "PublisherController::ResumePushVideo( "
        "this : %p "
        ")",
        this);
    mPublisherMutex.lock();
    mVideoPause = false;
    mPublisherMutex.unlock();
}

/*********************************************** 编码器回调处理 *****************************************************/
void PublisherController::OnEncodeVideoFrame(VideoEncoder *encoder, char *data, int size, int64_t ts) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::OnEncodeVideoFrame( "
                 "this : %p, "
                 "frameType : 0x%02x, "
                 "ts : %lld, "
                 "size : %d "
                 ")",
                 this,
                 data[0],
                 ts,
                 size);

    // 录制视频帧
    mVideoRecorderH264.RecordVideoNaluFrame(data, size);

    // 发送视频帧
    mRtmpPublisher.SendVideoFrame(data, size, ts);
}

void PublisherController::OnEncodeAudioFrame(
    AudioEncoder *encoder,
    AudioFrameFormat format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type,
    char *frame,
    int size,
    int64_t ts) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::OnEncodeAudioFrame( "
                 "this : %p, "
                 "ts : %lld, "
                 "size : %d "
                 ")",
                 this,
                 ts,
                 size);

    // 录制音频帧
    mAudioRecorderAAC.ChangeAudioFormat(format, sound_rate, sound_size, sound_type);
    mAudioRecorderAAC.RecordAudioFrame(frame, size);

    // 发送音频帧
    mRtmpPublisher.SendAudioFrame(format, sound_rate, sound_size, sound_type, frame, size, ts);
}

/*********************************************** 编码器回调处理 End *****************************************************/

/*********************************************** 传输器回调处理 *****************************************************/
void PublisherController::OnConnect(RtmpDump *rtmpDump) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnConnect( this : %p )",
                 this);
    if (mpPublisherStatusCallback) {
        mpPublisherStatusCallback->OnPublisherConnect(this);
    }
}

void PublisherController::OnDisconnect(RtmpDump *rtmpDump) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnDisconnect( this : %p )",
                 this);
    if (mpPublisherStatusCallback) {
        mpPublisherStatusCallback->OnPublisherDisconnect(this);
    }
}

void PublisherController::OnChangeVideoSpsPps(RtmpDump *rtmpDump, const char *sps, int sps_size, const char *pps, int pps_size, int naluHeaderSize, u_int32_t ts) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnChangeVideoSpsPps( "
                 "this : %p, "
                 "sps_size : %d, "
                 "pps_size : %d, "
                 "naluHeaderSize : %d, "
				 "ts : %u"
                 ")",
                 this,
                 sps_size,
                 pps_size,
                 naluHeaderSize,
				 ts
				 );
}

void PublisherController::OnRecvVideoFrame(RtmpDump *rtmpDump, const char *data, int size, u_int32_t pts, u_int32_t dts, VideoFrameType video_type) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "PublisherController::OnRecvVideoFrame( "
                 "this : %p, "
                 "pts : %u, "
                 "dts : %u "
                 ")",
                 this,
                 pts,
                 dts);
}

void PublisherController::OnChangeAudioFormat(
    RtmpDump *rtmpDump,
    AudioFrameFormat format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnChangeAudioFormat( "
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
                 sound_type);
}

void PublisherController::OnRecvAudioFrame(
    RtmpDump *rtmpDump,
    AudioFrameFormat format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type,
    char *data,
    int size,
    u_int32_t ts) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "PublisherController::OnRecvAudioFrame( "
                 "this : %p, "
                 "ts : %u "
                 ")",
                 this,
                 ts);
}

void PublisherController::OnRecvCmdLogin(RtmpDump *rtmpDump,
                                         bool bFlag,
                                         const string &userName,
                                         const string &serverAddress) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "PublisherController::OnRecvCmdLogin( "
                 "this : %p, "
                 "userName : %s, "
                 "serverAddress : %s "
                 ")",
                 this,
                 userName.c_str(),
                 serverAddress.c_str());
}

void PublisherController::OnRecvCmdMakeCall(RtmpDump *rtmpDump,
                                            const string &uuId,
                                            const string &userName) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "PublisherController::OnRecvCmdMakeCall( "
                 "this : %p, "
                 "uuId : %s, "
                 "userName : %s "
                 ")",
                 this,
                 uuId.c_str(),
                 userName.c_str());
}

void PublisherController::OnRecvStatusError(RtmpDump *rtmpDump,
                                         const string &code,
                                         const string &description) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::OnRecvStatusError( "
                 "this : %p, "
                 "code : %s, "
                 "description : %s "
                 ")",
                 this,
                 code.c_str(),
                 description.c_str());
    
    // 可以断开连接
    if (mpPublisherStatusCallback) {
        mpPublisherStatusCallback->OnPublisherError(this, code, description);
    }
}
/*********************************************** 传输器回调处理 End *****************************************************/

bool PublisherController::SendCmdLogin(const string& userName, const string& password, const string& siteId) {
    return mRtmpDump.SendCmdLogin(userName, password, siteId);
}

bool PublisherController::SendCmdMakeCall(const string& userName, const string& serverId, const string& siteId) {
    return mRtmpDump.SendCmdMakeCall(userName, serverId, siteId);
}

}
