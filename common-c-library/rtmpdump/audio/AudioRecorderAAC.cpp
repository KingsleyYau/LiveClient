//
//  AudioRecorderAAC.cpp
//  RtmpClient
//
//  Created by Max on 2017/8/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "AudioRecorderAAC.h"

namespace coollive {
AudioRecorderAAC::AudioRecorderAAC() {
    mFilePath = "";
    mpFile = NULL;

    mFormat = AFF_UNKNOWN;
    mSoundRate = AFSR_UNKNOWN;
    mSoundSize = AFSS_UNKNOWN;
    mSoundType = AFST_UNKNOWN;
}

AudioRecorderAAC::~AudioRecorderAAC() {
}

bool AudioRecorderAAC::Start(const string &filePath) {
    bool bFlag = false;

    mFilePath = filePath;

    if (mFilePath.length() > 0) {
        remove(mFilePath.c_str());
        mpFile = fopen(mFilePath.c_str(), "w+b");
        if (mpFile) {
            fseek(mpFile, 0L, SEEK_END);
            bFlag = true;
        }
    }

    return bFlag;
}

void AudioRecorderAAC::Stop() {
    if (mpFile) {
        fclose(mpFile);
        mpFile = NULL;
    }
}

void AudioRecorderAAC::ChangeAudioFormat(
    AudioFrameFormat format,
    AudioFrameSoundRate sound_rate,
    AudioFrameSoundSize sound_size,
    AudioFrameSoundType sound_type) {
    mFormat = format;
    mSoundRate = sound_rate;
    mSoundSize = sound_size;
    mSoundType = sound_type;
}

bool AudioRecorderAAC::RecordAudioFrame(const char *data, int size) {
    bool bFlag = false;

    if (mpFile) {
        // 增加ADTS头部
        mAudioFrame.ResetFrame();
        mAudioFrame.InitFrame(mFormat, mSoundRate, mSoundSize, mSoundType);

        char *frame = (char *)mAudioFrame.GetBuffer();
        int headerCapacity = mAudioFrame.GetBufferCapacity();
        int frameHeaderSize = 0;
        bFlag = mAudioMuxer.GetADTS(size, mAudioFrame.mSoundFormat, mAudioFrame.mSoundRate, mAudioFrame.mSoundSize, mAudioFrame.mSoundType, frame, headerCapacity, frameHeaderSize);
        if (bFlag) {
            // 计算已用的ADTS
            mAudioFrame.mBufferLen = frameHeaderSize;
            // 计算帧大小是否足够
            if (frameHeaderSize + size > headerCapacity) {
                mAudioFrame.RenewBufferSize(frameHeaderSize + size);
            }
            // 增加帧内容
            mAudioFrame.AddBuffer((unsigned char *)data, size);

            // Write playload
            fwrite(mAudioFrame.GetBuffer(), 1, mAudioFrame.mBufferLen, mpFile);

            fflush(mpFile);
        }
    }
    
    return bFlag;
}

}
