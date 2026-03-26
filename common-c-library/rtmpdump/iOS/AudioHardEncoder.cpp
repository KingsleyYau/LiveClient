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

    mAudioEncodedFrame.RenewBufferSize(2048);
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

    if (sampleRate == 48000)
        mSoundRate = AFSR_KHZ_48;
    else if (sampleRate == 44100)
        mSoundRate = AFSR_KHZ_44;
    else
        mSoundRate = AFSR_UNKNOWN;
    
    mSoundType = (channelsPerFrame == 2) ? AFST_STEREO : AFST_MONO;
    mSoundSize = (bitPerSample == 16) ? AFSS_BIT_16 : AFSS_BIT_8;

    // 初始化时间戳
    mLastPresentationTime = 0;
    mTotalPresentationTime = 0;

    FileLevelLog("rtmpdump",
                 KLog::LOG_WARNING,
                 "AudioHardEncoder::Create( "
                 "this : %p, "
                 "sampleRate : %d, "
                 "channelsPerFrame : %d, "
                 "bitPerSample : %d, "
                 "[%s] "
                 ")",
                 this,
                 sampleRate,
                 channelsPerFrame,
                 bitPerSample,
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
       
    DestroyContext();
    
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

        if (mAudioConverter) {
            // 获取PCM数据
            size_t lengthAtOffsetOut = 0;
            OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, (size_t *)&lengthAtOffsetOut, (size_t *)&(mAudioPCMBuffer.mDataByteSize), (char **)&(mAudioPCMBuffer.mData));
            NSError *error = nil;
            if (status == kCMBlockBufferNoErr) {
                FileLevelLog("rtmpdump",
                             KLog::LOG_STAT,
                             "AudioHardEncoder::EncodeAudioFrame( "
                             "[Get PCM Frame], "
                             "timestamp : %u, "
                             "lengthAtOffsetOut : %u, "
                             "mAudioPCMBuffer.mDataByteSize : %u, "
                             "mSoundSize : %u, "
                             "mSoundType : %u "
                             ")",
                             timestamp,
                             lengthAtOffsetOut,
                             mAudioPCMBuffer.mDataByteSize,
                             mSoundSize,
                             mSoundType
                             );
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
                outAudioBufferList.mBuffers[0].mNumberChannels = (mSoundType==AFST_STEREO)?2:1;
                outAudioBufferList.mBuffers[0].mDataByteSize = mAudioAACBuffer.mDataByteSize;
                outAudioBufferList.mBuffers[0].mData = mAudioAACBuffer.mData;
                
                // 编码后AAC帧描述
                AudioStreamPacketDescription outPacketDescription;
                
                // 每编码1个包就回调, 1个包是1024帧
                UInt32 ioOutputDataPacketSize = 1;
                status = AudioConverterFillComplexBuffer(mAudioConverter, inInputDataProc, this, &ioOutputDataPacketSize, &outAudioBufferList, &outPacketDescription);
                if (status == noErr) {
                    if (ioOutputDataPacketSize > 0) {
                        // 获取AAC编码数据
                        char *data = (char *)outAudioBufferList.mBuffers[0].mData;
                        UInt32 size = outAudioBufferList.mBuffers[0].mDataByteSize;
                        
                        mAudioEncodedFrame.EncodeDecodeBuffer::ResetBuffer();
                        
                        // 增加ADTS头部
                        char *frame = (char *)mAudioEncodedFrame.GetBuffer();
                        int headerCapacity = mAudioEncodedFrame.GetBufferCapacity();
                        int frameHeaderSize = 0;
                        bool bFlag = mAudioMuxer.GetADTS(size, AFF_AAC, mSoundRate, AFSS_BIT_16, mSoundType, frame, headerCapacity, frameHeaderSize);
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
                                         KLog::LOG_MSG,
                                         "AudioHardEncoder::EncodeAudioFrame( "
                                         "[Encoded AAC Frame], "
                                         "timestamp : %u, "
                                         "size : %d "
                                         ")",
                                         timestamp,
                                         mAudioEncodedFrame.mBufferLen);
                            
                            // 发送音频数据
                            if (mpCallback) {
                                mpCallback->OnEncodeAudioFrame(this, AFF_AAC, mSoundRate, AFSS_BIT_16, mSoundType, frame, mAudioEncodedFrame.mBufferLen, timestamp);
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

    UInt32 bytesPerPacket = encoder->mInAudioStreamBasicDescription.mBytesPerPacket;
    // 2 * encoder->mAudioPCMBuffer.mNumberChannels; // 源格式：PCM 16bit（2字节/样本），单声道，1样本/包 → 2字节/包
    // 2. 确定本次要提供的数据包数量（不超过请求的数量）
    UInt32 availablePackets = encoder->mAudioPCMBuffer.mDataByteSize / bytesPerPacket;
    
    FileLevelLog("rtmpdump",
                 KLog::LOG_MSG,
                 "AudioHardEncoder::inInputDataProc( "
                 "*ioNumberDataPackets : %u, "
                 "availablePackets : %u "
                 ")",
                 *ioNumberDataPackets,
                 availablePackets
                 );
    // 返回处理过的数据
    *ioNumberDataPackets = min(availablePackets, *ioNumberDataPackets);
    // 填充PCM数据
    ioData->mBuffers[0].mNumberChannels = encoder->mAudioPCMBuffer.mNumberChannels;
    ioData->mBuffers[0].mData = encoder->mAudioPCMBuffer.mData;
    ioData->mBuffers[0].mDataByteSize = bytesPerPacket * *ioNumberDataPackets;

    return noErr;
}

bool AudioHardEncoder::CreateContext(CMSampleBufferRef sampleBuffer) {
    bool bFlag = true;

    mRuningMutex.lock();

    if (!mAudioConverter) {
        FileLevelLog("rtmpdump", KLog::LOG_WARNING, "AudioHardEncoder::CreateContext( this : %p )", this);

        OSStatus status = noErr;

        // 音频输入格式
        mInAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));

        mAudioPCMBuffer.mNumberChannels = mInAudioStreamBasicDescription.mChannelsPerFrame;
        
        // 音频输出格式
        AudioStreamBasicDescription outAudioStreamBasicDescription = {0}; // 初始化输出流的结构体描述为0
        if (mSoundRate == AFSR_KHZ_48) {
            outAudioStreamBasicDescription.mSampleRate = 48000;
        } else {
            outAudioStreamBasicDescription.mSampleRate = 44100;
        }
        outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC; // 设置编码格式
//        outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
        // 声道数
        outAudioStreamBasicDescription.mChannelsPerFrame = (mSoundType==AFST_STEREO)?2:1;
        outAudioStreamBasicDescription.mFramesPerPacket = 1024;

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
            status = AudioConverterNewSpecific(&mInAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, desc, &mAudioConverter);
            if (status == noErr) {
                mAudioAACBuffer.mDataByteSize = 2048;
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
        AudioConverterReset(mAudioConverter);
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
