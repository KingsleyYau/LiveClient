

//
//  MediaFileReader.cpp
//  RtmpClient
//
//  Created by Max on 2020/5/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#include "MediaFileReader.h"
#include "ICodec.h"

#include <common/CommonFunc.h>

extern "C" {
#include <libavutil/imgutils.h>
#include <libavutil/samplefmt.h>
#include <libavformat/avformat.h>
}

// 预加载时间
#define PRE_READ_TIME_MS 500

namespace coollive {
// 文件读取线程
class MediaReaderRunnable : public KRunnable {
  public:
    MediaReaderRunnable(MediaFileReader *container) {
        mContainer = container;
    }
    virtual ~MediaReaderRunnable() {
        mContainer = NULL;
    }

  protected:
    void onRun() {
        mContainer->MediaReaderHandle();
    }

  private:
    MediaFileReader *mContainer;
};

MediaFileReader::MediaFileReader() : mRuningMutex(KMutex::MutexType_Recursive) {
    mContext = NULL;
    mpMediaReaderRunnable = new MediaReaderRunnable(this);

    mAudioStartTS = INVALID_TIMESTAMP;
    mAudioLastTS = INVALID_TIMESTAMP;
    
    mVideoStartTS = INVALID_TIMESTAMP;
    mVideoLastTS = INVALID_TIMESTAMP;
    
    mPlaybackRate = 1.0f;
    mPlaybackRateChange = false;
    mCacheMS = PRE_READ_TIME_MS;
    
    mbFinish = true;
}

MediaFileReader::~MediaFileReader() {
    Stop();

    if (mpMediaReaderRunnable) {
        delete mpMediaReaderRunnable;
        mpMediaReaderRunnable = NULL;
    }
}

bool MediaFileReader::PlayFile(const string &filePath) {
    bool bFlag = true;

    mRuningMutex.lock();
    if (mbRunning) {
        Stop();
    }

    mbFinish = false;
    mbRunning = true;
    mFilePath = filePath;

    mAudioStartTS = INVALID_TIMESTAMP;
    mAudioLastTS = INVALID_TIMESTAMP;

    mVideoStartTS = INVALID_TIMESTAMP;
    mVideoLastTS = INVALID_TIMESTAMP;

    // 开启文件读取线程
    mMediaReaderThread.Start(mpMediaReaderRunnable);

    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "MediaFileReader::PlayFile( "
                 "this : %p, "
                 "filePath : %s "
                 ")",
                 this,
                 filePath.c_str());

    return bFlag;
}

void MediaFileReader::Stop() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "MediaFileReader::Stop( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        mbRunning = false;

        // 停止文件读取线程
        mMediaReaderThread.Stop();
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "MediaFileReader::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

void MediaFileReader::SetMediaFileReaderCallback(MediaFileReaderCallback *callback) {
    mpCallback = callback;
}

void MediaFileReader::SetPlaybackRate(float playBackRate) {
    mPlaybackRate = playBackRate;
    mPlaybackRateChange = true;
}

void MediaFileReader::SetCacheMS(int cacheMS) {
    mCacheMS = cacheMS;
}

bool MediaFileReader::IsFinish() {
    return mbFinish;
}

void MediaFileReader::MediaReaderHandle() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "MediaFileReader::MediaReaderHandle( "
                 "this : %p, "
                 "[Start] "
                 ")",
                 this);

    while (mbRunning) {
        /* open input file, and allocate format context */
        if (avformat_open_input(&mContext, mFilePath.c_str(), NULL, NULL) < 0) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_ERR_USER,
                         "MediaFileReader::MediaReaderHandle( "
                         "this : %p, "
                         "[Counld Open Input File], "
                         "filePath : %s "
                         ")",
                         this,
                         mFilePath.c_str());
            break;
        }

        if (avformat_find_stream_info(mContext, NULL) >= 0) {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "MediaFileReader::MediaReaderHandle( "
                         "this : %p, "
                         "[Found Stream Info], "
                         "bit_rate : %lld b/s "
                         ")",
                         this,
                         mContext->bit_rate);
        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "MediaFileReader::MediaReaderHandle( "
                         "this : %p, "
                         "[Could Not Found Stream Info] "
                         ")",
                         this);
        }

        av_dump_format(mContext, 0, mFilePath.c_str(), 0);

        mAudioStreamIndex = av_find_best_stream(mContext, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
        AVCodecContext *audioCtx = NULL;
        if (mAudioStreamIndex >= 0) {
            audioCtx = mContext->streams[mAudioStreamIndex]->codec;
        }
        mVideoStreamIndex = av_find_best_stream(mContext, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
        if (mVideoStreamIndex >= 0) {
            AVStream *stream = mContext->streams[mVideoStreamIndex];
            double duration = 1.0 * stream->duration * stream->time_base.num / stream->time_base.den;
            int fps = (stream->avg_frame_rate.den != 0)?(stream->avg_frame_rate.num / stream->avg_frame_rate.den):0;
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "MediaFileReader::MediaReaderHandle( "
                         "this : %p, "
                         "[Video Stream Info], "
                         "duration : %.3f s, "
                         "nb_frames : %lld, "
                         "fps : %lld "
                         ")",
                         this,
                         duration,
                         stream->nb_frames,
                         fps
                         );

            if (mpCallback) {
                mpCallback->OnMediaFileReaderInfo(this, duration, fps);
            }
            
            AVCodecContext *videoCtx = mContext->streams[mVideoStreamIndex]->codec;
            unsigned char *extradata = (unsigned char *)videoCtx->extradata;
            unsigned char *extradata_end = (unsigned char *)videoCtx->extradata + videoCtx->extradata_size;
            if (videoCtx->extradata_size > 0) {
                if (videoCtx->codec_id == AV_CODEC_ID_H264) {
                    extradata += 4;

                    int sps_byte_size = (*extradata++ & 0x3) + 1;
                    int sps_count = *extradata++ & 0x1f;
                    int sps_size = (extradata[0] << 8) | extradata[1];
                    extradata += 2;

                    if (extradata_end - extradata < sps_size) {
                        FileLevelLog("rtmpdump",
                                     KLog::LOG_WARNING,
                                     "MediaFileReader::MediaReaderHandle( "
                                     "this : %p, "
                                     "[Error SPSP] "
                                     ")",
                                     this);
                        break;
                    }

                    char sps[1024] = {0};
                    memcpy(sps, extradata, sps_size);
                    extradata += sps_size;

                    int pps_count = *extradata++;
                    int pps_size = (extradata[0] << 8) | extradata[1];
                    extradata += 2;

                    if (extradata_end - extradata < pps_size) {
                        FileLevelLog("rtmpdump",
                                     KLog::LOG_WARNING,
                                     "MediaFileReader::MediaReaderHandle( "
                                     "this : %p, "
                                     "[Error PPS] "
                                     ")",
                                     this);
                        break;
                    }
                    char pps[1024] = {0};
                    memcpy(pps, extradata, pps_size);

                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "MediaFileReader::MediaReaderHandle( "
                                 "this : %p, "
                                 "[Read H264 Video SPS/PPS], "
                                 "sps_count : %d, "
                                 "sps_size : %d, "
                                 "pps_count : %d, "
                                 "pps_size : %d "
                                 ")",
                                 this,
                                 sps_count,
                                 sps_size,
                                 pps_count,
                                 pps_size);

                    if (mpCallback) {
                        mpCallback->OnMediaFileReaderChangeSpsPps(this, (const char *)sps, sps_size, (const char *)pps, pps_size);
                    }
                } else if (videoCtx->codec_id == AV_CODEC_ID_HEVC) {
                    unsigned char *vps = NULL;
                    int vps_size = 0;
                    unsigned char *sps = NULL;
                    int sps_size = 0;
                    unsigned char *pps = NULL;
                    int pps_size = 0;

                    extradata += 22;
                    int arrayCount = *extradata;
                    extradata++;
                    for (int i = 0; i < arrayCount; i++) {
                        unsigned char naluType = extradata[0];
                        extradata++;
                        unsigned short naluCount = extradata[0] << 16 | extradata[1];
                        extradata += 2;
                        for (int j = 0; j < naluCount; j++) {
                            unsigned short naluSize = extradata[0] << 16 | extradata[1];
                            extradata += 2;

                            if ((naluType & 0x3F) == 0x20) {
                                // VPS
                                vps = extradata;
                                vps_size = naluSize;
                            } else if ((naluType & 0x3F) == 0x21) {
                                // SPS
                                sps = extradata;
                                sps_size = naluSize;
                            } else if ((naluType & 0x3F) == 0x22) {
                                // PPS
                                pps = extradata;
                                pps_size = naluSize;
                            }
                            
                            extradata += naluSize;
                        }
                    }

                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "MediaFileReader::MediaReaderHandle( "
                                 "this : %p, "
                                 "[Read HEVC Video VPS/SPS/PPS], "
                                 "vps_size : %d, "
                                 "sps_size : %d, "
                                 "pps_size : %d "
                                 ")",
                                 this,
                                 vps_size,
                                 sps_size,
                                 pps_size);

                    if (mpCallback) {
                        mpCallback->OnMediaFileReaderChangeSpsPps(this, (const char *)sps, sps_size, (const char *)pps, pps_size, (const char *)vps, vps_size);
                    }
                } else {
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "MediaFileReader::MediaReaderHandle( "
                                 "this : %p, "
                                 "[UnSupport Codec Format], "
                                 "%d "
                                 ")",
                                 this,
                                 videoCtx->codec_id);
                    break;
                }
            }
        }

        AVPacket pkt;
        av_init_packet(&pkt);
        pkt.data = NULL;
        pkt.size = 0;

        AVFrame *frame = NULL;
        int ret = 0, got_frame = 0;

        bool bRead = true;

        // 开始播放时间
        long long startTime = getCurrentTime();
        long long now;

        while (mbRunning) {
            now = getCurrentTime();
            int64_t deltaTime = (unsigned int)(now - startTime);
            int64_t deltaTS = 0;
            bRead = true;
            
            if (mPlaybackRateChange) {
                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                             "MediaFileReader::MediaReaderHandle( "
                             "this : %p, "
                             "[Change Playback Rate] "
                             ")",
                             this);

                mPlaybackRateChange = false;

                startTime = getCurrentTime();

                mAudioStartTS = INVALID_TIMESTAMP;
                mAudioLastTS = INVALID_TIMESTAMP;
                
                mVideoStartTS = INVALID_TIMESTAMP;
                mVideoLastTS = INVALID_TIMESTAMP;
            }

            if (mVideoStartTS == INVALID_TIMESTAMP && mAudioStartTS == INVALID_TIMESTAMP) {
                bRead = true;
            } else {
                int64_t deltaAudioTS = (mAudioStartTS == INVALID_TIMESTAMP)?0:(mAudioLastTS - mAudioStartTS);
                int64_t deltaVideoTS = (mVideoStartTS == INVALID_TIMESTAMP)?0:(mVideoLastTS - mVideoStartTS);

                if (mVideoStreamIndex >= 0 && mAudioStreamIndex >= 0) {
                    deltaTS = MIN(deltaAudioTS, deltaVideoTS);
                } else if (mVideoStreamIndex >= 0) {
                    deltaTS = deltaVideoTS;
                } else if (mAudioStreamIndex >= 0) {
                    deltaTS = deltaAudioTS;
                }
            }

            int64_t delta = deltaTime + mCacheMS;
            deltaTS = deltaTS / mPlaybackRate;
            if ( bRead && (delta < deltaTS) ) {
                bRead = false;
            }

            if (bRead) {
                int ret = av_read_frame(mContext, &pkt);

                int pts = pkt.pts * 1000 * av_q2d(mContext->streams[pkt.stream_index]->time_base);
                int dts = pkt.dts * 1000 * av_q2d(mContext->streams[pkt.stream_index]->time_base);
                
                double time = 0;
                if (pkt.stream_index == mVideoStreamIndex) {
                    time = (pts - mVideoStartTS) / 1000.0;
                } else {
                    time = (pts - mAudioStartTS) / 1000.0;
                }
                
                FileLevelLog("rtmpdump",
                             KLog::LOG_MSG,
                             "MediaFileReader::MediaReaderHandle( "
                             "this : %p, "
                             "[Read Packet %s %s], "
                             "deltaTime : %u, "
                             "deltaTS : %u, "
                             "dts : %d, "
                             "pts : %d, "
                             "time : %.3f second, "
                             "av_q2d : %f, "
                             "size : %d "
                             ")",
                             this,
                             pkt.stream_index == mVideoStreamIndex ? "Video" : "Audio",
                             (pkt.flags & AV_PKT_FLAG_KEY) ? "IDR Frame" : "Non-IDR Frame",
                             deltaTime,
                             deltaTS,
                             dts,
                             pts,
                             time,
                             av_q2d(mContext->streams[pkt.stream_index]->time_base),
                             pkt.size
                             );
                
                if (pkt.stream_index == mVideoStreamIndex) {
                    VideoFrameType video_type;
                    video_type = (pkt.flags & AV_PKT_FLAG_KEY) ? VFT_IDR : VFT_NOTIDR;

                    if (mpCallback) {
                        mpCallback->OnMediaFileReaderVideoFrame(this, (const char *)pkt.data, pkt.size, dts, pts, video_type);
                    }

                    if (mVideoStartTS == INVALID_TIMESTAMP) {
                        mVideoStartTS = pts;
                    }
                    
                    mVideoLastTS = pts;

                } else if (pkt.stream_index == mAudioStreamIndex) {
                    if (mpCallback) {
                        mpCallback->OnMediaFileReaderAudioFrame(this, (const char *)pkt.data, pkt.size, pts,
                                                                AFF_AAC, AFSR_KHZ_44, AFSS_BIT_16, (audioCtx->channels == 2) ? AFST_STEREO : AFST_MONO);
                    }

                    if (mAudioStartTS == INVALID_TIMESTAMP) {
                        mAudioStartTS = pts;
                    }
                    
                    mAudioLastTS = pts;
                }

                av_packet_unref(&pkt);
                
                if (ret < 0) {
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_ERR_USER,
                                 "MediaFileReader::MediaReaderHandle( "
                                 "this : %p, "
                                 "[Read Packet Finish], "
                                 "ret : %d "
                                 ")",
                                 this,
                                 ret);
                    break;
                }
                Sleep(1);
            } else {
                Sleep(1);
            }
        }

        break;
    }

    avformat_close_input(&mContext);
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "MediaFileReader::MediaReaderHandle( "
                 "this : %p, "
                 "[Exit] "
                 ")",
                 this);
    
    mbFinish = true;
}

bool MediaFileReader::CombineFile(const vector<string>& srcFilePaths, const string& dstFilePath) {
    bool bFlag = false;
    
    int err, ret;
    char errbuf[128];
    const char *errbuf_ptr = errbuf;
    
    const string &output = dstFilePath;
    AVFormatContext *oc;
    bool opened = false;
    
    err = avformat_alloc_output_context2(&oc, NULL, NULL, output.c_str());
    if (oc) {
        AVStream *os_v = avformat_new_stream(oc, NULL);
        AVStream *os_a = avformat_new_stream(oc, NULL);
        bool os_v_copy = false;
        bool os_a_copy = false;
        
        for(int i = 0; i < (int)srcFilePaths.size(); i++) {
            const string &input = srcFilePaths[i];
            AVFormatContext *ic;
            
            ic = avformat_alloc_context();
            ic->flags |= AVFMT_FLAG_KEEP_SIDE_DATA;
            ic->flags |= AVFMT_FLAG_NONBLOCK;
            
            err = avformat_open_input(&ic, input.c_str(), NULL, NULL);
            if (err < 0) {
                if (av_strerror(err, errbuf, sizeof(errbuf)) < 0) {
                    errbuf_ptr = strerror(AVUNERROR(err));
                }
            }
            
            ret = avformat_find_stream_info(ic, NULL);
            if (ret < 0) {
                av_log(NULL, AV_LOG_FATAL, "%s: could not find codec parameters\n", input.c_str());
                if (ic->nb_streams == 0) {
                    avformat_close_input(&ic);
                }
            }
            av_dump_format(ic, ic->nb_streams - 1, input.c_str(), 0);
            
            AVCodecContext *ctx = avcodec_alloc_context3(NULL);
            AVCodecParameters *par = avcodec_parameters_alloc();
            
            for(int i = 0; i < ic->nb_streams; i++) {
                AVStream *is = ic->streams[i];
                AVStream *os;
                if (is->codecpar->codec_type != AVMEDIA_TYPE_VIDEO && is->codecpar->codec_type != AVMEDIA_TYPE_AUDIO ) {
                    continue;
                }
                
                if( !os_v_copy && is->codecpar->codec_type == AVMEDIA_TYPE_VIDEO ) {
                    os = os_v;
                } else if( !os_a_copy && is->codecpar->codec_type == AVMEDIA_TYPE_AUDIO ) {
                    os = os_a;
                } else {
                    continue;
                }
                
                ret = avcodec_parameters_to_context(ctx, is->codecpar);
                ret = avcodec_parameters_from_context(par, ctx);
                
                uint32_t codec_tag = os->codecpar->codec_tag;
                if (!codec_tag) {
                    unsigned int codec_tag_tmp;
                    if (!oc->oformat->codec_tag ||
                        av_codec_get_id (oc->oformat->codec_tag, par->codec_tag) == par->codec_id ||
                        !av_codec_get_tag2(oc->oformat->codec_tag, par->codec_id, &codec_tag_tmp))
                        codec_tag = par->codec_tag;
                }
                
                if ( !opened ) {
                    ret = avcodec_parameters_copy(os->codecpar, is->codecpar);
                    if (ret < 0) {
                        if (av_strerror(err, errbuf, sizeof(errbuf)) < 0) {
                            errbuf_ptr = strerror(AVUNERROR(err));
                        }
                    }
                    os->codecpar->codec_tag = codec_tag;
                    
                    ret = avformat_transfer_internal_stream_timing_info(oc->oformat, os, is, AVFMT_TBCF_AUTO);
                    if (av_strerror(err, errbuf, sizeof(errbuf)) < 0) {
                        errbuf_ptr = strerror(AVUNERROR(err));
                    }
                }
            }
            
            if ( !opened ) {
                av_dump_format(oc, oc->nb_streams - 1, output.c_str(), 1);

                ret = avio_open(&oc->pb, output.c_str(), AVIO_FLAG_WRITE);
                ret = avformat_write_header(oc, NULL);
                if (ret < 0) {
                    if (av_strerror(err, errbuf, sizeof(errbuf)) < 0) {
                        errbuf_ptr = strerror(AVUNERROR(err));
                    }
                }
            }
            opened = true;
            
            AVPacket *pkt = av_packet_alloc();
            while (av_read_frame(ic, pkt) >= 0) {
                AVStream *is = ic->streams[pkt->stream_index];
                AVStream *os;
                if (is->codecpar->codec_type == AVMEDIA_TYPE_VIDEO ) {
                    os = os_v;
                } else if ( is->codecpar->codec_type == AVMEDIA_TYPE_AUDIO ) {
                    os = os_a;
                } else {
                    continue;
                }
                
                av_packet_rescale_ts(pkt, is->time_base, os->time_base);
                ret = av_interleaved_write_frame(oc, pkt);
            }
            
            avformat_close_input(&ic);
            av_free(ic);
            
            av_free(ctx);
            avcodec_parameters_free(&par);
        }
        
        av_write_trailer(oc);
        avio_close(oc->pb);
        av_free(oc);
    }
    
    return bFlag;
}

}
