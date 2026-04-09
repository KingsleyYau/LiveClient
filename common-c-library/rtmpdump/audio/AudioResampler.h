//
//  AudioResampler.h
//  RtmpClient
//
//  Created by Max on 2017/6/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#ifndef AUDIO_RESAMPLER_H
#define AUDIO_RESAMPLER_H

#include <rtmpdump/ICodec.h>

#include <stdio.h>

struct AVCodecContext;
struct AVFrame;
struct SwrContext;

namespace coollive {
class AudioResampler {
public:
    AudioResampler();
    ~AudioResampler();

    // 初始化：输入格式 + 输出格式
    bool init(int inSampleRate, int inChannels,
              int outSampleRate, int outChannels);

    // 送入原始PCM → 自动转换 → 自动缓存
    void pushPCM(uint8_t* data, int sampleCount);

    // 取出一帧【固定1024帧】的PCM（给AAC编码用）
    // 返回：实际读到的帧数（1024 或 0）
    int popFrame1024(uint8_t* outBuf);

    // 清空缓存
    void flush();

private:
    SwrContext*     mSwrCtx;
    uint8_t*        mCacheBuf;
    int             mCacheSamples;
    int             mOutChannels;
    int             mOutSampleSize;
};
}
#endif /* VideoFormatConverter_h */
