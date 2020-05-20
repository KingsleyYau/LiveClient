

//
//  MediaFileReader.cpp
//  RtmpClient
//
//  Created by Max on 2020/5/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#include "MediaFileReader.h"

extern "C" {
#include <libavutil/imgutils.h>
#include <libavutil/samplefmt.h>
#include <libavutil/timestamp.h>
#include <libavformat/avformat.h>
}

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
}

MediaFileReader::~MediaFileReader() {
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

    mbRunning = true;
    mFilePath = filePath;

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
                 KLog::LOG_MSG,
                 "MediaFileReader::Stop( "
                 "this : %p "
                 ")",
                 this);

    mRuningMutex.lock();
    if (mbRunning) {
        mbRunning = false;

        // 停止文件读取线程
        mMediaReaderThread.Stop();

        if (mContext != NULL) {
            avformat_close_input(&mContext);
            mContext = NULL;
        }
    }
    mRuningMutex.unlock();

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "MediaFileReader::Stop( "
                 "this : %p, "
                 "[Success] "
                 ")",
                 this);
}

void MediaFileReader::SetMediaFileReaderCallback(MediaFileReaderCallback *callback) {
    mpCallback = callback;
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
                         KLog::LOG_MSG,
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
                         KLog::LOG_MSG,
                         "MediaFileReader::MediaReaderHandle( "
                         "[Found Stream Info], "
                         "duration : %d second, "
                         "bit_rate : %d kb/s "
                         ")",
                         this,
                         mContext->duration,
                         mContext->bit_rate);
        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "MediaFileReader::MediaReaderHandle( "
                         "this : %p, "
                         "[Could Not Found Stream Info] "
                         ")",
                         this);
        }

        av_dump_format(mContext, 0, mFilePath.c_str(), 0);

        mAudioStreamIndex = av_find_best_stream(mContext, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
        AVCodec *videoCodec = NULL;
        mVideoStreamIndex = av_find_best_stream(mContext, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
        unsigned char *extradata = (unsigned char *)mContext->streams[mVideoStreamIndex]->codec->extradata;
        extradata += 4;

        int sps_byte_size = (*extradata++ & 0x3) + 1;
        int sps_count = *extradata++ & 0x1f;
        int sps_data_size = (extradata[0] << 8) | extradata[1];
        extradata += 2;

        char sps[1024] = {0};
        memcpy(sps, extradata, sps_data_size);
        extradata += sps_data_size;

        int pps_count = *extradata++;
        int pps_data_size = (extradata[0] << 8) | extradata[1];
        extradata += 2;
        char pps[1024] = {0};
        memcpy(pps, extradata, pps_data_size);

        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "MediaFileReader::MediaReaderHandle( "
                     "this : %p, "
                     "[Read Video SPS/PPS], "
                     "sps_count : %d, "
                     "sps_data_size : %d, "
                     "pps_count : %d, "
                     "pps_data_size : %d "
                     ")",
                     this,
                     sps_count,
                     sps_data_size,
                     pps_count,
                     pps_data_size);

        if (mpCallback) {
            mpCallback->OnMediaFileReaderChangeSpsPps(this, (const char *)sps, sps_data_size, (const char *)pps, pps_data_size);
        }

        AVPacket pkt;
        av_init_packet(&pkt);
        pkt.data = NULL;
        pkt.size = 0;

        AVFrame *frame = NULL;
        int ret = 0, got_frame = 0;

        bool bFinish = false;
        while (mbRunning) {
            int ret = av_read_frame(mContext, &pkt);

            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "MediaFileReader::MediaReaderHandle( "
                         "this : %p, "
                         "[Read Packet %s %s], "
                         "pts : %d, "
                         "size : %d, "
                         "data : 0x%02x,%02x,%02x,%02x,%02x"
                         ")",
                         this,
                         pkt.stream_index == mVideoStreamIndex ? "Video" : "Audio",
                         (pkt.flags & AV_PKT_FLAG_KEY) ? "Key Frame" : "Frame",
                         pkt.pts,
                         pkt.size,
                         pkt.data[0], pkt.data[1], pkt.data[2], pkt.data[3], pkt.data[4]);

            if (pkt.stream_index == mVideoStreamIndex) {
                VideoFrameType video_type;
                video_type = (pkt.flags & AV_PKT_FLAG_KEY) ? VFT_IDR : VFT_NOTIDR;

                if (mpCallback) {
                    int timestamp = pkt.pts * 1000 * av_q2d(mContext->streams[mVideoStreamIndex]->time_base);
                    mpCallback->OnMediaFileReaderVideoFrame(this, (const char *)pkt.data, pkt.size, timestamp, video_type);
                }

            } else if (pkt.stream_index == mAudioStreamIndex) {
            }

            if (ret < 0) {
                bFinish = true;
                break;
            }
        }

        if (bFinish) {
            break;
        }
    }

    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "MediaFileReader::MediaReaderHandle( "
                 "this : %p, "
                 "[Exit] "
                 ")",
                 this);
}
}
