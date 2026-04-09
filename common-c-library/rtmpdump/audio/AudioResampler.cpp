//
//  VideoFormatConverter.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "AudioResampler.h"

#include "AudioFrame.h"

#include <common/KLog.h>
#include <common/CommonFunc.h>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/opt.h>
#include <libavutil/channel_layout.h>
#include <libavutil/samplefmt.h>
#include <libswresample/swresample.h>
}

namespace coollive {
AudioResampler::AudioResampler()
: mSwrCtx(NULL)
, mCacheBuf(NULL)
, mCacheSamples(0)
, mOutChannels(0)
, mOutSampleSize(0)
{}

AudioResampler::~AudioResampler() {
    flush();
    if (mSwrCtx) {
        swr_free(&mSwrCtx);
    }
    if (mCacheBuf) {
        delete[] mCacheBuf;
    }
}

bool AudioResampler::init(int inSampleRate, int inChannels,
                          int outSampleRate, int outChannels)
{
    int64_t inLayout  = av_get_default_channel_layout(inChannels);
    int64_t outLayout = av_get_default_channel_layout(outChannels);

    // FFmpeg 2.8 重采样
    AVSampleFormat inFmt = AV_SAMPLE_FMT_S16;
    AVSampleFormat outFmt = AV_SAMPLE_FMT_S16;
    mSwrCtx = swr_alloc_set_opts(NULL,
                                 outLayout,
                                 outFmt,
                                 outSampleRate,
                                 inLayout,
                                 inFmt,
                                 inSampleRate,
                                 0, NULL);

    if (!mSwrCtx || swr_init(mSwrCtx) < 0) {
        return false;
    }

    mOutChannels = outChannels;
    mOutSampleSize = av_get_bytes_per_sample(outFmt);

    // 缓存：最多缓存 2048 帧（足够凑1024）
    mCacheBuf = new uint8_t[2048 * outChannels * mOutSampleSize];
    mCacheSamples = 0;
    return true;
}

void AudioResampler::pushPCM(uint8_t* data, int sampleCount) {
    if (!mSwrCtx || !data || sampleCount <= 0) return;

    // 输出转换后缓冲区
    int outMaxSamples = sampleCount;
    uint8_t* outBuf = new uint8_t[outMaxSamples * mOutChannels * mOutSampleSize];

    // 执行重采样
    uint8_t* inData[] = { data };
    uint8_t* outData[] = { outBuf };

    int converted = swr_convert(mSwrCtx,
                                outData, outMaxSamples,
                                (const uint8_t**)inData, sampleCount);

    if (converted > 0) {
        // 写入缓存
        int bytes = converted * mOutChannels * mOutSampleSize;
        int cacheBytes = mCacheSamples * mOutChannels * mOutSampleSize;

        memcpy(mCacheBuf + cacheBytes, outBuf, bytes);
        mCacheSamples += converted;
    }

    delete[] outBuf;
}

int AudioResampler::popFrame1024(uint8_t* outBuf) {
    const int NEED = 1024;
    if (mCacheSamples < NEED) return 0;

    // 拷贝 1024 帧
    int bytes = NEED * mOutChannels * mOutSampleSize;
    memcpy(outBuf, mCacheBuf, bytes);

    // 剩余数据前移
    int remain = mCacheSamples - NEED;
    int remainBytes = remain * mOutChannels * mOutSampleSize;

    memmove(mCacheBuf, mCacheBuf + bytes, remainBytes);
    mCacheSamples = remain;

    return NEED;
}

void AudioResampler::flush() {
    mCacheSamples = 0;
}
    
}
