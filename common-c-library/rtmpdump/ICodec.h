/*
 * ICodec.h
 *
 *  Created on: 2017年5月8日
 *      Author: max
 */

#ifndef RTMPDUMP_ICODEC_H_
#define RTMPDUMP_ICODEC_H_

namespace coollive {
    // 原始视频数据格式
    typedef enum VIDEO_FORMATE_TYPE {
        VIDEO_FORMATE_NONE    = 0,
        VIDEO_FORMATE_NV21    = 1,
        VIDEO_FORMATE_NV12    = 2,
        VIDEO_FORMATE_YUV420P = 3,
        VIDEO_FORMATE_RGB565  = 4,
        VIDEO_FORMATE_RGB24   = 5,
        VIDEO_FORMATE_BGRA    = 6,
        VIDEO_FORMATE_RGBA    = 7,
    } VIDEO_FORMATE_TYPE;
    
    typedef enum VideoFrameFormat {
        VFF_UNKNOWN = 0,
        VFF_H263 = 2,
        VVF_SCREEN_VIDEO = 3,
        VVF_ON2VP6 = 4,
        VVF_ON2_VP6_WITH_ALPHA_CHANNEL = 5,
        VVF_SCREEN_VIDEO_VERSION = 6,
        VVF_AVC = 7,
    } VideoFrameFormat;
    
    typedef enum VideoFrameType {
        VFT_UNKNOWN = 0,
        VFT_NOTIDR = 1,
        VFT_IDR = 5,
        VFT_SPS = 7,
        VFT_PPS = 8,
    } VideoFrameType;
    
    typedef enum AudioFrameFormat {
        AFF_UNKNOWN = -1,
        AFF_LINEAR = 0, // 0 = Linear PCM, platform endian
        AFF_ADPCM = 1, // 1 = ADPCM
        AFF_MP3 = 2, // 2 = MP3
        AFF_G711A = 7, // 7 = G.711 A-law logarithmic PCM
        AFF_G711MU = 8, // 8 = G.711 mu-law logarithmic PCM
        AFF_AAC = 10, // 10 = AAC
        AFF_SPEEX = 11, // 11 = Speex
    } AudioFrameFormat;
    
    typedef enum AudioFrameSoundRate {
        AFSR_UNKNOWN = -1,
        AFSR_KHZ_5_5 = 0,
        AFSR_KHZ_11 = 1,
        AFSR_KHZ_22 = 2,
        AFSR_KHZ_44 = 3,
    } AudioFrameSoundRate;
    
    typedef enum AudioFrameSoundSize {
        AFSS_UNKNOWN = -1,
        AFSS_BIT_8 = 0,
        AFSS_BIT_16 = 1,
    } AudioFrameSoundSize;
    
    typedef enum AudioFrameSoundType {
        AFST_UNKNOWN = -1,
        AFST_MONO = 0,
        AFST_STEREO = 1,
    } AudioFrameSoundType;
    
    typedef enum AudioFrameAACType {
        AAC_UNKNOWN = -1,
        AAC_SEQUENCE_HEADER = 0,
        AAC_RAW  = 1,
    } AudioFrameAACType;
}

#endif /* RTMPDUMP_ICODEC_H_ */
