//
//  AudioHardEncoder.cpp
//  RtmpClient
//
//  Created by Max on 2017/7/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "AudioHardEncoder.h"

#include <common/KLog.h>
#include <common/CommonFunc.h>

namespace coollive {
AudioHardEncoder::AudioHardEncoder()
    : mRuningMutex(KMutex::MutexType_Recursive) {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioHardEncoder::AudioHardEncoder( "
                 "this : %p "
                 ")",
                 this);

    // 默认格式
    mFormat = AFF_AAC;
    mSoundRate = AFSR_UNKNOWN;
    mSoundSize = AFSS_UNKNOWN;
    mSoundType = AFST_UNKNOWN;

    // 创建音频编码队列
    mAudioEncodeQueue = dispatch_queue_create("_mAudioEncodeQueue", NULL);
    mAudioConverter = NULL;

    // 临时Buffer
    mAudioPCMBuffer.mData = NULL;
    mAudioAACBuffer.mData = NULL;

    mAudioEncodedFrame.RenewBufferSize(1024);
}

AudioHardEncoder::~AudioHardEncoder() {
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioHardEncoder::~AudioHardEncoder( "
                 "this : %p "
                 ")",
                 this);

    DestroyContext();
}

bool AudioHardEncoder::Create(int sampleRate, int channelsPerFrame, int bitPerSample) {
    bool bFlag = true;

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioHardEncoder::Create( this : %p )", this);

    mSoundRate = (sampleRate == 44100) ? AFSR_KHZ_44 : AFSR_UNKNOWN;
    mSoundSize = (bitPerSample == 16) ? AFSS_BIT_16 : AFSS_BIT_8;
    mSoundType = (channelsPerFrame == 2) ? AFST_STEREO : AFST_MONO;

    // 初始化时间戳
    mLastPresentationTime = 0;
    mTotalPresentationTime = 0;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioHardEncoder::Create( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail"
                 );

    return bFlag;
}

void AudioHardEncoder::SetCallback(AudioEncoderCallback *callback) {
    mpCallback = callback;
}

bool AudioHardEncoder::Reset() {
    bool bFlag = true;

    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioHardEncoder::Reset( this : %p )", this);
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioHardEncoder::Reset( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 bFlag ? "Success" : "Fail"
                 );

    return bFlag;
}

void AudioHardEncoder::Pause() {
    FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioHardEncoder::Pause( this : %p )", this);

    DestroyContext();
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioHardEncoder::Pause( "
                 "this : %p, "
                 "[%s] "
                 ")",
                 this,
                 "Success"
                 );
}

void AudioHardEncoder::EncodeAudioFrame(void *data, int size, void *frame) {
    CMSampleBufferRef sampleBuffer = (CMSampleBufferRef)frame;

    // 创建转码器
    CreateContext(sampleBuffer);

    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CFRetain(blockBuffer);

    // 计算时间戳
    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    double value = presentationTime.value;
    value /= presentationTime.timescale;

    // 第一帧, 或者时间被重置
    if (mLastPresentationTime == 0 || mLastPresentationTime > value) {
        mLastPresentationTime = value;
        mTotalPresentationTime = 0;

        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "AudioHardEncoder::EncodeAudioFrame( "
                     "[Reset Timestamp], "
                     "mLastPresentationTime : %f, "
                     "mTotalPresentationTime : %u "
                     ")",
                     mLastPresentationTime,
                     mTotalPresentationTime);
    }

    double diff = value - mLastPresentationTime;
    mTotalPresentationTime += diff;
    UInt32 timestamp = (UInt32)floor(1000 * mTotalPresentationTime);
    mLastPresentationTime = value;

    dispatch_async(mAudioEncodeQueue, ^{
        mRuningMutex.lock();

        // 获取PCM数据
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, (size_t *)&(mAudioPCMBuffer.mDataByteSize), (char **)&(mAudioPCMBuffer.mData));
        NSError *error = nil;
        if (status == kCMBlockBufferNoErr) {

        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];

            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "AudioHardEncoder::EncodeAudioFrame( "
                         "[Get PCM Frame Error], "
                         "timestamp : %u, "
                         "status : %d, "
                         "error : %@ "
                         ")",
                         timestamp,
                         status,
                         error);
        }

        // 初始化AAC Buffer
        if (mAudioAACBuffer.mData && mAudioAACBuffer.mDataByteSize > 0) {
            memset(mAudioAACBuffer.mData, 0, mAudioAACBuffer.mDataByteSize);

            // 编码后AAC帧Buffer
            AudioBufferList outAudioBufferList = {0};
            outAudioBufferList.mNumberBuffers = 1;
            outAudioBufferList.mBuffers[0].mNumberChannels = 1;
            outAudioBufferList.mBuffers[0].mDataByteSize = mAudioAACBuffer.mDataByteSize;
            outAudioBufferList.mBuffers[0].mData = mAudioAACBuffer.mData;
            // 编码后AAC帧描述
            AudioStreamPacketDescription outPacketDescription;

            // 每编码一帧就回调
            UInt32 ioOutputDataPacketSize = 1;
            status = AudioConverterFillComplexBuffer(mAudioConverter, inInputDataProc, this, &ioOutputDataPacketSize, &outAudioBufferList, &outPacketDescription);
            if (status == noErr) {
                // 获取AAC编码数据
                char *data = (char *)outAudioBufferList.mBuffers[0].mData;
                UInt32 size = outAudioBufferList.mBuffers[0].mDataByteSize;

                mAudioEncodedFrame.EncodeDecodeBuffer::ResetBuffer();

                // 增加ADTS头部
                char *frame = (char *)mAudioEncodedFrame.GetBuffer();
                int headerCapacity = mAudioEncodedFrame.GetBufferCapacity();
                int frameHeaderSize = 0;
                bool bFlag = mAudioMuxer.GetADTS(size, AFF_AAC, AFSR_KHZ_44, AFSS_BIT_16, AFST_MONO, frame, headerCapacity, frameHeaderSize);
                if (bFlag) {
                    // 计算已用的ADTS
                    mAudioEncodedFrame.mBufferLen = frameHeaderSize;
                    // 计算帧大小是否足够
                    if (frameHeaderSize + size > headerCapacity) {
                        mAudioEncodedFrame.RenewBufferSize(frameHeaderSize + size);
                    }
                    // 增加帧内容
                    mAudioEncodedFrame.AddBuffer((unsigned char *)data, size);

                    FileLevelLog("rtmpdump",
                                 KLog::LOG_STAT,
                                 "AudioHardEncoder::EncodeAudioFrame( "
                                 "[Encoded AAC Frame], "
                                 "timestamp : %u, "
                                 "size : %d "
                                 ")",
                                 timestamp,
                                 mAudioEncodedFrame.mBufferLen);

                    // 发送音频数据
                    if (mpCallback) {
                        mpCallback->OnEncodeAudioFrame(this, AFF_AAC, AFSR_KHZ_44, AFSS_BIT_16, AFST_MONO, frame, mAudioEncodedFrame.mBufferLen, timestamp);
                    }

                } else {
                    FileLevelLog("rtmpdump",
                                 KLog::LOG_WARNING,
                                 "AudioHardEncoder::EncodeAudioFrame( "
                                 "[Encoded ADTS Error], "
                                 "timestamp : %u "
                                 ")",
                                 timestamp);
                }

            } else {
                error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];

                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "AudioHardEncoder::EncodeAudioFrame( "
                             "[Encoded AAC Error], "
                             "timestamp : %u, "
                             "status : %d, "
                             "error : %@ "
                             ")",
                             timestamp,
                             status,
                             error);
            }
        }

        CFRelease(blockBuffer);

        mRuningMutex.unlock();

    });
}

OSStatus AudioHardEncoder::inInputDataProc(AudioConverterRef inAudioConverter,
                                           UInt32 *ioNumberDataPackets,
                                           AudioBufferList *ioData,
                                           AudioStreamPacketDescription **outDataPacketDescription,
                                           void *inUserData) {
    AudioHardEncoder *encoder = (AudioHardEncoder *)(inUserData);

    // 填充PCM数据
    ioData->mBuffers[0].mData = encoder->mAudioPCMBuffer.mData;
    ioData->mBuffers[0].mDataByteSize = encoder->mAudioPCMBuffer.mDataByteSize;

    if (*ioNumberDataPackets > encoder->mAudioPCMBuffer.mDataByteSize) {
        // 缓存数据不够, 返回继续等待
        *ioNumberDataPackets = 0;
        encoder->mAudioPCMBuffer.mDataByteSize = 0;

    } else {
        *ioNumberDataPackets = 1;
    }

    return noErr;
}

bool AudioHardEncoder::CreateContext(CMSampleBufferRef sampleBuffer) {
    bool bFlag = true;

    mRuningMutex.lock();

    if (!mAudioConverter) {
        FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioHardEncoder::CreateContext( this : %p )", this);

        OSStatus status = noErr;

        // 音频输入格式
        AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));

        // 音频输出格式
        AudioStreamBasicDescription outAudioStreamBasicDescription = {0}; // 初始化输出流的结构体描述为0
        outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;
        outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC; // 设置编码格式
                                                                         //        outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
        outAudioStreamBasicDescription.mChannelsPerFrame = 1;            // 声道数

        AudioClassDescription *desc = nil;
        AudioClassDescription *descArray = nil;
        unsigned int count = 0;

        UInt32 encodeType = kAudioFormatMPEG4AAC;
        UInt32 size;
        status = AudioFormatGetPropertyInfo(
            kAudioFormatProperty_Encoders,
            sizeof(encodeType),
            &encodeType,
            &size);

        if (status == noErr) {
            count = size / sizeof(AudioClassDescription);
            descArray = new AudioClassDescription[count];

            status = AudioFormatGetProperty(
                kAudioFormatProperty_Encoders,
                sizeof(encodeType),
                &encodeType,
                &size,
                descArray);

            if (status == noErr) {
                for (unsigned int i = 0; i < count; i++) {
                    if ((kAudioFormatMPEG4AAC == descArray[i].mSubType) &&
                        (kAppleSoftwareAudioCodecManufacturer == descArray[i].mManufacturer)) {
                        desc = &descArray[i];
                    }
                }
            } else {
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "AudioHardEncoder::CreateContext( "
                             "[AudioFormatGetProperty error encodeType : %u], "
                             "this : %p, "
                             "status : %d "
                             ")",
                             (unsigned int)encodeType,
                             this,
                             (int)(status));
            }

        } else {
            FileLevelLog("rtmpdump",
                         KLog::LOG_WARNING,
                         "AudioHardEncoder::CreateContext( "
                         "[AudioFormatGetPropertyInfo error encodeType : %u], "
                         "this : %p, "
                         "status : %d "
                         ")",
                         (unsigned int)encodeType,
                         this,
                         (int)(status));
        }

        if (status == noErr) {
            // 创建转换器
            status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, desc, &mAudioConverter);
            if (status == noErr) {
                //                // 设置码率
                //                uint32_t audioBitrate = 10 * 1000;
                //                uint32_t audioBitrateSize = sizeof(audioBitrate);
                //                status = AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, audioBitrateSize, &audioBitrate);

                mAudioAACBuffer.mDataByteSize = 1024;
                mAudioAACBuffer.mData = (void *)malloc(mAudioAACBuffer.mDataByteSize * sizeof(uint8_t));

                bFlag = YES;

            } else {
                FileLevelLog("rtmpdump",
                             KLog::LOG_WARNING,
                             "AudioHardEncoder::CreateContext( "
                             "[AudioConverterNewSpecific error encodeType : %u], "
                             "this : %p, "
                             "status : %d "
                             ")",
                             (unsigned int)encodeType,
                             this,
                             (int)(status));
            }
        }

        if (descArray) {
            delete[] descArray;
        }
    }

    mRuningMutex.unlock();

    return bFlag;
}

void AudioHardEncoder::DestroyContext() {
    FileLevelLog("rtmpdump", KLog::LOG_MSG, "AudioHardEncoder::DestroyContext( this : %p )", this);

    mRuningMutex.lock();
    if( mAudioConverter ) {
        AudioConverterDispose(mAudioConverter);
        mAudioConverter = NULL;
    }
    
    if( mAudioAACBuffer.mData ) {
        free(mAudioAACBuffer.mData);
        mAudioAACBuffer.mData = NULL;
    }
    mRuningMutex.unlock();
}
}
