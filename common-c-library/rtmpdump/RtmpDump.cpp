//
//  RtmpDump.cpp
//  RtmpClient
//
//  Created by Max on 2017/4/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "RtmpDump.h"

#include <sys/time.h>

#include <netdb.h>
#include <netinet/tcp.h>
#include <netinet/in.h>

#define DEFAULT_VIDEO_FRAME_SIZE 65535
#define DEFAULT_AUDIO_FRAME_SIZE DEFAULT_VIDEO_FRAME_SIZE

#define ADTS_HEADER_SIZE 7

static char NaluStartCode[] = {0x00, 0x00, 0x00, 0x01};

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
        mContainer->ReadPackage();
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
    mRecordH264FilePath = "";
    mpRecordH264File = NULL;
    mpRecordH264FullFile = NULL;
    mRecordAACFilePath = "";
    mpRecordAACFile = NULL;
    
    mpSps = NULL;
    mSpsSize = 0;
    
    mpPps = NULL;
    mPpsSize = 0;
    
    mNaluHeaderSize = 0;
    
    mSendVideoFrameTimestamp = 0;
    mSendAudioFrameTimestamp = 0;
    
    mpRecvRunnable = new RecvRunnable(this);
    
//    mTempVideoBufferSize = DEFAULT_VIDEO_FRAME_SIZE;
//    mpTempVideoBuffer = NULL;
//    mpTempVideoBuffer = new char[mTempVideoBufferSize];
    
    mTempAudioBufferSize = DEFAULT_AUDIO_FRAME_SIZE;
    mpTempAudioBuffer = new char[mTempAudioBufferSize];

    mTempAudioRecvBufferSize = DEFAULT_AUDIO_FRAME_SIZE;
    mpTempAudioRecvBuffer = new char[mTempAudioRecvBufferSize];
}

RtmpDump::~RtmpDump() {
    Stop();
    
    if( mpRecvRunnable ) {
        delete mpRecvRunnable;
    }
    
//    if( mpTempVideoBuffer ) {
//        delete[] mpTempVideoBuffer;
//    }
    
    if( mpTempAudioBuffer ) {
        delete[] mpTempAudioBuffer;
    }
    
    if( mpTempAudioRecvBuffer ) {
        delete[] mpTempAudioRecvBuffer;
    }
}

void RtmpDump::SetCallback(RtmpDumpCallback* callback) {
    mpRtmpDumpCallback = callback;
}

bool RtmpDump::PlayUrl(const string& url, const string& recordFilePath, const string& recordH264FilePath, const string& recordAACFilePath) {
    bool bFlag = false;
    
//    FileLog("rtmpdump", "RtmpDump::PlayUrl( "
//    		"this : %p, "
//            "url : %s "
//            ")",
//			this,
//            url.c_str()
//            );
    
    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    mpRtmp = srs_rtmp_create(url.c_str());
    
    bFlag = (0 == srs_rtmp_handshake(mpRtmp));
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::PlayUrl( [srs_rtmp_handshake fail] )");
    }
    
    bFlag = (bFlag && (0 == srs_rtmp_connect_app(mpRtmp)));
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::PlayUrl( [srs_rtmp_connect_app fail] )");
    }
    
    bFlag = (bFlag && (0 == srs_rtmp_play_stream(mpRtmp)));
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::PlayUrl( [srs_rtmp_play_stream fail] )");
    }
    
    if( bFlag ) {
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
                FileLog("rtmpdump", "RtmpDump::PlayUrl( [Write flv file header fail], recordFilePath : %s )", mRecordH264FilePath.c_str());
                
            }
        }
        
        // 创建H264文件
        mRecordH264FilePath = recordH264FilePath;
        mpRecordH264File = fopen(mRecordH264FilePath.c_str(), "w+b");
        if( mpRecordH264File ) {
            fseek(mpRecordH264File, 0L, SEEK_END);
        }
        string h264FullPath = recordH264FilePath + ".h264";
        mpRecordH264FullFile = fopen(h264FullPath.c_str(), "w+b");
        if( mpRecordH264FullFile ) {
            fseek(mpRecordH264FullFile, 0L, SEEK_END);
        }		
        
        // 创建AAC文件
        mRecordAACFilePath = recordAACFilePath;
        mpRecordAACFile = fopen(mRecordAACFilePath.c_str(), "w+b");
        if( mpRecordAACFile ) {
            fseek(mpRecordAACFile, 0L, SEEK_END);
        }
        
        mbRunning = true;
        mRecvThread.Start(mpRecvRunnable);
        
//        FileLog("rtmpdump", "RtmpDump::PlayUrl( "
//        		"this : %p, "
//        		"[Success], "
//                "url : %s, "
//                "mpRtmp : %p "
//                ")",
//				this,
//                url.c_str(),
//				mpRtmp
//                );

    } else {
        Stop();
    }
    
    mClientMutex.unlock();
    
    return bFlag;
}

bool RtmpDump::PublishUrl(const string& url, const string& recordFilePath, const string& recordAACFilePath) {
    bool bFlag = false;
    
//    FileLog("rtmpdump", "RtmpDump::PublishUrl( "
//    		"this : %p, "
//            "url : %s "
//            ")",
//			this,
//            url.c_str()
//            );
    
    mClientMutex.lock();
    if( mbRunning ) {
        Stop();
    }
    
    mpRtmp = srs_rtmp_create(url.c_str());
    
    bFlag = (0 == srs_rtmp_handshake(mpRtmp));
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::PublishUrl( [srs_rtmp_handshake fail] )");
    }
    
    bFlag = (bFlag && (0 == srs_rtmp_connect_app(mpRtmp)));
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::PublishUrl( [srs_rtmp_connect_app fail] )");
    }
    
    bFlag = (bFlag && (0 == srs_rtmp_publish_stream(mpRtmp)));
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::PublishUrl( [srs_rtmp_publish_stream fail] )");
    }
    
    if( bFlag ) {
        mRecordH264FilePath = recordFilePath;
        if( mRecordH264FilePath.length() > 0 ) {
            mpRecordH264File = fopen(mRecordH264FilePath.c_str(), "w+b");
            if( mpRecordH264File ) {
                fseek(mpRecordH264File, 0L, SEEK_END);
            }
        }
        
        mRecordAACFilePath = recordAACFilePath;
        if( mRecordAACFilePath.length() > 0 ) {
            mpRecordAACFile = fopen(mRecordAACFilePath.c_str(), "w+b");
            if( mpRecordAACFile ) {
                fseek(mpRecordAACFile, 0L, SEEK_END);
            }
        }
    
        mSendVideoFrameTimestamp = 0;
        mSendAudioFrameTimestamp = 0;
        
        mbRunning = true;
        mRecvThread.Start(mpRecvRunnable);
        
//        FileLog("rtmpdump", "RtmpDump::PublishUrl( "
//        		"this : %p, "
//        		"[Success], "
//                "url : %s, "
//                "mpRtmp : %p "
//                ")",
//				this,
//                url.c_str(),
//				mpRtmp
//                );

    } else {
        Stop();
    }
    
    mClientMutex.unlock();
    
    return bFlag;
}

void RtmpDump::ReadPackage() {    
//    int64_t nb_packets = 0;
    u_int32_t pre_timestamp = 0;
    int64_t pre_now = -1;
    int64_t start_time = -1;
    
    char type;
    u_int32_t timestamp = 0;
    char* frame = NULL;
    int frame_size = 0;
    
    FileLog("rtmpdump", "RtmpDump::ReadPackage( "
    		"[Start], "
    		"this : %p "
    		")",
			this
			);
    
    while( mbRunning && 0 == srs_rtmp_read_packet(mpRtmp, &type, &timestamp, &frame, &frame_size) ) {
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
            FileLog("RtmpDump", "RtmpDump::OnRecvVideoFrame(\t\ttimestamp : %d, size : %d )", timestamp, frame_size);
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
//                    FileLog("RtmpDump", "RtmpDump::ReadPackage( dump rtmp packet failed )");
                }
            } else {
//                FileLog("RtmpDump", "RtmpDump::ReadPackage( drop message type=%#x, size=%dB )", type, frame_size);
            }
        }
        
        free(frame);
    }
    
    FileLog("rtmpdump", "RtmpDump::ReadPackage( "
    		"[Exit], "
    		"this : %p "
    		")",
			this
			);
    
    if( mpRtmpDumpCallback ) {
        mpRtmpDumpCallback->OnDisconnect(this);
    }
}

bool RtmpDump::SendVideoFrame(char* frame, int frame_size) {
    bool bFlag = false;
    int ret = 0;
//    int nb_start_code = 0;
    
    char* sendFrame = frame;
    int sendSize = frame_size;
    
//    if( mTempVideoBufferSize < frame_size + 4 ) {
//        if( mpTempVideoBuffer ) {
//            delete[] mpTempVideoBuffer;
//            mpTempVideoBuffer = NULL;
//        }
//        
//        mTempVideoBufferSize = frame_size + 4;
//        mpTempVideoBuffer = new char[mTempVideoBufferSize];
//    }
    
    mClientMutex.lock();
    if( mbRunning && mpRtmp ) {
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
        
        // 因为没有B帧, 所以dts和pts一样就可以
//        FileLog("rtmpdump", "RtmpDump::SendVideoFrame( mSendVideoFrameTimestamp : %d )", mSendVideoFrameTimestamp);
        ret = srs_h264_write_raw_frame_without_startcode(mpRtmp, sendFrame, sendSize, mSendVideoFrameTimestamp, mSendVideoFrameTimestamp);
        if (ret != 0) {
            bFlag = true;
            
            if (srs_h264_is_dvbsp_error(ret)) {
                FileLog("rtmpdump", "RtmpDump::SendVideoFrame( ignore drop video error, code=%d )", ret);
                
            } else if (srs_h264_is_duplicated_sps_error(ret)) {
//                FileLog("rtmpdump", "ignore duplicated sps, code=%d", ret);
                
            } else if (srs_h264_is_duplicated_pps_error(ret)) {
//                FileLog("rtmpdump", "ignore duplicated pps, code=%d", ret);
                
            } else {
                bFlag = false;
            }
            
        } else {
            bFlag = true;
        }
        
    }
    mClientMutex.unlock();
    
    if( !bFlag ) {
        FileLog("rtmpdump", "RtmpDump::SendVideoFrame( send h264 raw data failed. ret=%d )", ret);
        
        srs_rtmp_shutdown(mpRtmp);
        
    } else {
        // 5bits, 7.3.1 NAL unit syntax,
        // H.264-AVC-ISO_IEC_14496-10.pdf, page 44.
        //  7: SPS, 8: PPS, 5: I Frame, 1: P Frame, 9: AUD, 6: SEI
//        u_int8_t nut = (char)frame[nb_start_code] & 0x1f;
//        FileLog("RtmpDump", "sent packet: type=%s, time=%d, size=%d, b[%d]=%#x(%s)",
//                        srs_human_flv_tag_type2string(SRS_RTMP_TYPE_VIDEO), mSendVideoFrameTimestamp, frame_size, nb_start_code, (char)frame[nb_start_code],
//                        (nut == 7? "SPS":(nut == 8? "PPS":(nut == 5? "I":(nut == 1? "P":(nut == 9? "AUD":(nut == 6? "SEI":"Unknown")))))));
        
        // Write to H264 file
        if( mpRecordH264File ) {
            fwrite(sendFrame, 1, sendSize, mpRecordH264File);
            
            fflush(mpRecordH264File);
        }
        
    }

    return bFlag;
}

void RtmpDump::AddVideoTimestamp(u_int32_t timestamp) {
    mSendVideoFrameTimestamp += timestamp;
}

bool RtmpDump::SendAudioFrame(
                              AudioFrameFormat sound_format,
                              AudioFrameSoundRate sound_rate,
                              AudioFrameSoundSize sound_size,
                              AudioFrameSoundType sound_type,
                              char* frame,
                              int frame_size
                              ) {
    bool bFlag = false;
    int ret = 0;
    
    if( mTempAudioBufferSize < frame_size + ADTS_HEADER_SIZE ) {
        if( mpTempAudioBuffer ) {
            delete[] mpTempAudioBuffer;
            mpTempAudioBuffer = NULL;
        }
        
        mTempAudioBufferSize = frame_size + ADTS_HEADER_SIZE;
        mpTempAudioBuffer = new char[mTempAudioBufferSize];
    }
    
    // 增加ADTS数据头(Audio Data Transport Stream 音频数据传输流)
    if( GetADTS(frame_size, mpTempAudioBuffer, ADTS_HEADER_SIZE) ) {
        // 音频内容
        memcpy(mpTempAudioBuffer + ADTS_HEADER_SIZE, frame, frame_size);
        
        mClientMutex.lock();
        if( mbRunning && mpRtmp ) {
//            FileLog("rtmpdump", "RtmpDump::SendAudioFrame( mSendAudioFrameTimestamp : %d )", mSendAudioFrameTimestamp);
            if( (ret = srs_audio_write_raw_frame(mpRtmp, sound_format, sound_rate, sound_size, sound_type, mpTempAudioBuffer, ADTS_HEADER_SIZE + frame_size, mSendAudioFrameTimestamp)) == 0 ) {
                bFlag = true;
                
            }
        }
        mClientMutex.unlock();
        
        if( !bFlag ) {
            FileLog("rtmpdump", "RtmpDump::SendAudioFrame( send audio raw data failed. ret=%d )", ret);
            
        } else {
            
            // Write to AAC file
            if( mpRecordAACFile ) {
                fwrite(mpTempAudioBuffer, 1, ADTS_HEADER_SIZE + frame_size, mpRecordAACFile);
                
                fflush(mpRecordAACFile);
            }
        }
    }
    
    return bFlag;
}

void RtmpDump::AddAudioTimestamp(u_int32_t timestamp) {
    mSendAudioFrameTimestamp += timestamp;
}

void RtmpDump::Stop() {
//    FileLog("rtmpdump", "RtmpDump::Stop( "
//    		"this : %p, "
//    		"mpRtmp : %p "
//    		")",
//			this,
//			mpRtmp
//    		);

    mClientMutex.lock();
    
    if( mbRunning ) {
        mbRunning = false;
        
        if( mpRtmp ) {
        	srs_rtmp_shutdown(mpRtmp);
        }
        
        mRecvThread.Stop();
        
        Destroy();
    }

    mClientMutex.unlock();
    
//    FileLog("rtmpdump", "RtmpDump::Stop( "
//            "[Success], "
//            "this : %p "
//            ")",
//            this
//            );

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
    
    // 关闭H264文件
    if( mpRecordH264File ) {
        fclose(mpRecordH264File);
        mpRecordH264File = NULL;
    }

    // 关闭AAC文件
    if( mpRecordAACFile ) {
        fclose(mpRecordAACFile);
        mpRecordAACFile = NULL;
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
            // Callback for ADTS
            if( mpRtmpDumpCallback ) {
                mpRtmpDumpCallback->OnChangeAudioFormat(this, sound_format, sound_rate, sound_size, sound_type);
            }
        } else if( aac_type == AAC_RAW ) {
            if( mTempAudioRecvBufferSize < playload_size + ADTS_HEADER_SIZE ) {
                if( mpTempAudioRecvBuffer ) {
                    delete[] mpTempAudioRecvBuffer;
                    mpTempAudioRecvBuffer = NULL;
                }
                
                mTempAudioRecvBufferSize = playload_size + ADTS_HEADER_SIZE;
                mpTempAudioRecvBuffer = new char[mTempAudioRecvBufferSize];
            }
            
            // 增加ADTS数据头(Audio Data Transport Stream 音频数据传输流)
            if( GetADTS(playload_size, mpTempAudioRecvBuffer, ADTS_HEADER_SIZE) ) {
                // 音频内容
                memcpy(mpTempAudioRecvBuffer + ADTS_HEADER_SIZE, pStart, playload_size);
                
                // Write to AAC file
                if( mpRecordAACFile ) {
                    fwrite(mpTempAudioRecvBuffer, 1, ADTS_HEADER_SIZE + playload_size, mpRecordAACFile);
                    
                    fflush(mpRecordAACFile);
                }
                
                // Callback for Audio Data
                if( mpRtmpDumpCallback ) {
                    mpRtmpDumpCallback->OnRecvAudioFrame(this, sound_format, sound_rate, sound_size, sound_type, mpTempAudioRecvBuffer, ADTS_HEADER_SIZE + playload_size, timestamp);
                }
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
                
                if (mpSps == NULL) {
                    mSpsSize = spsLen;
                    mpSps = new char[mSpsSize];
                    memcpy(mpSps, pStart, mSpsSize);
                    
                    // Write to H264 file
                    if( mpRecordH264File ) {
                        // Write NALU start code
                        fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264File);
                        
                        // Write playload
                        fwrite(mpSps, 1, mSpsSize, mpRecordH264File);
                        
                        fflush(mpRecordH264File);
                    }
                    
//                    if (mpRecordH264FullFile) {
//                        // Write NALU start code
//                        fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264FullFile);
//                        
//                        // Write playload
//                        fwrite(mpSps, 1, mSpsSize, mpRecordH264FullFile);
//                        
//                        fflush(mpRecordH264FullFile);
//                    }
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
                
                if (mpPps == NULL) {
                    mPpsSize = ppsLen;
                    mpPps = new char[mPpsSize];
                    memcpy(mpPps, pStart, mPpsSize);
                    
                    // Write to H264 file
                    if( mpRecordH264File ) {
                        // Write NALU start code
                        fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264File);
                        
                        // Write playload
                        fwrite(mpPps, 1, mPpsSize, mpRecordH264File);
                        
                        fflush(mpRecordH264File);
                    }
                    
//                    if (mpRecordH264FullFile) {
//                        // Write NALU start code
//                        fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264FullFile);
//                        
//                        // Write playload
//                        fwrite(mpSps, 1, mSpsSize, mpRecordH264FullFile);
//                        
//                        fflush(mpRecordH264FullFile);
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
            int NaluSize = 0;
            char* NaluHeader = NULL;
            char* NaluBody = NULL;
            
            while( ((pEnd - pStart) > 0) && bFlag ) {
                NaluSize = 0;
                NaluHeader = pStart;
                NaluBody = NaluHeader + mNaluHeaderSize;
                
                // 获取每一个NALU大小
                switch (mNaluHeaderSize) {
                    case 1: {
                        NaluSize = *(char *)NaluHeader;
                    }break;
                    case 2: {
                        short* pNaluSize = (short *)NaluHeader;
                        NaluSize = ntohs(*pNaluSize);

                    }break;
                    case 4: {
                        int* pNaluSize = (int *)NaluHeader;
                        NaluSize = ntohl(*pNaluSize);

                    }break;
                    default:{
                        bFlag = false;
                    }break;
                }
                
                if( NaluSize > 0 && (pEnd - (pStart + mNaluHeaderSize + NaluSize) >= 0) ) {
                    // 每个NALU第一个字节的前5位标明的是该NAL包的类型，即nal_unit_type, 只需要IDR Picture帧和Non-IDR Picture帧才解码
                    char nal_unit_type = NaluBody[0] & 0x1f;
//                    FileLog("rtmpdump",
//                    		"RtmpDump::FlvVideo2H264( "
//                    		"nal_unit_type : %d, "
//                    		"frameSize : %d "
//                    		")",
//							nal_unit_type,
//							mNaluHeaderSize + NaluSize
//							);

                    if( nal_unit_type == 1 || 		// Non-IDR
                    		nal_unit_type == 5 		// IDR
							) {
                        // Callback for Video
                        if( mpRtmpDumpCallback ) {
                            mpRtmpDumpCallback->OnRecvVideoFrame(this, NaluHeader, mNaluHeaderSize + NaluSize, timestamp, (VideoFrameType)nal_unit_type);
                        }
                        
                        // Write to H264 file
                        if( mpRecordH264File ) {
                            // Write NALU start code
                            fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264File);
                            
                            // Write playload
                            fwrite(NaluBody, 1, NaluSize, mpRecordH264File);
                            
                            fflush(mpRecordH264File);
                        }
                        
//                        if (mpRecordH264FullFile) {
//                            // Write NALU start code
//                            fwrite(NaluStartCode, 1, sizeof(NaluStartCode), mpRecordH264FullFile);
//                            
//                            // Write playload
//                            fwrite(NaluHeader, 1, mNaluHeaderSize + NaluSize, mpRecordH264File);
//                            
//                            fflush(mpRecordH264FullFile);
//                        }
                    }
                    
                    // 寻找下一帧开头
                    pStart += mNaluHeaderSize + NaluSize;
                    
                } else {
                    bFlag = false;
                }
                
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
    
    if( header != NULL && headerSize >= ADTS_HEADER_SIZE ) {
        // Variables Recycled by addADTStoPacket
        int profile = 2;  //AAC LC
        
        // 39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
        int freqIdx = 4;  //44.1KHz
        int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
        int fullSize = ADTS_HEADER_SIZE + packetSize;
        
        // Fill in ADTS data
        header[0] = (char)0xFF; // 11111111     = syncword
        header[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
        header[2] = (char)(((profile - 1) <<6 ) + (freqIdx<<2) +(chanCfg>>2));
        header[3] = (char)(((chanCfg & 3) << 6) + (fullSize>>11));
        header[4] = (char)((fullSize & 0x7FF) >> 3);
        header[5] = (char)(((fullSize & 7) << 5) + 0x1F);
        header[6] = (char)0xFC;
        
        bFlag = true;
    }

    return bFlag;
}
