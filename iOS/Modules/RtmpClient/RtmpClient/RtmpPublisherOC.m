//
//  RtmpPublisherOC.m
//  RtmpPublisherOC
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RtmpPublisherOC.h"

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

#include <rtmpdump/RtmpPublisher.h>

class RtmpDumpCallbackPublish;
@interface RtmpPublisherOC ()
/**
 传输模块
 */
@property (assign) RtmpPublisher* publisher;
@property (assign) RtmpPublisherCallback* rtmpCallback;

#pragma mark - 音频编码变量
/**
 音频编码队列
 */
@property (strong) dispatch_queue_t audio_encode_queue;
/**
 音频编码器
 */
@property (assign) AudioConverterRef audioConverter;
/**
 音频PCM缓存Buffer
 */
@property (assign) AudioBuffer audioPCMBuffer;
/**
 音频AAC编码Buffer
 */
@property (assign) AudioBuffer audioAACBuffer;
/**
 音频最后编码帧时间
 */
@property (assign) u_int32_t audioEncodeTimestamp;

#pragma mark - 视频编码变量
/**
 视频编码队列
 */
@property (strong) dispatch_queue_t video_encode_queue;
/**
 视频编码器
 */
@property (assign) VTCompressionSessionRef videoCompressionSession;
/**
 视频编码帧数下标
 */
@property (assign) NSInteger encodeFrameCount;
/**
 视频最后编码帧时间
 */
@property (assign) u_int32_t videoEncodeTimestamp;
/**
 视频宽
 */
@property (assign) NSInteger width;
/**
 视频高
 */
@property (assign) NSInteger height;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackGround;

#pragma mark - 测试
@property (strong) NSString* recordPCMFilePath;

@property (assign) BOOL bRunning;

@end

#pragma mark - RrmpPublisher回调
class RtmpPublisherCallbackImp : public RtmpPublisherCallback {
public:
    RtmpPublisherCallbackImp(RtmpPublisherOC* publisher) {
        mpPublisher = publisher;
    };
    
    ~RtmpPublisherCallbackImp(){};
    
    void OnDisconnect(RtmpPublisher* publisher) {
        [mpPublisher.delegate rtmpPublisherOCOnDisconnect:mpPublisher];
    }
    
private:
    RtmpPublisherOC* mpPublisher;
};

@implementation RtmpPublisherOC
#pragma mark - 获取实例
+ (instancetype)instance {
    RtmpPublisherOC *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init {
    if(self = [super init] ) {
        _isBackGround = NO;
        _bRunning = NO;
        
        self.publisher = new RtmpPublisher();
        
        self.rtmpCallback = new RtmpPublisherCallbackImp(self);
        self.publisher->SetCallback(self.rtmpCallback);
        
        // 创建音频编码队列
        self.audio_encode_queue = dispatch_queue_create("_audio_encode_queue", NULL);
        _audioConverter = NULL;
        
        // 创建视频编码队列
        self.video_encode_queue = dispatch_queue_create("_video_encode_queue", NULL);
        _videoCompressionSession = NULL;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc {
    if( self.rtmpCallback ) {
        delete self.rtmpCallback;
        self.rtmpCallback = NULL;
    }
    
    if( self.publisher ) {
        delete self.publisher;
        self.publisher = NULL;
    }
        
    // 销毁视频编码器
    [self destroyVideoCompressionSession];
    
    // 销毁音频编码器
    [self destroyAudioCompressionSession];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)publishUrl:(NSString * _Nonnull)url
             width:(NSInteger)width
            height:(NSInteger)height
recordH264FilePath:(NSString *)recordH264FilePath
 recordAACFilePath:(NSString * _Nullable)recordAACFilePath
{
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPublisherOC::pushlishUrl( publisher : %@, url : %@, recordH264FilePath : %@, recordAACFilePath : %@ )", self, url, recordH264FilePath, recordAACFilePath);
    self.recordPCMFilePath = [NSString stringWithFormat:@"%@.pcm", recordAACFilePath];
    
    bFlag = self.publisher->PublishUrl([url UTF8String], [recordH264FilePath UTF8String], [recordAACFilePath UTF8String]);
    if( bFlag ) {
        // 创建视频编码器
        self.width = width;
        self.height = height;
        
        self.videoEncodeTimestamp = 0;
        self.audioEncodeTimestamp = 0;
        
        self.bRunning = YES;
        
        [self createVideoCompressionSession];
    }
    
    return bFlag;
}

- (void)stop {
    NSLog(@"RtmpPublisherOC::stop( publisher : %@ )", self);
    self.publisher->Stop();
    
    // 销毁音频编码器
    [self destroyAudioCompressionSession];
    // 销毁视频编码器
    [self destroyVideoCompressionSession];
}

- (void)sendVideoFrame:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferRetain(pixelBuffer);
    
    dispatch_sync(self.video_encode_queue, ^{
        VTEncodeInfoFlags flags;
        // 设置每帧的Timestamp
        CMTime presentationTimeStamp = CMTimeMake(self.encodeFrameCount++, FPS);
        OSStatus status = VTCompressionSessionEncodeFrame(
                                                          self.videoCompressionSession,
                                                          pixelBuffer,
                                                          presentationTimeStamp,
                                                          kCMTimeInvalid,
                                                          NULL,
                                                          NULL,
                                                          &flags
                                                          );
        if( status != noErr ) {
            NSLog(@"RtmpPublisherOC::sendVideoFrame( fail, status : %d )", (int)status);
        }
        CVPixelBufferRelease(pixelBuffer);
    });
}

- (void)sendAudioFrame:(CMSampleBufferRef)sampleBuffer {
    // 创建转码器
    [self createAudioCompressionSession:sampleBuffer];
    
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CFRetain(blockBuffer);
    
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    UInt32 sampleTimestamp = (UInt32)((1000 * presentationTimeStamp.value) / presentationTimeStamp.timescale);
    
    UInt32 timestamp = 0;
    if( self.audioEncodeTimestamp != 0 ) {
        timestamp = sampleTimestamp - self.audioEncodeTimestamp;
    }
//    NSLog(@"sendAudioFrame( sampleTimestamp : %u, timestamp : %u )", sampleTimestamp, (unsigned int)timestamp);
    self.audioEncodeTimestamp = sampleTimestamp;
    self.publisher->AddAudioTimestamp(timestamp);
    
    dispatch_sync(self.audio_encode_queue, ^{
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, (size_t *)&(_audioPCMBuffer.mDataByteSize), (char **)&(_audioPCMBuffer.mData));
        NSError *error = nil;
        if( status == kCMBlockBufferNoErr ) {
            
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        // 初始化AAC Buffer
        memset(_audioAACBuffer.mData, 0, _audioAACBuffer.mDataByteSize);
        
        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mNumberBuffers = 1;
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        outAudioBufferList.mBuffers[0].mDataByteSize = _audioAACBuffer.mDataByteSize;
        outAudioBufferList.mBuffers[0].mData = _audioAACBuffer.mData;
        
        AudioStreamPacketDescription outPacketDescription;
        // 每编码一帧就回调
        UInt32 ioOutputDataPacketSize = 1;
        status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, &outPacketDescription);
        if( status == noErr ) {
            // 获取AAC编码数据
            NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            
            // 发送音频数据
            self.publisher->SendAudioFrame(AFF_AAC, AFSR_KHZ_44, AFSS_BIT_16, AFST_MONO, (char *)[rawAAC bytes], (int)[rawAAC length]);
            
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        CFRelease(blockBuffer);
    });
}

#pragma mark - 视频硬编码H264
- (BOOL)createVideoCompressionSession {
    BOOL bFlag = false;
    
    if( !_videoCompressionSession ) {
        OSStatus status;
        
        // 这里宽高换转, 因为摄像头默认是右转90度
        int32_t width = (int32_t)self.height, height = (int32_t)self.width;
        status = VTCompressionSessionCreate(
                                            kCFAllocatorDefault,
                                            width,
                                            height,
                                            kCMVideoCodecType_H264,
                                            NULL,
                                            NULL,
                                            NULL,
                                            videoCompressionOutputCallback,
                                            (__bridge void *)(self),
                                            &_videoCompressionSession
                                            );
        
        if( status == noErr ) {
            VTSessionSetProperty(_videoCompressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
            VTSessionSetProperty(_videoCompressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_4_1);
            
            // 码率
            SInt32 bitRate = BIT_RATE;
            CFNumberRef ref = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
            VTSessionSetProperty(_videoCompressionSession, kVTCompressionPropertyKey_AverageBitRate, ref);
            CFRelease(ref);
            
            // 关键帧间隔
            int frameInterval = KEY_FRAME_TIME;
            CFNumberRef frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
            VTSessionSetProperty(_videoCompressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
            CFRelease(frameIntervalRef);
            
            VTCompressionSessionPrepareToEncodeFrames(_videoCompressionSession);
            
        } else {
            NSLog(@"RtmpPublisherOC::createVideoCompressionSession( fail, statusCode : %d )", (int)status);
        }
        
        bFlag = (status == noErr);
    }
    
    return bFlag;
}

- (void)destroyVideoCompressionSession {
    if( _videoCompressionSession ) {
        VTCompressionSessionCompleteFrames(_videoCompressionSession, kCMTimeInvalid);
        
        VTCompressionSessionInvalidate(_videoCompressionSession);
        CFRelease(_videoCompressionSession);
        _videoCompressionSession = NULL;
    }
}

static void videoCompressionOutputCallback(
                                           void *outputCallbackRefCon,
                                           void *sourceFrameRefCon,
                                           OSStatus status,
                                           VTEncodeInfoFlags infoFlags,
                                           CMSampleBufferRef sampleBuffer
                                           ) {
    
    RtmpPublisherOC* client = (__bridge RtmpPublisherOC*)outputCallbackRefCon;
    OSStatus statusCode = noErr;
    
    if( !sampleBuffer || status != noErr ) {
        // kVTVideoEncoderMalfunctionErr
        NSLog(@"RtmpPublisherOC::videoCompressionOutputCallback( [sampleBuffer is NULL], status : %d )", status);
        // 可以断开连接, 或者重建编码器
        return;
    }
    
    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    UInt32 presentationTimestamp = (UInt32)((1000 * presentationTime.value) / presentationTime.timescale);
    
    UInt32 timestamp = 0;
    if( client.videoEncodeTimestamp != 0 ) {
        timestamp = presentationTimestamp - client.videoEncodeTimestamp;
    }
//    NSLog(@"videoCompressionOutputCallback( presentationTimestamp : %u, timestamp : %u )", presentationTimestamp, timestamp);
    client.videoEncodeTimestamp = presentationTimestamp;
    client.publisher->AddVideoTimestamp(timestamp);
    
    // 判断当前帧是否为关键帧
    CFArrayRef arrayRef = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    CFDictionaryRef dictRef = (CFDictionaryRef)CFArrayGetValueAtIndex(arrayRef, 0);
    bool keyframe = !CFDictionaryContainsKey(dictRef, kCMSampleAttachmentKey_NotSync);
    
    // 关键帧
    if (keyframe) {
        // 获取SPS(Sequence Parameter Set)
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr) {
            client.publisher->SendVideoFrame((char *)sparameterSet, (int)sparameterSetSize);
        }
        
        // 获取PPS(Picture Parameter Set)
        size_t pparameterSetSize, pparameterSetCount;
        const uint8_t *pparameterSet;
        statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
        if (statusCode == noErr) {
            client.publisher->SendVideoFrame((char *)pparameterSet, (int)pparameterSetSize);
        }
        
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *h264Buffer;
    statusCode = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &h264Buffer);
    if (statusCode == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        
        // 硬编码器返回的NALU数据前四个字节不是{0x00, 0x00, 0x00, 0x01}的startcode，而是大端模式的帧长度length
        // 循环获取NALU数据
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            uint32_t NALUnitLength = 0;
            // Read NALU length
            memcpy(&NALUnitLength, h264Buffer + bufferOffset, AVCCHeaderLength);
            
            // 从大端转系统端
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            // 发送帧
            char* data = (h264Buffer + bufferOffset + AVCCHeaderLength);
            client.publisher->SendVideoFrame(data, NALUnitLength);
            
            // Move to the next NALU in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
    }
}

#pragma mark - 音频编码AAC
- (BOOL)createAudioCompressionSession:(CMSampleBufferRef)sampleBuffer {
    BOOL bFlag = false;
    
    if( !_audioConverter ) {
        OSStatus status = noErr;
        
        // 音频输入格式
        AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
        
        // 音频输出格式
        AudioStreamBasicDescription outAudioStreamBasicDescription = {0};                           // 初始化输出流的结构体描述为0
        outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;     // 音频流，在正常播放情况下的帧率, 如果是压缩的格式，这个属性表示解压缩后的帧率。帧率不能为0。
        outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;                            // 设置编码格式
        outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;                          // 无损编码 ，0表示没有
        outAudioStreamBasicDescription.mChannelsPerFrame = 1;                                       // 声道数

        
        AudioClassDescription* desc = nil;
        AudioClassDescription* descArray = nil;
        unsigned int count = 0;
        
        UInt32 encodeType = kAudioFormatMPEG4AAC;
        UInt32 size;
        status = AudioFormatGetPropertyInfo(
                                            kAudioFormatProperty_Encoders,
                                            sizeof(encodeType),
                                            &encodeType,
                                            &size
                                            );
        
        if( status == noErr ) {
            count = size / sizeof(AudioClassDescription);
            descArray = new AudioClassDescription[count];
            
            status = AudioFormatGetProperty(
                                            kAudioFormatProperty_Encoders,
                                            sizeof(encodeType),
                                            &encodeType,
                                            &size,
                                            descArray
                                            );
            
            if( status == noErr ) {
                for(unsigned int i = 0; i < count; i++) {
                    if( (kAudioFormatMPEG4AAC == descArray[i].mSubType) &&
                       (kAppleSoftwareAudioCodecManufacturer == descArray[i].mManufacturer)
                       ) {
                        desc = &descArray[i];
                    }
                }
            } else {
                NSLog(@"RtmpPublisherOC::createAudioCompressionSession( AudioFormatGetProperty error encodeType : %u, status : %d )", (unsigned int)encodeType, (int)(status));
            }
            
        } else {
            NSLog(@"RtmpPublisherOC::createAudioCompressionSession( AudioFormatGetPropertyInfo error encodeType : %u, status : %d )", (unsigned int)encodeType, (int)(status));
        }
        
        if( status == noErr ) {
            // 创建转换器
            status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, desc, &_audioConverter);
            if( status == noErr ) {
//                // 设置码率
//                uint32_t audioBitrate = 10 * 1000;
//                uint32_t audioBitrateSize = sizeof(audioBitrate);
//                status = AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, audioBitrateSize, &audioBitrate);
                
                _audioAACBuffer.mDataByteSize = 1024;
                _audioAACBuffer.mData = (void *)malloc(_audioAACBuffer.mDataByteSize * sizeof(uint8_t));
                
                bFlag = YES;
                
            } else {
                NSLog(@"RtmpPublisherOC::createAudioCompressionSession( AudioConverterNewSpecific error encodeType : %u, status : %d )", (unsigned int)encodeType, (int)(status));
            }
        }
        
        if( descArray ) {
            delete[] descArray;
        }
    }
    
    return bFlag;
}

- (void)destroyAudioCompressionSession {
    if( _audioConverter ) {
        AudioConverterDispose(_audioConverter);
        _audioConverter = NULL;
    }
    
    if( _audioAACBuffer.mData ) {
        free(_audioAACBuffer.mData);
        _audioAACBuffer.mData = NULL;
    }
}

static OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData) {
    RtmpPublisherOC *encoder = (__bridge RtmpPublisherOC *)(inUserData);
    // 编码器需要的PCM数据大小
    UInt32 requestedPackets = *ioNumberDataPackets;
    
    // 已经获取的PCM数据大小
    size_t copiedSamples = [encoder copyPCMSamplesIntoBuffer:ioData];
    if( copiedSamples < requestedPackets ) {
        // 缓存数据不够, 返回继续等待
        *ioNumberDataPackets = 0;
        return -1;
    }
    
    *ioNumberDataPackets = 1;
    
    return noErr;
}

- (size_t)copyPCMSamplesIntoBuffer:(AudioBufferList*)ioData {
    // 填充PCM到缓冲区
    size_t size = _audioPCMBuffer.mDataByteSize;
    if( size > 0 ) {
        ioData->mBuffers[0].mData = _audioPCMBuffer.mData;
        ioData->mBuffers[0].mDataByteSize = _audioPCMBuffer.mDataByteSize;
        
        // 清空旧的Buffer
        _audioPCMBuffer.mData = NULL;
        _audioPCMBuffer.mDataByteSize = 0;
    }
    return size;
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification*)notification {
    if( _isBackGround == NO ) {
        _isBackGround = YES;
        
        // 销毁硬编码器
        [self destroyVideoCompressionSession];
    }
}

- (void)willEnterForeground:(NSNotification*)notification {
    if( _isBackGround == YES ) {
        _isBackGround = NO;
        // 重置视频编码器
        [self createVideoCompressionSession];
    }
}

#pragma mark - 私有方法
- (void)writeDataToFile:(const void *)bytes length:(NSUInteger)length filePath:(NSString *)filePath {
    NSData* data = [NSData dataWithBytes:bytes length:length];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if( !fileHandle ) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    
    if( fileHandle ) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    }
}


@end
