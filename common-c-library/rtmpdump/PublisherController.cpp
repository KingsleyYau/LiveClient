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
    mVideoTimestampSyncMod = 0;
    mVideoTimestampSyncTotal = 0;
    mVideoPause = false;
    mVideoResume = true;
    mVideoFramePauseTime = 0;
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

void PublisherController::SetVideoParam(int width, int height, int fps, int keyInterval) {
    mRtmpDump.SetVideoParam(width, height);

    mPublisherMutex.lock();
    mVideoFps = fps;
    if (fps > 0) {
        mVideoFrameInterval = 1000.0 / fps;
        mVideoTimestampSyncMod = 1000 % fps;
    }
    mPublisherMutex.unlock();
}

bool PublisherController::PublishUrl(const string &url, const string &recordH264FilePath, const string &recordAACFilePath) {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "PublisherController::PublishUrl( "
                 "this : %p "
                 "url : %s "
                 ")",
                 this,
                 url.c_str());

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

    // 复位帧率控制
    mPublisherMutex.lock();
    mVideoFrameStartPushTime = 0;
    mVideoFrameIndex = 0;
    mVideoFramePauseTime = 0;
    mVideoFrameLastPushTime = 0;
    mVideoTimestampSyncTotal = 0;
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
            // 更新上次暂停导致的时间差
            long long videoFrameDiffTime = now - mVideoFrameLastPushTime;
            videoFrameDiffTime -= mVideoFrameInterval;
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_WARNING,
                "PublisherController::PushVideoFrame( "
                "this : %p, "
                "[Video capture is resume], "
                "videoFrameDiffTime : %lld "
                ")",
                this,
                videoFrameDiffTime);
            mRtmpDump.AddVideoTimestamp((unsigned int)videoFrameDiffTime);
            mVideoFramePauseTime += videoFrameDiffTime;
        }

        // 控制帧率
        if (mVideoFrameStartPushTime == 0) {
            mVideoFrameStartPushTime = now;
        }
        long long diffTime = now - mVideoFrameStartPushTime;
        diffTime -= mVideoFramePauseTime;
        long long videoFrameInterval = diffTime - (mVideoFrameIndex * mVideoFrameInterval + mVideoTimestampSyncTotal);

        if (videoFrameInterval >= 0) {
            FileLevelLog(
                "rtmpdump",
                KLog::LOG_STAT,
                "PublisherController::PushVideoFrame( "
                "this : %p, "
                "[Video frame pushed], "
                "videoFrameInterval : %lld, "
                "diffTime : %lld, "
                "videoFrameIndex : %d "
                ")",
                this,
                videoFrameInterval,
                diffTime,
                mVideoFrameIndex);

            // 放到编码器
            if (mpVideoEncoder) {
                mpVideoEncoder->EncodeVideoFrame(data, size, frame);
            }

            // 更新最后处理帧数目
            mVideoFrameIndex++;
            // 更新最后处理时间
            mVideoFrameLastPushTime = now;
            // 处理时间戳余数
            if (mVideoTimestampSyncMod != 0) {
                if (mVideoFrameIndex % mVideoFps == 0) {
                    // 每秒同步余数
                    FileLevelLog(
                        "rtmpdump",
                        KLog::LOG_STAT,
                        "PublisherController::PushVideoFrame( "
                        "this : %p, "
                        "[Video ts sync], "
                        "mVideoTimestampSyncMod : %u, "
                        "videoFrameIndex : %d "
                        ")",
                        this,
                        mVideoTimestampSyncMod,
                        mVideoFrameIndex);
                    mVideoTimestampSyncTotal += mVideoTimestampSyncMod;
                }
            }
        }
    } else {
        FileLevelLog(
            "rtmpdump",
            KLog::LOG_WARNING,
            "PublisherController::PushVideoFrame( "
            "this : %p, "
            "[Video capture is pausing] "
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
void PublisherController::OnEncodeVideoFrame(VideoEncoder *encoder, char *data, int size, u_int32_t ts) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::OnEncodeVideoFrame( "
                 "this : %p, "
                 "frameType : 0x%02x, "
                 "ts : %u, "
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
    u_int32_t ts) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_STAT,
                 "PublisherController::OnEncodeAudioFrame( "
                 "this : %p, "
                 "ts : %u, "
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
/*********************************************** 传输器回调处理 End *****************************************************/

bool PublisherController::SendCmdLogin(const string& userName, const string& password, const string& siteId) {
    return mRtmpDump.SendCmdLogin(userName, password, siteId);
}

bool PublisherController::SendCmdMakeCall(const string& userName, const string& serverId, const string& siteId) {
    return mRtmpDump.SendCmdMakeCall(userName, serverId, siteId);
}

}
