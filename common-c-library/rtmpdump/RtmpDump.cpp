//
//  RtmpDump.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpDump.h"

#include <common/CommonFunc.h>
#include <common/md5.h>

#include <sys/time.h>

#include <netdb.h>
#include <netinet/tcp.h>
#include <netinet/in.h>

#include <srs/srs_librtmp.h>

#define DEFAULT_VIDEO_FRAME_SIZE 65535
#define DEFAULT_AUDIO_FRAME_SIZE DEFAULT_VIDEO_FRAME_SIZE

#define ADTS_HEADER_SIZE 7

namespace coollive {
class RecvRunnable : public KRunnable {
  public:
    RecvRunnable(RtmpDump *container) {
        mContainer = container;
    }
    virtual ~RecvRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->RecvRunnableHandle();
    }

  private:
    RtmpDump *mContainer;
};

class CheckConnectRunnable : public KRunnable {
  public:
    CheckConnectRunnable(RtmpDump *container) {
        mContainer = container;
    }
    virtual ~CheckConnectRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->CheckConnectRunnableHandle();
    }

  private:
    RtmpDump *mContainer;
};

void RtmpDump::GobalInit() {
    FileLog("rtmpdump", "RtmpDump::GobalInit( Example for srs-librtmp )");
    FileLog("rtmpdump", "RtmpDump::GobalInit( SRS(ossrs) client librtmp library )");
    FileLog("rtmpdump", "RtmpDump::GobalInit( version: %d.%d.%d )", srs_version_major(), srs_version_minor(), srs_version_revision());
}

RtmpDump::RtmpDump()
    : mClientMutex(KMutex::MutexType_Recursive) {
    mpRtmpDumpCallback = NULL;
    mbRunning = false;

    mpRtmp = NULL;
    mpFlv = NULL;
    mRecordFlvFilePath = "";

    mpSps = NULL;
    mSpsSize = 0;

    mpPps = NULL;
    mPpsSize = 0;

    mNaluHeaderSize = 0;

    mWidth = 0;
    mHeight = 0;

    mEncodeVideoTimestamp = 0;
    mEncodeAudioTimestamp = 0;
    mSendVideoFrameTimestamp = 0;
    mSendAudioFrameTimestamp = 0;

    mIsPlay = true;
    mIsConnected = false;
    mConnectTimeout = 5000;

    mpRecvRunnable = new RecvRunnable(this);
    mpCheckConnectRunnable = new CheckConnectRunnable(this);
}

RtmpDump::~RtmpDump() {
    Stop();

    if (mpRecvRunnable) {
        delete mpRecvRunnable;
        mpRecvRunnable = NULL;
    }

    if (mpCheckConnectRunnable) {
        delete mpCheckConnectRunnable;
        mpCheckConnectRunnable = NULL;
    }

    if (mpSps) {
        delete[] mpSps;
        mpSps = NULL;
    }

    if (mpPps) {
        delete[] mpPps;
        mpPps = NULL;
    }
}

void RtmpDump::SetCallback(RtmpDumpCallback *callback) {
    mpRtmpDumpCallback = callback;
}

void RtmpDump::SetVideoParam(int width, int height) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::SetVideoParam( "
                 "this : %p, "
                 "width : %d, "
                 "height : %d "
                 ")",
                 this,
                 width,
                 height);

    mClientMutex.lock();
    mWidth = width;
    mHeight = height;
    mClientMutex.unlock();
}

bool RtmpDump::PlayUrl(const string &url, const string &recordFilePath) {
    bool bFlag = true;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PlayUrl( "
                 "this : %p, "
                 "url : %s, "
                 "recordFilePath : %s "
                 ")",
                 this,
                 url.c_str(),
                 recordFilePath.c_str());

    mClientMutex.lock();
    if (mbRunning) {
        Stop();
    }

    mIsPlay = true;
    mpRtmp = srs_rtmp_create(url.c_str());

    if (bFlag && mpRtmp) {
        // 创建FLV文件
        mRecordFlvFilePath = recordFilePath;
        if (mRecordFlvFilePath.length() > 0) {
            mpFlv = srs_flv_open_write(mRecordFlvFilePath.c_str());

            if (mpFlv) {
                FileLog("rtmpdump", "RtmpDump::PlayUrl( [Create record file success], recordFilePath : %s )", mRecordFlvFilePath.c_str());
            } else {
                FileLog("rtmpdump", "RtmpDump::PlayUrl( [Create record file fail], recordFilePath : %s )", mRecordFlvFilePath.c_str());
            }
        }

        mbRunning = true;
        mRecvThread.Start(mpRecvRunnable);
        mCheckConnectThread.Start(mpCheckConnectRunnable);

    } else {
        Stop();
    }

    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PlayUrl( "
                 "this : %p, "
                 "[%s], "
                 "url : %s, "
                 "mpRtmp : %p "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail",
                 url.c_str(),
                 mpRtmp);

    return bFlag;
}

bool RtmpDump::PublishUrl(const string &url) {
    bool bFlag = false;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PublishUrl( "
                 "this : %p, "
                 "url : %s "
                 ")",
                 this,
                 url.c_str());

    mClientMutex.lock();
    if (mbRunning) {
        Stop();
    }

    mIsPlay = false;
    mpRtmp = srs_rtmp_create(url.c_str());

    if (mpRtmp) {
        mbRunning = true;
        mRecvThread.Start(mpRecvRunnable);
        mCheckConnectThread.Start(mpCheckConnectRunnable);
        bFlag = true;

    } else {
        Stop();
    }

    mClientMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PublishUrl( "
                 "this : %p, "
                 "[%s], "
                 "url : %s, "
                 "mpRtmp : %p "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail",
                 url.c_str(),
                 mpRtmp);

    return bFlag;
}

void RtmpDump::RecvRunnableHandle() {
    //    int64_t nb_packets = 0;
    u_int32_t pre_timestamp = 0;
    int64_t pre_now = -1;
    int64_t start_time = -1;

    char type;
    u_int32_t timestamp = 0;
    char *frame = NULL;
    int frame_size = 0;

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::RecvRunnableHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    // 设置读写超时
    srs_rtmp_set_timeout(mpRtmp, 0, 0);
    bool bFlag = (0 == srs_rtmp_handshake(mpRtmp));
    if (bFlag) {
        bFlag = (0 == srs_rtmp_connect_app(mpRtmp));
        if (bFlag) {
            if (mIsPlay) {
                bFlag = (0 == srs_rtmp_play_stream(mpRtmp));
                if (!bFlag) {
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_ERR_USER,
                                 "RtmpDump::RecvRunnableHandle( "
                                 "this : %p, "
                                 "[srs_rtmp_play_stream fail] "
                                 ")",
                                 this);
                }
            } else {
                bFlag = (0 == srs_rtmp_publish_stream(mpRtmp));
                if (!bFlag) {
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_ERR_USER,
                                 "RtmpDump::RecvRunnableHandle( "
                                 "this : %p, "
                                 "[srs_rtmp_publish_stream fail] "
                                 ")",
                                 this);
                }
                // 发送支持Flash播放的视频分辨率
                srs_rtmp_set_data_frame(mpRtmp, mWidth, mHeight);
            }
        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_ERR_USER,
                         "RtmpDump::RecvRunnableHandle( "
                         "this : %p, "
                         "[srs_rtmp_connect_app fail]"
                         ")",
                         this);
        }
    } else {
        FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "RtmpDump::RecvRunnableHandle( "
                                                     "this : %p, "
                                                     "[srs_rtmp_handshake fail] "
                                                     ")",
                     this);
    }

    // 标记为已经连接上服务器
    if (bFlag) {
        mConnectedMutex.lock();
        mIsConnected = true;
        mEncodeVideoTimestamp = 0;
        mEncodeAudioTimestamp = 0;
        mSendVideoFrameTimestamp = 0;
        mSendAudioFrameTimestamp = 0;
        mConnectedMutex.unlock();

        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "RtmpDump::RecvRunnableHandle( "
                     "this : %p, "
                     "[Connected] "
                     ")",
                     this);

        if (mpRtmpDumpCallback) {
            mpRtmpDumpCallback->OnConnect(this);
        }
    }

    while (bFlag && mbRunning && 0 == srs_rtmp_read_packet(mpRtmp, &type, &timestamp, &frame, &frame_size)) {
        if (pre_now == -1) {
            pre_now = srs_utils_time_ms();
        }
        if (start_time == -1) {
            start_time = srs_utils_time_ms();
        }

        //        if( srs_human_print_rtmp_packet4(type, timestamp, frame, frame_size, pre_timestamp, pre_now, start_time, nb_packets++) != 0 ) {
        //            break;
        //        }

        pre_timestamp = timestamp;
        pre_now = srs_utils_time_ms();

        if (type == SRS_RTMP_TYPE_AUDIO) {
            Flv2Audio(frame, frame_size, timestamp);

        } else if (type == SRS_RTMP_TYPE_VIDEO) {
            Flv2Video(frame, frame_size, timestamp);

        } else if (type == SRS_RTMP_TYPE_COMMAND) {
            RecvCmd(frame, frame_size, timestamp);
        }

        // we only write some types of messages to flv file.
        int is_flv_msg = ((type == SRS_RTMP_TYPE_AUDIO) ||
                          (type == SRS_RTMP_TYPE_VIDEO) ||
                          (type == SRS_RTMP_TYPE_SCRIPT));

        // for script data, ignore except onMetaData
        if (type == SRS_RTMP_TYPE_SCRIPT) {
            if (!srs_rtmp_is_onMetaData(type, frame, frame_size)) {
                is_flv_msg = 0;
            }
        }

        if (mpFlv) {
            if (is_flv_msg) {
                if (srs_flv_write_tag(mpFlv, type, timestamp, frame, frame_size) != 0) {
                    //                    FileLog("RtmpDump", "RtmpDump::RecvRunnableHandle( [srs_flv_write_tag fail] )");
                }
            } else {
                //                FileLog("RtmpDump", "RtmpDump::RecvRunnableHandle( [drop message type=%#x, size=%dB] )", type, frame_size);
            }
        }

        //        free(frame);
        if (frame) {
            delete[] frame;
            frame = NULL;
        }
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::RecvRunnableHandle( "
                 "this : %p, "
                 "[Exit] "
                 ")",
                 this);

    mConnectedMutex.lock();
    mIsConnected = false;
    mConnectedMutex.unlock();

    if (mpRtmpDumpCallback) {
        mpRtmpDumpCallback->OnDisconnect(this);
    }
}

bool RtmpDump::SendVideoFrame(char *frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = false;
    int ret = 0;
    //    int nb_start_code = 0;

    char *sendFrame = frame;
    int sendSize = frame_size;

    mClientMutex.lock();
    mConnectedMutex.lock();
    if (mbRunning && mpRtmp && mIsConnected) {
        //        // 判断是否{0x00, 0x00, 0x00, 0x01}开头
        //        if( !srs_h264_startswith_annexb(frame, frame_size, &nb_start_code) ) {
        //            // Add NALU start code
        //            static char nalu[] = {0x00, 0x00, 0x00, 0x01};
        //            memcpy(mpTempVideoBuffer, nalu, sizeof(nalu));
        //            memcpy(mpTempVideoBuffer + sizeof(nalu), frame, frame_size);
        //
        //            sendFrame = mpTempVideoBuffer;
        //            sendSize = sizeof(nalu) + frame_size;
        //        }

        // 计算RTMP时间戳
        int sendTimestamp = 0;

        // 第一帧
        if (mEncodeVideoTimestamp == 0) {
            mEncodeVideoTimestamp = timestamp;
        }

        // 当前帧比上一帧时间戳大, 计算时间差
        if (timestamp > mEncodeVideoTimestamp) {
            sendTimestamp = timestamp - mEncodeVideoTimestamp;
        }

        // 生成RTMP相对时间戳
        mSendVideoFrameTimestamp += sendTimestamp;
        mEncodeVideoTimestamp = timestamp;

        // 因为没有B帧, 所以dts和pts一样就可以
        FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendVideoFrame( this : %p, timestamp : %u, size : %d, frameType : 0x%x )", this, mSendVideoFrameTimestamp, sendSize, sendFrame[0]);
        ret = srs_h264_write_raw_frame_without_startcode(mpRtmp, sendFrame, sendSize, mSendVideoFrameTimestamp, mSendVideoFrameTimestamp);
        //        ret = srs_h264_write_raw_frames(mpRtmp, sendFrame, sendSize, mSendVideoFrameTimestamp, mSendVideoFrameTimestamp);
        if (ret != 0) {
            bFlag = true;

            if (srs_h264_is_dvbsp_error(ret)) {
                //                FileLog("rtmpdump", "RtmpDump::SendVideoFrame( ignore drop video error, code=%d )", ret);

            } else if (srs_h264_is_duplicated_sps_error(ret)) {
                FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendVideoFrame( this : %p, Ignore duplicated sps, ret : %d )", this, ret);

            } else if (srs_h264_is_duplicated_pps_error(ret)) {
                FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendVideoFrame( this : %p, Ignore duplicated pps, ret : %d )", this, ret);

            } else {
                bFlag = false;
            }

        } else {
            bFlag = true;
        }
    }
    mConnectedMutex.unlock();
    mClientMutex.unlock();

    if (!bFlag) {
        mConnectedMutex.lock();
        if (mIsConnected) {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "RtmpDump::SendVideoFrame( this : %p, Send h264 raw data failed, ret : %d )", this, ret);

            srs_rtmp_shutdown(mpRtmp);
        }
        mConnectedMutex.unlock();

    } else {
        // 5bits, 7.3.1 NAL unit syntax,
        // H.264-AVC-ISO_IEC_14496-10.pdf, page 44.
        //  7: SPS, 8: PPS, 5: I Frame, 1: P Frame, 9: AUD, 6: SEI
        //        u_int8_t nut = (char)frame[nb_start_code] & 0x1f;
        //        FileLog("RtmpDump", "sent packet: type=%s, time=%d, size=%d, b[%d]=%#x(%s)",
        //                        srs_human_flv_tag_type2string(SRS_RTMP_TYPE_VIDEO), mSendVideoFrameTimestamp, frame_size, nb_start_code, (char)frame[nb_start_code],
        //                        (nut == 7? "SPS":(nut == 8? "PPS":(nut == 5? "I":(nut == 1? "P":(nut == 9? "AUD":(nut == 6? "SEI":"Unknown")))))));
    }

    return bFlag;
}

void RtmpDump::AddVideoTimestamp(u_int32_t timestamp) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpDump::AddVideoTimestamp( "
                 "this : %p, "
                 "timestamp : %u "
                 ")",
                 this,
                 timestamp);

    mConnectedMutex.lock();
    if (mIsConnected) {
        mSendVideoFrameTimestamp += timestamp;
    }
    mConnectedMutex.unlock();
}

bool RtmpDump::SendAudioFrame(
    AudioFrameFormat sound_format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type,
    char *frame,
    int frame_size,
    u_int32_t timestamp) {
    bool bFlag = false;
    int ret = 0;

    mClientMutex.lock();
    mConnectedMutex.lock();
    if (mbRunning && mpRtmp && mIsConnected) {
        // 计算RTMP时间戳
        int sendTimestamp = 0;

        // 第一帧
        if (mEncodeAudioTimestamp == 0) {
            mEncodeAudioTimestamp = timestamp;
        }

        // 当前帧比上一帧时间戳大, 计算时间差
        if (timestamp > mEncodeAudioTimestamp) {
            sendTimestamp = timestamp - mEncodeAudioTimestamp;
        }

        // 生成RTMP相对时间戳
        mSendAudioFrameTimestamp += sendTimestamp;
        mEncodeAudioTimestamp = timestamp;

        FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendAudioFrame( this : %p, timestamp : %u, size : %d )", this, mSendAudioFrameTimestamp, frame_size);
        if ((ret = srs_audio_write_raw_frame(mpRtmp, sound_format, sound_rate, sound_size, sound_type, frame, frame_size, mSendAudioFrameTimestamp)) == 0) {
            bFlag = true;
        }
    }
    mConnectedMutex.unlock();
    mClientMutex.unlock();

    if (!bFlag) {
        FileLevelLog("rtmpdump", KLog::LOG_WARNING, "RtmpDump::SendAudioFrame( this : %p, Send audio raw data failed. ret=%d, timestamp : %u )", this, ret, mSendAudioFrameTimestamp);
        mConnectedMutex.lock();
        if (mIsConnected) {
            srs_rtmp_shutdown(mpRtmp);
        }
        mConnectedMutex.unlock();
    }

    return bFlag;
}

void RtmpDump::AddAudioTimestamp(u_int32_t timestamp) {
    mConnectedMutex.lock();
    if (mIsConnected) {
        mSendAudioFrameTimestamp += timestamp;
    }
    mConnectedMutex.unlock();
}

void RtmpDump::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::Stop( "
                 "this : %p, "
                 "mpRtmp : %p "
                 ")",
                 this,
                 mpRtmp);

    mClientMutex.lock();

    if (mbRunning) {
        mbRunning = false;

        if (mpRtmp) {
            srs_rtmp_shutdown(mpRtmp);
        }

        mRecvThread.Stop();
        mCheckConnectThread.Stop();

        Destroy();
    }

    mClientMutex.unlock();

    FileLevelLog(
        "rtmpdump",
        KLog::LOG_MSG,
        "RtmpDump::Stop( "
        "this : %p, "
        "[Success] "
        ")",
        this);
}

void RtmpDump::Destroy() {
    //    FileLog("rtmpdump", "RtmpDump::Destroy( "
    //            "this : %p, "
    //            "mpRtmp : %p "
    //            ")",
    //            this,
    //            mpRtmp
    //            );

    // 关闭RTMP句柄
    if (mpRtmp) {
        srs_rtmp_destroy(mpRtmp);
        mpRtmp = NULL;
    }

    // 关闭FLV文件
    if (mpFlv) {
        srs_flv_close(mpFlv);
        mpFlv = NULL;
    }

    //    FileLog("rtmpdump", "RtmpDump::Destroy( "
    //            "[Success], "
    //            "this : %p "
    //            ")",
    //            this
    //            );
}

bool RtmpDump::Flv2Audio(char *frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = true;

    AudioFrameFormat sound_format = AFF_UNKNOWN;
    AudioFrameSoundRate sound_rate = AFSR_UNKNOWN;
    AudioFrameSoundSize sound_size = AFSS_UNKNOWN;
    AudioFrameSoundType sound_type = AFST_UNKNOWN;
    AudioFrameAACType aac_type = AAC_UNKNOWN;

    char *pStart = frame + 1;
    int playload_size = frame_size - 1;

    sound_format = (AudioFrameFormat)srs_utils_flv_audio_sound_format(frame, frame_size);
    sound_rate = (AudioFrameSoundRate)srs_utils_flv_audio_sound_rate(frame, frame_size);
    sound_size = (AudioFrameSoundSize)srs_utils_flv_audio_sound_size(frame, frame_size);
    sound_type = (AudioFrameSoundType)srs_utils_flv_audio_sound_type(frame, frame_size);

    if (sound_format == AFF_AAC) {
        pStart++;
        playload_size--;

        aac_type = (AudioFrameAACType)srs_utils_flv_audio_aac_packet_type(frame, frame_size);
        if (aac_type == AAC_SEQUENCE_HEADER) {
            // AAC类型包
            if (mpRtmpDumpCallback) {
                mpRtmpDumpCallback->OnChangeAudioFormat(this, sound_format, sound_rate, sound_size, sound_type);
            }

        } else if (aac_type == AAC_RAW) {
            // Callback for Audio Data
            if (mpRtmpDumpCallback) {
                mpRtmpDumpCallback->OnRecvAudioFrame(this, sound_format, sound_rate, sound_size, sound_type, pStart, playload_size, timestamp);
            }
        }
    }

    return bFlag;
}

bool RtmpDump::Flv2Video(char *frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = false;

    if (frame_size > 1) {
        VideoFrameFormat video_format = (VideoFrameFormat)srs_utils_flv_video_codec_id(frame, frame_size);
        switch (video_format) {
            case VVF_AVC: {
                // H264
                bFlag = FlvVideo2H264(frame, frame_size, timestamp);

            } break;
            default:
                break;
        }
    }

    return bFlag;
}

bool RtmpDump::FlvVideo2H264(char *frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = true;

    char *pStart = frame;
    char *pEnd = frame + frame_size;

    if (
        srs_utils_flv_video_frame_type(frame, frame_size) == 0x01 &&  // Key frame
        srs_utils_flv_video_codec_id(frame, frame_size) == 0x07 &&    // H264
        srs_utils_flv_video_avc_packet_type(frame, frame_size) == 0x0 // SPS/PPS
        ) {
        pStart = frame + 2;
        int cfgVer = pStart[3];
        if (cfgVer == 1) {
            int spsIndex = 0;
            int spsLen = 0;

            int ppsIndex = 0;
            int ppsLen = 0;

            mNaluHeaderSize = (pStart[7] & 0x03) + 1; // 4

            spsIndex = pStart[8] & 0x1f; //1
            pStart += 9;

            for (int i = 0; i < spsIndex; i++) {
                spsLen = ntohs(*(unsigned short *)pStart);
                pStart += 2;

                if (spsLen > pEnd - pStart) {
                    bFlag = false;
                    break;
                }

                bool bSpsChange = true;
                if (mpSps != NULL) {
                    if (mSpsSize == spsLen) {
                        if (0 != memcmp(mpSps, pStart, spsLen)) {
                            bSpsChange = true;

                        } else {
                            bSpsChange = false;
                        }
                    }
                }

                if (bSpsChange) {
                    if (mpSps) {
                        delete[] mpSps;
                        mpSps = NULL;
                    }

                    mSpsSize = spsLen;
                    mpSps = new char[mSpsSize];
                    memcpy(mpSps, pStart, mSpsSize);
                }

                pStart += spsLen;
            }

            ppsIndex = pStart[0];
            pStart += 1;
            for (int i = 0; i < ppsIndex; i++) {
                ppsLen = ntohs(*(unsigned short *)pStart);
                pStart += 2;
                if (ppsLen > pEnd - pStart) {
                    bFlag = false;
                    break;
                }

                bool bPpsChange = true;
                if (mpPps != NULL) {
                    if (mPpsSize == ppsLen) {
                        if (0 != memcmp(mpPps, pStart, spsLen)) {
                            bPpsChange = true;

                        } else {
                            bPpsChange = false;
                        }
                    }
                }

                if (bPpsChange) {
                    if (mpPps) {
                        delete[] mpPps;
                        mpPps = NULL;
                    }

                    mPpsSize = ppsLen;
                    mpPps = new char[mPpsSize];
                    memcpy(mpPps, pStart, mPpsSize);

                    //                    // Write to H264 file
                    //                    if( mpRecordH264File ) {
                    //                        // Write NALU start code
                    //                        fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264File);
                    //
                    //                        // Write playload
                    //                        fwrite(mpPps, 1, mPpsSize, mpRecordH264File);
                    //
                    //                        fflush(mpRecordH264File);
                    //                    }
                }

                pStart += ppsLen;
            }

            if (mpRtmpDumpCallback) {
                mpRtmpDumpCallback->OnChangeVideoSpsPps(this, mpSps, mSpsSize, mpPps, mPpsSize, mNaluHeaderSize, timestamp);
            }

        } else {
            // UnSupport version
            bFlag = false;
        }

    } else if (
        (
            srs_utils_flv_video_frame_type(frame, frame_size) == 0x01 || // Key frame
            srs_utils_flv_video_frame_type(frame, frame_size) == 0x02    // Inter frame
            ) &&
        srs_utils_flv_video_codec_id(frame, frame_size) == 0x07 &&    // H264
        srs_utils_flv_video_avc_packet_type(frame, frame_size) == 0x1 // NALU
        ) {
        if (mpSps && mpPps && mNaluHeaderSize != 0) {
            // Skip FLV video tag
            pStart = frame + 5;
            
            unsigned char *pCts = (unsigned char *)frame + 2;
            u_int32_t cts = pCts[0] << 24;
            cts |= pCts[1] << 16;
            cts |= pCts[2];
            
            u_int32_t dts = timestamp - cts;
            
//            FileLevelLog("rtmpdump",
//                         KLog::LOG_STAT,
//                         "RtmpDump::FlvVideo2H264( "
//                         "this : %p, "
//                         "pts : %u, "
//                         "dts : %u, "
//                         "cts : %u "
//                         ")",
//                         this,
//                         timestamp,
//                         dts,
//                         cts);
            
            // Callback for Video
            if (mpRtmpDumpCallback) {
                VideoFrameType type = VFT_UNKNOWN;
                if (srs_utils_flv_video_frame_type(frame, frame_size) == 0x01) {
                    type = VFT_IDR;
                } else if (srs_utils_flv_video_frame_type(frame, frame_size) == 0x02) {
                    type = VFT_NOTIDR;
                }
                mpRtmpDumpCallback->OnRecvVideoFrame(this, pStart, (int)(pEnd - pStart), timestamp, dts, type);
            }
        }
    }

    return bFlag;
}

u_int32_t RtmpDump::GetCurrentTime() {
    struct timeval tv;
    gettimeofday(&tv, 0);
    return (u_int32_t)(tv.tv_sec * 1000) + (u_int32_t)(tv.tv_usec / 1000);
}

void RtmpDump::CheckConnectRunnableHandle() {
    bool bBreak = false;
    long long startTime = (long long)getCurrentTime();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::CheckConnectRunnableHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    while (mbRunning) {
        mConnectedMutex.lock();
        if (mIsConnected) {
            // 已经连接上服务器, 标记退出线程
            bBreak = true;
        } else {
            // 计算超时
            long long curTime = (long long)getCurrentTime();
            int diffTime = (int)(curTime - startTime);
            if (diffTime >= mConnectTimeout) {
                // 超时, 断开连接
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "RtmpDump::CheckConnectRunnableHandle( "
                             "this : %p, "
                             "[Shutdown for connect timeout] "
                             ")",
                             this);

                if (mpRtmp) {
                    srs_rtmp_shutdown(mpRtmp);
                }
                bBreak = true;
            }
        }
        mConnectedMutex.unlock();

        if (bBreak) {
            break;
        }

        Sleep(100);
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::CheckConnectRunnableHandle( "
                 "this : %p, "
                 "[Exit] "
                 ")",
                 this);
}

void RtmpDump::RecvCmd(char *frame, int frame_size, u_int32_t timestamp) {
    int index = 0;
    int last = frame_size;
    int size = 0;

    srs_amf0_t cmd = srs_amf0_parse(frame, last, &size);
    index += size;
    last -= size;
    if (srs_amf0_is_string(cmd)) {
        const char *cmdString = srs_amf0_to_string(cmd);
        FileLevelLog("rtmpdump",
                     KLog::LOG_WARNING,
                     "RtmpDump::RecvCmd( "
                     "this : %p, "
                     "[Got command], "
                     "cmd : %s "
                     ")",
                     this,
                     cmdString);

        if (0 == strcmp(cmdString, "onLogin")) {
            RecvCmdLogin(frame + index, last, timestamp);

        } else if (0 == strcmp(cmdString, "onMakeCall")) {
            RecvCmdMakeCall(frame + index, last, timestamp);
        }
    }
    srs_amf0_free(cmd);
}

bool RtmpDump::SendCmdLogin(const string &userName, const string &password, const string &siteId) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpDump::SendCmdLogin( "
                 "this : %p, "
                 "userName : %s, "
                 "password : %s, "
                 "siteId : %s "
                 ")",
                 this,
                 userName.c_str(),
                 password.c_str(),
                 siteId.c_str());

    bool bFlag = false;

    char *data = new char[4096];
    memset(data, 0, 4096);
    int index = 0;
    int size = 0;

    srs_amf0_t amfCmd = srs_amf0_create_string("login");
    size = srs_amf0_size(amfCmd);
    srs_amf0_serialize(amfCmd, data + index, size);
    index += size;
    srs_amf0_free(amfCmd);

    srs_amf0_t amfNumber = srs_amf0_create_number(0);
    size = srs_amf0_size(amfNumber);
    srs_amf0_serialize(amfNumber, data + index, size);
    index += size;
    srs_amf0_free(amfNumber);

    srs_amf0_t amfArgs = srs_amf0_create_null();
    size = srs_amf0_size(amfArgs);
    srs_amf0_serialize(amfArgs, data + index, size);
    index += size;
    srs_amf0_free(amfArgs);

    char user[2048] = {0};
    snprintf(user, sizeof(user) - 1, "%s@%s", userName.c_str(), "172.25.32.133");
    srs_amf0_t amfUserName = srs_amf0_create_string(user);
    size = srs_amf0_size(amfUserName);
    srs_amf0_serialize(amfUserName, data + index, size);
    index += size;
    srs_amf0_free(amfUserName);

    char auth[2048] = {0};
    snprintf(auth, sizeof(auth) - 1, "%s:%s", user, "123456");
    char authMd5[2048] = {0};
    GetMD5String(auth, authMd5);
    srs_amf0_t amfAuth = srs_amf0_create_string(authMd5);
    size = srs_amf0_size(amfAuth);
    srs_amf0_serialize(amfAuth, data + index, size);
    index += size;
    srs_amf0_free(amfAuth);

    srs_amf0_t amfSiteId = srs_amf0_create_string(siteId.c_str());
    size = srs_amf0_size(amfSiteId);
    srs_amf0_serialize(amfSiteId, data + index, size);
    index += size;
    srs_amf0_free(amfSiteId);

    char sid[2048] = {0};
    snprintf(sid, sizeof(sid) - 1, "sid=%s&userType=1", siteId.c_str());
    srs_amf0_t amfCustom = srs_amf0_create_string(sid);
    size = srs_amf0_size(amfCustom);
    srs_amf0_serialize(amfCustom, data + index, size);
    index += size;
    srs_amf0_free(amfCustom);

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpDump::SendCmdLogin( "
                 "this : %p, "
                 "user : %s, "
                 "auth : %s, "
                 "sid : %s "
                 ")",
                 this,
                 user,
                 auth,
                 sid);

    int ret = srs_rtmp_write_packet(mpRtmp, SRS_RTMP_TYPE_COMMAND, 0, data, index);

    return bFlag;
}

void RtmpDump::RecvCmdLogin(char *frame, int frame_size, u_int32_t timestamp) {
    int index = 0;
    int last = frame_size;
    int size = 0;
    bool bFlag = false;

    srs_amf0_t number = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;

    srs_amf0_t args = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;

    srs_amf0_t result = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;
    const char *resultString = NULL;
    if (srs_amf0_is_string(result)) {
        resultString = srs_amf0_to_string(result);
        if (0 == strcmp(resultString, "success")) {
            bFlag = true;
        }
    }

    srs_amf0_t userName = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;
    const char *userNameString = "";
    if (srs_amf0_is_string(userName)) {
        userNameString = srs_amf0_to_string(userName);
    }

    srs_amf0_t serverAddress = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;
    const char *serverAddressString = "";
    if (srs_amf0_is_string(serverAddress)) {
        serverAddressString = srs_amf0_to_string(serverAddress);
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpDump::RecvCmdLogin( "
                 "this : %p, "
                 "bFlag : %s, "
                 "userName : %s, "
                 "serverAddress : %s "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail",
                 userNameString,
                 serverAddressString);

    if (mpRtmpDumpCallback) {
        mpRtmpDumpCallback->OnRecvCmdLogin(this, bFlag, userNameString, serverAddressString);
    }
}

bool RtmpDump::SendCmdMakeCall(const string &userName, const string &serverId, const string &siteId) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "RtmpDump::SendCmdMakeCall( "
                 "this : %p, "
                 "userName : %s, "
                 "serverId : %s, "
                 "siteId : %s "
                 ")",
                 this,
                 userName.c_str(),
                 serverId.c_str(),
                 siteId.c_str());

    bool bFlag = false;

    char *data = new char[4096];
    memset(data, 0, 4096);
    int index = 0;
    int size = 0;

    srs_amf0_t amfCmd = srs_amf0_create_string("makeCall");
    size = srs_amf0_size(amfCmd);
    srs_amf0_serialize(amfCmd, data + index, size);
    index += size;
    srs_amf0_free(amfCmd);

    srs_amf0_t amfNumber = srs_amf0_create_number(0);
    size = srs_amf0_size(amfNumber);
    srs_amf0_serialize(amfNumber, data + index, size);
    index += size;
    srs_amf0_free(amfNumber);

    srs_amf0_t amfArgs = srs_amf0_create_null();
    size = srs_amf0_size(amfArgs);
    srs_amf0_serialize(amfArgs, data + index, size);
    index += size;
    srs_amf0_free(amfArgs);

    char userNameString[1024] = {0};
    snprintf(userNameString, sizeof(userNameString) - 1, "%s|||%s|||%s", userName.c_str(), serverId.c_str(), siteId.c_str());
    srs_amf0_t amfUserName = srs_amf0_create_string(userNameString);
    size = srs_amf0_size(amfUserName);
    srs_amf0_serialize(amfUserName, data + index, size);
    index += size;
    srs_amf0_free(amfUserName);

    srs_amf0_t argsNullString = srs_amf0_create_string("");
    size = srs_amf0_size(argsNullString);
    srs_amf0_serialize(argsNullString, data + index, size);
    index += size;
    srs_amf0_free(argsNullString);

    srs_amf0_t makeCallObj = srs_amf0_create_object();
    srs_amf0_t bandWith = srs_amf0_create_string("1mb");
    srs_amf0_object_property_set(makeCallObj, "incomingBandwidth", bandWith);
    srs_amf0_t wantVideo = srs_amf0_create_string("true");
    srs_amf0_object_property_set(makeCallObj, "wantVideo", wantVideo);
    size = srs_amf0_size(makeCallObj);
    srs_amf0_serialize(makeCallObj, data + index, size);
    index += size;
    srs_amf0_free(makeCallObj);

    int ret = srs_rtmp_write_packet(mpRtmp, SRS_RTMP_TYPE_COMMAND, 0, data, index);

    return bFlag;
}

void RtmpDump::RecvCmdMakeCall(char *frame, int frame_size, u_int32_t timestamp) {
    int index = 0;
    int last = frame_size;
    int size = 0;
    bool bFlag = false;

    srs_amf0_t number = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;

    srs_amf0_t args = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;

    srs_amf0_t uuId = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;
    const char *uuIdString = "";
    if (srs_amf0_is_string(uuId)) {
        uuIdString = srs_amf0_to_string(uuId);
    }

    srs_amf0_t userName = srs_amf0_parse(frame + index, last, &size);
    index += size;
    last -= size;
    const char *userNameString = "";
    if (srs_amf0_is_string(userName)) {
        userNameString = srs_amf0_to_string(userName);
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::LOG_WARNING( "
                 "this : %p, "
                 "uuId : %s, "
                 "userName : %s "
                 ")",
                 this,
                 uuIdString,
                 userNameString);

    if (mpRtmpDumpCallback) {
        mpRtmpDumpCallback->OnRecvCmdMakeCall(this, uuIdString, userNameString);
    }
}

bool RtmpDump::SendCmdReceive() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::SendCmdReceive( "
                 "this : %p "
                 ")",
                 this);

    bool bFlag = false;

    char *data = new char[4096];
    memset(data, 0, 4096);
    int index = 0;
    int size = 0;

    srs_amf0_t amfCmd = srs_amf0_create_string("receiveVideo");
    size = srs_amf0_size(amfCmd);
    srs_amf0_serialize(amfCmd, data + index, size);
    index += size;
    srs_amf0_free(amfCmd);

    srs_amf0_t amfNumber = srs_amf0_create_number(0);
    size = srs_amf0_size(amfNumber);
    srs_amf0_serialize(amfNumber, data + index, size);
    index += size;
    srs_amf0_free(amfNumber);

    srs_amf0_t amfArgs = srs_amf0_create_null();
    size = srs_amf0_size(amfArgs);
    srs_amf0_serialize(amfArgs, data + index, size);
    index += size;
    srs_amf0_free(amfArgs);

    srs_amf0_t amfRecvVideo = srs_amf0_create_boolean(true);
    size = srs_amf0_size(amfRecvVideo);
    srs_amf0_serialize(amfRecvVideo, data + index, size);
    index += size;
    srs_amf0_free(amfRecvVideo);
    
    int ret = srs_rtmp_write_packet(mpRtmp, SRS_RTMP_TYPE_COMMAND, 0, data, index);
    
    return bFlag;
}
}
