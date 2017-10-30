//
//  RtmpDump.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpDump.h"

#include <common/CommonFunc.h>

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
:mClientMutex(KMutex::MutexType_Recursive) {
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
    
    if( mpRecvRunnable ) {
        delete mpRecvRunnable;
        mpRecvRunnable = NULL;
    }
    
    if( mpCheckConnectRunnable ) {
        delete mpCheckConnectRunnable;
        mpCheckConnectRunnable = NULL;
    }
    
    if( mpSps ) {
        delete[] mpSps;
        mpSps = NULL;
    }
    
    if( mpPps ) {
        delete[] mpPps;
        mpPps = NULL;
    }
}

void RtmpDump::SetCallback(RtmpDumpCallback* callback) {
    mpRtmpDumpCallback = callback;
}

bool RtmpDump::PlayUrl(const string& url, const string& recordFilePath, const string& recordAACFilePath) {
    bool bFlag = true;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PlayUrl( "
                 "this : %p, "
                 "url : %s "
                 ")",
                 this,
                 url.c_str()
                 );
    
    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    mIsPlay = true;
    mpRtmp = srs_rtmp_create(url.c_str());
    
    if( bFlag && mpRtmp ) {
        // 创建FLV文件
        mRecordFlvFilePath = recordFilePath;
        if( mRecordFlvFilePath.length() > 0 ) {
            mpFlv = srs_flv_open_write(mRecordFlvFilePath.c_str());
            
            if( mpFlv ) {
                // flv header
                char header[9];
                // 3bytes, signature, "FLV",
                header[0] = 'F';
                header[1] = 'L';
                header[2] = 'V';
                // 1bytes, version, 0x01,
                header[3] = 0x01;
                // 1bytes, flags, UB[5] 0, UB[1] audio present, UB[1] 0, UB[1] video present.
                header[4] = 0x03; // audio + video.
                // 4bytes, dataoffset
                header[5] = 0x00;
                header[6] = 0x00;
                header[7] = 0x00;
                header[8] = 0x09;
                bFlag &= (0 == srs_flv_write_header(mpFlv, header));
                
            } else {
                FileLog("rtmpdump", "RtmpDump::PlayUrl( [Write flv file header fail], recordFilePath : %s )", mRecordFlvFilePath.c_str());
                
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
                 "[%s], "
                 "this : %p, "
                 "url : %s, "
                 "mpRtmp : %p "
                 ")",
                 bFlag?"Success":"Fail",
                 this,
                 url.c_str(),
                 mpRtmp
                 );
    
    return bFlag;
}

bool RtmpDump::PublishUrl(const string& url, const string& recordAACFilePath) {
    bool bFlag = false;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PublishUrl( "
                 "this : %p, "
                 "url : %s "
                 ")",
                 this,
                 url.c_str()
                 );
    
    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    mIsPlay = false;
    mpRtmp = srs_rtmp_create(url.c_str());
    
    if( mpRtmp ) {
        mbRunning = true;
        mRecvThread.Start(mpRecvRunnable);
        bFlag = true;
        
    } else {
        Stop();
    }
    
    mClientMutex.unlock();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::PublishUrl( "
                 "[%s], "
                 "this : %p, "
                 "url : %s, "
                 "mpRtmp : %p "
                 ")",
                 bFlag?"Success":"Fail",
                 this,
                 url.c_str(),
                 mpRtmp
                 );
    
    return bFlag;
}

void RtmpDump::RecvRunnableHandle() {    
//    int64_t nb_packets = 0;
    u_int32_t pre_timestamp = 0;
    int64_t pre_now = -1;
    int64_t start_time = -1;
    
    char type;
    u_int32_t timestamp = 0;
    char* frame = NULL;
    int frame_size = 0;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::RecvRunnableHandle( "
                 "[Start], "
                 "this : %p "
                 ")",
                 this
                 );
    
    // 设置读写超时
    srs_rtmp_set_timeout(mpRtmp, 0, 0);
    bool bFlag = (0 == srs_rtmp_handshake(mpRtmp));
    if( bFlag ) {
        bFlag = (0 == srs_rtmp_connect_app(mpRtmp));
        if( bFlag ) {
            if( mIsPlay ) {
                bFlag = (0 == srs_rtmp_play_stream(mpRtmp));
                if( !bFlag ) {
                    FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "RtmpDump::RecvRunnableHandle( [srs_rtmp_play_stream fail] )");
                }
            } else {
                bFlag = (0 == srs_rtmp_publish_stream(mpRtmp));
                if( !bFlag ) {
                    FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "RtmpDump::RecvRunnableHandle( [srs_rtmp_publish_stream fail] )");
                }
            }
        } else {
            FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "RtmpDump::RecvRunnableHandle( [srs_rtmp_connect_app fail] )");
        }
    } else {
        FileLevelLog("rtmpdump", KLog::LOG_ERR_USER, "RtmpDump::RecvRunnableHandle( [srs_rtmp_handshake fail] )");
    }
    
    // 标记为已经连接上服务器
    if( bFlag ) {
        mConnectedMutex.lock();
        mIsConnected = true;
        mEncodeVideoTimestamp = 0;
        mEncodeAudioTimestamp = 0;
        mSendVideoFrameTimestamp = 0;
        mSendAudioFrameTimestamp = 0;
        mConnectedMutex.unlock();
        
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "RtmpDump::RecvRunnableHandle( [Connected] )"
                     );
        
        if( mpRtmpDumpCallback ) {
            mpRtmpDumpCallback->OnConnect(this);
        }
    }
    
    while( bFlag && mbRunning && 0 == srs_rtmp_read_packet(mpRtmp, &type, &timestamp, &frame, &frame_size) ) {
        if( pre_now == -1 ) {
            pre_now = srs_utils_time_ms();
        }
        if( start_time == -1 ) {
            start_time = srs_utils_time_ms();
        }
        
//        if( srs_human_print_rtmp_packet4(type, timestamp, frame, frame_size, pre_timestamp, pre_now, start_time, nb_packets++) != 0 ) {
//            break;
//        }
        
        pre_timestamp = timestamp;
        pre_now = srs_utils_time_ms();
        
        if( type == SRS_RTMP_TYPE_AUDIO ) {
            Flv2Audio(frame, frame_size, timestamp);
            
        } else if( type == SRS_RTMP_TYPE_VIDEO ) {
            Flv2Video(frame, frame_size, timestamp);
        }
        
        // we only write some types of messages to flv file.
        int is_flv_msg = (
                          (type == SRS_RTMP_TYPE_AUDIO) ||
                          (type == SRS_RTMP_TYPE_VIDEO) ||
                          (type == SRS_RTMP_TYPE_SCRIPT)
                          );
        
        // for script data, ignore except onMetaData
        if( type == SRS_RTMP_TYPE_SCRIPT ) {
            if (!srs_rtmp_is_onMetaData(type, frame, frame_size)) {
                is_flv_msg = 0;
            }
        }
        
        if( mpFlv ) {
            if( is_flv_msg ) {
                if( srs_flv_write_tag(mpFlv, type, timestamp, frame, frame_size) != 0 ) {
//                    FileLog("RtmpDump", "RtmpDump::RecvRunnableHandle( [srs_flv_write_tag fail] )");
                }
            } else {
//                FileLog("RtmpDump", "RtmpDump::RecvRunnableHandle( [drop message type=%#x, size=%dB] )", type, frame_size);
            }
        }
        
        free(frame);
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::RecvRunnableHandle( "
                 "[Exit], "
                 "this : %p "
                 ")",
                 this
                 );
    
    mConnectedMutex.lock();
    mIsConnected = false;
    mConnectedMutex.unlock();
    
    if( mpRtmpDumpCallback ) {
        mpRtmpDumpCallback->OnDisconnect(this);
    }
}

bool RtmpDump::SendVideoFrame(char* frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = false;
    int ret = 0;
//    int nb_start_code = 0;
    
    char* sendFrame = frame;
    int sendSize = frame_size;
    
    mClientMutex.lock();
    mConnectedMutex.lock();
    if( mbRunning && mpRtmp && mIsConnected ) {
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
        if( mEncodeVideoTimestamp == 0 ) {
            mEncodeVideoTimestamp = timestamp;
        }
        
        // 当前帧比上一帧时间戳大, 计算时间差
        if( timestamp > mEncodeVideoTimestamp ) {
            sendTimestamp = timestamp - mEncodeVideoTimestamp;
        }
        
        // 生成RTMP相对时间戳
        mSendVideoFrameTimestamp += sendTimestamp;
        mEncodeVideoTimestamp = timestamp;
        
        // 因为没有B帧, 所以dts和pts一样就可以
        FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendVideoFrame( timestamp : %u, size : %d, frameType : 0x%x )", mSendVideoFrameTimestamp, sendSize, sendFrame[0]);
        ret = srs_h264_write_raw_frame_without_startcode(mpRtmp, sendFrame, sendSize, mSendVideoFrameTimestamp, mSendVideoFrameTimestamp);
//        ret = srs_h264_write_raw_frames(mpRtmp, sendFrame, sendSize, mSendVideoFrameTimestamp, mSendVideoFrameTimestamp);
        if (ret != 0) {
            bFlag = true;
            
            if (srs_h264_is_dvbsp_error(ret)) {
//                FileLog("rtmpdump", "RtmpDump::SendVideoFrame( ignore drop video error, code=%d )", ret);
                
            } else if (srs_h264_is_duplicated_sps_error(ret)) {
                FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendVideoFrame( Ignore duplicated sps, ret : %d )", ret);
                
            } else if (srs_h264_is_duplicated_pps_error(ret)) {
                FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendVideoFrame( Ignore duplicated pps, ret : %d )", ret);
                
            } else {
                bFlag = false;
            }
            
        } else {
            bFlag = true;
        }
        
    }
    mConnectedMutex.unlock();
    mClientMutex.unlock();
    
    if( !bFlag ) {
        mConnectedMutex.lock();
        if( mIsConnected ) {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "RtmpDump::SendVideoFrame( Send h264 raw data failed, ret : %d )", ret);
            
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
    mConnectedMutex.lock();
    if( mIsConnected ) {
        mSendVideoFrameTimestamp += timestamp;
    }
    mConnectedMutex.unlock();
}
    
bool RtmpDump::SendAudioFrame(
                              AudioFrameFormat sound_format,
                              AudioFrameSoundRate sound_rate,
                              AudioFrameSoundSize sound_size,
                              AudioFrameSoundType sound_type,
                              char* frame,
                              int frame_size,
                              u_int32_t timestamp
                              ) {
    bool bFlag = false;
    int ret = 0;
    
    mClientMutex.lock();
    mConnectedMutex.lock();
    if( mbRunning && mpRtmp && mIsConnected ) {
        // 计算RTMP时间戳
        int sendTimestamp = 0;
        
        // 第一帧
        if( mEncodeAudioTimestamp == 0 ) {
            mEncodeAudioTimestamp = timestamp;
        }
        
        // 当前帧比上一帧时间戳大, 计算时间差
        if( timestamp > mEncodeAudioTimestamp ) {
            sendTimestamp = timestamp - mEncodeAudioTimestamp;
        }
        
        // 生成RTMP相对时间戳
        mSendAudioFrameTimestamp += sendTimestamp;
        mEncodeAudioTimestamp = timestamp;
        
        FileLevelLog("rtmpdump", KLog::LOG_MSG, "RtmpDump::SendAudioFrame( timestamp : %u, size : %d )", mSendAudioFrameTimestamp, frame_size);
        if( (ret = srs_audio_write_raw_frame(mpRtmp, sound_format, sound_rate, sound_size, sound_type, frame, frame_size, mSendAudioFrameTimestamp)) == 0 ) {
            bFlag = true;
        }
    }
    mConnectedMutex.unlock();
    mClientMutex.unlock();
    
    if( !bFlag ) {
        mConnectedMutex.lock();
        if( mIsConnected ) {
            FileLevelLog("rtmpdump", KLog::LOG_WARNING, "RtmpDump::SendAudioFrame( [send audio raw data failed. ret=%d], timestamp : %u )", ret, mSendAudioFrameTimestamp);
            
            srs_rtmp_shutdown(mpRtmp);
        }
        mConnectedMutex.unlock();
        
    }
    
    return bFlag;
}

void RtmpDump::AddAudioTimestamp(u_int32_t timestamp) {
    mConnectedMutex.lock();
    if( mIsConnected ) {
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
                 mpRtmp
                 );

    mClientMutex.lock();
    
    if( mbRunning ) {
        mbRunning = false;
        
        if( mpRtmp ) {
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
                 "[Success], "
                 "this : %p "
                 ")",
                 this
                 );

}

void RtmpDump::Destroy() {
//	FileLog("rtmpdump", "RtmpDump::Destroy( "
//			"this : %p, "
//			"mpRtmp : %p "
//			")",
//			this,
//			mpRtmp
//			);

    // 关闭RTMP句柄
    if( mpRtmp ) {
        srs_rtmp_destroy(mpRtmp);
        mpRtmp = NULL;
    }
    
    // 关闭FLV文件
    if( mpFlv ) {
        srs_flv_close(mpFlv);
        mpFlv = NULL;
    }

//	FileLog("rtmpdump", "RtmpDump::Destroy( "
//			"[Success], "
//			"this : %p "
//			")",
//			this
//			);
}

bool RtmpDump::Flv2Audio(char* frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = true;
    
    AudioFrameFormat sound_format = AFF_UNKNOWN;
    AudioFrameSoundRate sound_rate = AFSR_UNKNOWN;
    AudioFrameSoundSize sound_size = AFSS_UNKNOWN;
    AudioFrameSoundType sound_type = AFST_UNKNOWN;
    AudioFrameAACType aac_type = AAC_UNKNOWN;
    
    char* pStart = frame + 1;
    int playload_size = frame_size - 1;
    
    sound_format = (AudioFrameFormat)srs_utils_flv_audio_sound_format(frame, frame_size);
    sound_rate = (AudioFrameSoundRate)srs_utils_flv_audio_sound_rate(frame, frame_size);
    sound_size = (AudioFrameSoundSize)srs_utils_flv_audio_sound_size(frame, frame_size);
    sound_type = (AudioFrameSoundType)srs_utils_flv_audio_sound_type(frame, frame_size);
    
    if( sound_format == AFF_AAC ) {
        pStart++;
        playload_size--;
        
        aac_type = (AudioFrameAACType)srs_utils_flv_audio_aac_packet_type(frame, frame_size);
        if( aac_type == AAC_SEQUENCE_HEADER ) {
            // AAC类型包
            if( mpRtmpDumpCallback ) {
                mpRtmpDumpCallback->OnChangeAudioFormat(this, sound_format, sound_rate, sound_size, sound_type);
            }
            
        } else if( aac_type == AAC_RAW ) {
            // Callback for Audio Data
            if( mpRtmpDumpCallback ) {
                mpRtmpDumpCallback->OnRecvAudioFrame(this, sound_format, sound_rate, sound_size, sound_type, pStart, playload_size, timestamp);
            }
        }
    }

    return bFlag;
}

bool RtmpDump::Flv2Video(char* frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = false;
    
    if( frame_size > 1 ) {
        VideoFrameFormat video_format = (VideoFrameFormat)srs_utils_flv_video_codec_id(frame, frame_size);
        switch (video_format) {
            case VVF_AVC:{
                // H264
                bFlag = FlvVideo2H264(frame, frame_size, timestamp);
                
            }break;
            default:
                break;
        }
    }
    
    return bFlag;
}

bool RtmpDump::FlvVideo2H264(char* frame, int frame_size, u_int32_t timestamp) {
    bool bFlag = true;
    
    char *pStart = frame;
    char *pEnd = frame + frame_size;
    
    if(
       srs_utils_flv_video_frame_type(frame, frame_size) == 0x01 &&       // Key frame
       srs_utils_flv_video_codec_id(frame, frame_size) == 0x07 &&         // H264
       srs_utils_flv_video_avc_packet_type(frame, frame_size) == 0x0      // SPS/PPS
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
                if( mpSps != NULL ) {
                    if( mSpsSize == spsLen ) {
                        if( 0 != memcmp(mpSps, pStart, spsLen) ) {
                            bSpsChange = true;
                            
                        } else {
                            bSpsChange = false;
                            
                        }
                    }
                }
                
                if ( bSpsChange ) {
                    if( mpSps ) {
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
                if( mpPps != NULL ) {
                    if( mPpsSize == ppsLen ) {
                        if( 0 != memcmp(mpPps, pStart, spsLen) ) {
                            bPpsChange = true;
                            
                        } else {
                            bPpsChange = false;
                            
                        }
                    }
                }
                
                if ( bPpsChange ) {
                    if( mpPps ) {
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
            
            if( mpRtmpDumpCallback ) {
                mpRtmpDumpCallback->OnChangeVideoSpsPps(this, mpSps, mSpsSize, mpPps, mPpsSize, mNaluHeaderSize);
            }
            
        } else {
            // UnSupport version
            bFlag = false;
        }
        
    } else if (
               (
                srs_utils_flv_video_frame_type(frame, frame_size) == 0x01 ||	   // Key frame
                srs_utils_flv_video_frame_type(frame, frame_size) == 0x02		   // Inter frame
                ) &&
               srs_utils_flv_video_codec_id(frame, frame_size) == 0x07 &&          // H264
               srs_utils_flv_video_avc_packet_type(frame, frame_size) == 0x1       // NALU
               ) {
        if( mpSps && mpPps && mNaluHeaderSize != 0 ) {
            // Skip FLV video tag
            pStart = frame + 5;
            
            // Callback for Video
            if( mpRtmpDumpCallback ) {
                VideoFrameType type = VFT_UNKNOWN;
                if( srs_utils_flv_video_frame_type(frame, frame_size) == 0x01 ) {
                    type = VFT_IDR;
                } else if( srs_utils_flv_video_frame_type(frame, frame_size) == 0x02 ) {
                    type = VFT_NOTIDR;
                }
                mpRtmpDumpCallback->OnRecvVideoFrame(this, pStart, (int)(pEnd - pStart), timestamp, type);
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

bool RtmpDump::GetADTS(int packetSize, char* header, int headerSize) {
    bool bFlag = false;
    
    if( header != NULL && headerSize >= ADTS_HEADER_SIZE && headerSize > 0 ) {
        // Variables Recycled by addADTStoPacket
        int profile = 2;  //AAC LC
        
        // 39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
        int freqIdx = 4;  //44.1KHz
        int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
        int fullSize = ADTS_HEADER_SIZE + packetSize;
        
        // Fill in ADTS data
        header[0] = (char)0xFF; // 11111111     = syncword
        header[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
        header[2] = (char)(((profile - 1) << 6 ) + (freqIdx << 2) + (chanCfg >> 2));
        header[3] = (char)(((chanCfg & 3) << 6) + (fullSize >> 11));
        header[4] = (char)((fullSize & 0x7FF) >> 3);
        header[5] = (char)(((fullSize & 7) << 5) + 0x1F);
        header[6] = (char)0xFC;
        
        bFlag = true;
    }

    return bFlag;
}
    
void RtmpDump::CheckConnectRunnableHandle() {
    bool bBreak = false;
    long long startTime = (long long)getCurrentTime();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::CheckConnectRunnableHandle( "
                 "[Start], "
                 "this : %p "
                 ")",
                 this
                 );
    
    while (mbRunning) {
        mClientMutex.lock();
        if( mIsConnected ) {
            // 已经连接上服务器, 标记退出线程
            bBreak = true;
        } else {
            // 计算超时
            long long curTime = (long long)getCurrentTime();
            int diffTime = (int)(curTime - startTime);
            if( diffTime >= mConnectTimeout ) {
                // 超时, 断开连接
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "RtmpDump::CheckConnectRunnableHandle( "
                             "[Shutdown for connect timeout], "
                             "this : %p "
                             ")",
                             this
                             );
                
                if( mpRtmp ) {
                    srs_rtmp_shutdown(mpRtmp);
                }
                bBreak = true;
            }
        }
        mClientMutex.unlock();
        
        if( bBreak ) {
            break;
        }
        
        Sleep(100);
        
    }
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "RtmpDump::CheckConnectRunnableHandle( "
                 "[Exit], "
                 "this : %p "
                 ")",
                 this
                 );
}
}
