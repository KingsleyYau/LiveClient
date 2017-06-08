//
//  RtmpPlayerOC.m
//  RtmpPlayerOC
//
//  Created by Max on 2017/4/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RtmpPlayerOC.h"

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

#include <rtmpdump/RtmpPlayer.h>
#include "VideoHardDecoder.h"
#include "AudioHardDecoder.h"

const size_t kAQBufSize = 128 * 1024;		// 音频播放Buffer的大小(Bytes)

class RtmpDumpCallbackPlayer;
class VideoDecoderImp;
class AudioDecoderImp;

@interface RtmpPlayerOC ()
/**
 传输模块
 */
@property (assign) RtmpPlayer* player;
@property (assign) RtmpPlayerCallback* rtmpCallback;
@property (assign) VideoDecoder* videoDecoder;
@property (assign) AudioDecoder* audioDecoder;

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
@property (assign) u_int64_t audioEncodeTimestamp;

#pragma mark - 音频解码变量
/**
 音频解码队列
 */
@property (strong) dispatch_queue_t audio_decode_queue;
@property (assign) AudioFileStreamID audioFileStream;
@property (assign) AudioQueueRef audioQueue;
/**
 创建音频解码器
 
 @return 成功失败
 */
- (BOOL)createAudioDecompressionSession;
/**
 销毁音频解码器
 */
- (void)destroyAudioDecompressionSession;
/**
 解码音频帧
 
 @param frame 音频帧数据
 */
- (void)decodeAudioFrame:(const char *)frame size:(size_t)size timestamp:(u_int32_t)timestamp;

#pragma mark - 视频解码变量
/**
 视频解码队列
 */
@property (strong) dispatch_queue_t video_decode_queue;
/**
 视频解码器
 */
@property (assign) VTDecompressionSessionRef videoDecompressionSession;
/**
 视频解码器描述
 */
@property (assign) CMFormatDescriptionRef videoFormatDescription;
/**
 创建视频解码器
 
 @param sps Sequence Parameter Set
 @param pps Picture Parameter Set
 @param nalUnitHeaderLength NALU帧长度变量占用位数(1/2/4 byte)
 */
- (BOOL)createVideoDecompressionSession:(NSData *)sps pps:(NSData *)pps nalUnitHeaderLength:(int)nalUnitHeaderLength;
/**
 解码视频帧
 
 @param frame 视频帧数据
 */
- (void)decodeVideoFrame:(const char *)frame size:(size_t)size timestamp:(u_int32_t)timestamp;

#pragma mark - 测试
@property (strong) NSString* recordPCMFilePath;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackGround;

@property (nonatomic, strong) NSData* spsData;
@property (nonatomic, strong) NSData* ppsData;
@property (nonatomic, assign) int nalUnitHeaderLength;

//@property (nonatomic, assign) u_int32_t videoDecodeTimestamp;

@end

#pragma mark - RrmpPlayer回调
class RtmpPlayerCallbackImp : public RtmpPlayerCallback {
public:
    RtmpPlayerCallbackImp(RtmpPlayerOC* player) {
        mpPlayer = player;
    };
    
    ~RtmpPlayerCallbackImp(){};
    
    void OnDisconnect(RtmpPlayer* player) {
        NSLog(@"RtmpPlayerOC::OnDisconnect()");
    }
    
    void OnPlayVideoFrame(RtmpPlayer* player, void* frame) {
        CVPixelBufferRef buffer = (CVPixelBufferRef)frame;
        [mpPlayer.delegate rtmpPlayerOCOnRecvVideoBuffer:mpPlayer buffer:buffer];
        CFRelease(buffer);
    }
    
    void OnDropVideoFrame(RtmpPlayer* player, void* frame) {
        CMSampleBufferRef sampleBuffer = (CMSampleBufferRef)frame;
        CFRelease(sampleBuffer);
    }
    
    void OnPlayAudioFrame(RtmpPlayer* player, void* frame) {
        CFDataRef dataRef = (CFDataRef)frame;
//        dispatch_sync(mpPlayer.audio_decode_queue, ^{
            OSStatus status = noErr;
            if( mpPlayer.audioFileStream ) {
                status = AudioFileStreamParseBytes(mpPlayer.audioFileStream, (UInt32)CFDataGetLength(dataRef), CFDataGetBytePtr(dataRef), 0);
                if( status != noErr ) {
                    NSLog(@"RtmpPlayerOC::OnPlayAudioFrame( [Fail], status : %d )", status);
                }
            }
//        });
        CFRelease(dataRef);
    }
    
    void OnDropAudioFrame(RtmpPlayer* player, void* frame) {
        CFDataRef dataRef = (CFDataRef)frame;
        CFRelease(dataRef);
        
        AudioQueueReset(mpPlayer.audioQueue);
    }
    
private:
    RtmpPlayerOC* mpPlayer;

};

class VideoDecoderImp : public VideoDecoder {
public:
    VideoDecoderImp(RtmpPlayerOC* player) {
        mpPlayer = player;
    };
    
    ~VideoDecoderImp() {};
    
    bool Create() {
        return true;
    }
    
    void Destroy() {
        
    }
    
    void DecodeVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
        // 创建视频解码器
        NSData* spsData = [NSData dataWithBytes:sps length:sps_size];
        NSData* ppsData = [NSData dataWithBytes:pps length:pps_size];
        
        mpPlayer.spsData = spsData;
        mpPlayer.ppsData = ppsData;
        mpPlayer.nalUnitHeaderLength = nalUnitHeaderLength;
        
        @synchronized (mpPlayer) {
            if( !mpPlayer.isBackGround ) {
                // 解码视频
                [mpPlayer createVideoDecompressionSession:spsData pps:ppsData nalUnitHeaderLength:nalUnitHeaderLength];
            }
        }

    }
    void DecodeVideoFrame(const char* data, int size, u_int32_t timestamp, VideoFrameType video_type) {
        @synchronized (mpPlayer) {
            if( !mpPlayer.isBackGround ) {
                // 解码视频
                [mpPlayer decodeVideoFrame:data size:size timestamp:timestamp];
            }
        }
    }
    
private:
    RtmpPlayerOC* mpPlayer;
};

class AudioDecoderImp : public AudioDecoder {
public:
    AudioDecoderImp(RtmpPlayerOC* player) {
        mpPlayer = player;
    };
    
    ~AudioDecoderImp() {};
    
    void CreateAudioDecoder(
                            AudioFrameFormat format,
                            AudioFrameSoundRate sound_rate,
                            AudioFrameSoundSize sound_size,
                            AudioFrameSoundType sound_type
                            ) {
        // 创建音频解码器
        [mpPlayer destroyAudioDecompressionSession];
        [mpPlayer createAudioDecompressionSession];
    }
    
    void DecodeAudioFrame(
                          AudioFrameFormat format,
                          AudioFrameSoundRate sound_rate,
                          AudioFrameSoundSize sound_size,
                          AudioFrameSoundType sound_type,
                          const char* data,
                          int size,
                          u_int32_t timestamp
                          ) {
        // 解码音频
        [mpPlayer decodeAudioFrame:data size:size timestamp:timestamp];
        
    };
    
private:
    RtmpPlayerOC* mpPlayer;
};

@implementation RtmpPlayerOC
#pragma mark - 获取实例
+ (instancetype)instance {
    RtmpPlayerOC *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init {
    if(self = [super init] ) {
        _isBackGround = NO;
        
        self.videoDecoder = new VideoHardDecoder;
        self.audioDecoder = new AudioHardDecoder;
        self.rtmpCallback = new RtmpPlayerCallbackImp(self);
        
        [self createAudioDecompressionSession];
        
        self.player = new RtmpPlayer(self.videoDecoder, self.audioDecoder, self.rtmpCallback);
        self.videoDecoder->Create(self.player);
        self.audioDecoder->Create(self.player);
        
        // 创建音频解码队列
        self.audio_decode_queue = dispatch_queue_create("_audio_decode_queue", NULL);
        _audioFileStream = NULL;
        _audioQueue = NULL;
    
        // 创建视频解码队列
        self.video_decode_queue = dispatch_queue_create("_video_decode_queue", NULL);
        _videoDecompressionSession = NULL;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];

    }
    
    return self;
}

- (void)dealloc {
    if( self.player ) {
        delete self.player;
        self.player = NULL;
    }
    
    if( self.videoDecoder ) {
        delete self.videoDecoder;
        self.videoDecoder = NULL;
    }
    
    if( self.audioDecoder ) {
        delete self.audioDecoder;
        self.audioDecoder = NULL;
    }
    
    // 销毁视频解码器
    [self destroyVideoDecompressionSession];
    
    // 销毁音频解码器
    [self destroyAudioDecompressionSession];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPlayerOC::playUrl( url : %@, recordFilePath : %@, recordH264FilePath : %@, recordAACFilePath : %@ )", url, recordFilePath, recordH264FilePath, recordAACFilePath);
    self.recordPCMFilePath = [NSString stringWithFormat:@"%@.pcm", recordAACFilePath];
    
    bFlag = self.player->PlayUrl([url UTF8String], [recordFilePath UTF8String], [recordH264FilePath UTF8String], [recordAACFilePath UTF8String]);
    
    if( bFlag ) {
    }
    
    return bFlag;
}

- (void)stop {
    self.player->Stop();
    
    // 停止播放
    AudioQueueFlush(self.audioQueue);
    AudioQueueStop(self.audioQueue, YES);

    // 销毁音频解码器
    [self destroyAudioDecompressionSession];
    // 销毁视频解码器
    [self destroyVideoDecompressionSession];
}

#pragma mark - 视频硬解码H264
- (BOOL)createVideoDecompressionSession:(NSData *)sps pps:(NSData *)pps nalUnitHeaderLength:(int)nalUnitHeaderLength {
    BOOL bFlag = false;
    
    if( !_videoDecompressionSession ) {
        OSStatus status;
        
#define parameterSetCount 2
        const uint8_t* const parameterSetPointers[parameterSetCount] = { (const uint8_t*)[sps bytes], (const uint8_t*)[pps bytes] };
        const size_t parameterSetSizes[parameterSetCount] = { [sps length], [pps length] };
        status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
                                                                     kCFAllocatorDefault,
                                                                     parameterSetCount,
                                                                     parameterSetPointers,
                                                                     parameterSetSizes,
                                                                     nalUnitHeaderLength,
                                                                     &_videoFormatDescription
                                                                     );
        
        if( status == noErr ) {
            VTDecompressionOutputCallbackRecord callBackRecord;
            callBackRecord.decompressionOutputCallback = decompressionOutputCallback;
            // this is necessary if you need to make calls to Objective C "self" from within in the callback method.
            callBackRecord.decompressionOutputRefCon = (__bridge void *)self;
            
            // you can set some desired attributes for the destination pixel buffer.  I didn't use this but you may
            // if you need to set some attributes, be sure to uncomment the dictionary in VTDecompressionSessionCreate
            NSDictionary *destinationImageBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                              //                                                          [NSNumber numberWithBool:NO], (id)kCVPixelBufferOpenGLESCompatibilityKey,
                                                              [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
                                                              nil
                                                              ];
            
            status = VTDecompressionSessionCreate(
                                                  kCFAllocatorDefault,
                                                  _videoFormatDescription,
                                                  NULL,
                                                  (__bridge CFDictionaryRef)(destinationImageBufferAttributes),
                                                  &callBackRecord,
                                                  &_videoDecompressionSession
                                                  );
            
            bFlag = (status == noErr);
        }
    }
    
    return bFlag;
}

- (void)destroyVideoDecompressionSession {
    if( _videoDecompressionSession ) {
        VTDecompressionSessionInvalidate(_videoDecompressionSession);
        CFRelease(_videoDecompressionSession);
        _videoDecompressionSession = NULL;
    }
}

typedef struct _tagDecodeItem {
    void* source;
    u_int32_t timestamp;
    
    _tagDecodeItem() {
        source = NULL;
        timestamp = 0;
    }
} DecodeItem;

- (void)decodeVideoFrame:(const char *)frame size:(size_t)size timestamp:(u_int32_t)timestamp {
    dispatch_sync(self.video_decode_queue, ^{
        OSStatus status = noErr;
        CMBlockBufferRef blockBuffer = NULL;
        status = CMBlockBufferCreateWithMemoryBlock(
                                                    kCFAllocatorDefault,
                                                    (void *)frame,
                                                    size,
                                                    kCFAllocatorNull,
                                                    NULL,
                                                    0,
                                                    size,
                                                    0,
                                                    &blockBuffer
                                                    );
        if( status == kCMBlockBufferNoErr ) {
            CMSampleBufferRef sampleBuffer = NULL;
            const size_t sampleSizeArray[] = {size};
            status = CMSampleBufferCreateReady(
                                               kCFAllocatorDefault,
                                               blockBuffer,
                                               _videoFormatDescription,
                                               1,
                                               0,
                                               NULL,
                                               1,
                                               sampleSizeArray,
                                               &sampleBuffer
                                               );
            
            if( status == kCMBlockBufferNoErr ) {
                VTDecodeFrameFlags flags = 0;
                VTDecodeInfoFlags flagOut = 0;
//                CVPixelBufferRef outputPixelBuffer = NULL;
                DecodeItem item;
                item.timestamp = timestamp;
                item.source = (__bridge void *)self;
                
                FileLog("rtmpdump",
                        "RtmpPlayerOC::OnRecvVideoFrame(\t"
                        "timestamp : %d, "
                        "size : %d"
                        ")",
                        timestamp,
                        size
                        );
                
//                self.videoDecodeTimestamp = timestamp;
                status = VTDecompressionSessionDecodeFrame(
                                                           _videoDecompressionSession,
                                                           sampleBuffer,
                                                           flags,
                                                           &item,
                                                           &flagOut
                                                           );
                
                if( status == noErr ) {
                    // 放到播放队列
//                    CFRetain(sampleBuffer);
//                    self.player->PushVideoFrame(outputPixelBuffer, timestamp);

                }
                CFRelease(sampleBuffer);
            }
            
            CFRelease(blockBuffer);
        }
        
        if( status != noErr ) {
            NSLog(@"decodeVideoFrame( [Fail], noErr : %d ) ", status);
        }
    });
}

static void decompressionOutputCallback (
                                         void * CM_NULLABLE decompressionOutputRefCon,
                                         void * CM_NULLABLE sourceFrameRefCon,
                                         OSStatus status,
                                         VTDecodeInfoFlags infoFlags,
                                         CM_NULLABLE CVImageBufferRef imageBuffer,
                                         CMTime presentationTimeStamp,
                                         CMTime presentationDuration
                                         ) {

    if( status == noErr && imageBuffer != NULL ) {
//        // 放到播放队列
        DecodeItem* item = (DecodeItem*)sourceFrameRefCon;
        RtmpPlayerOC* playerOC = (__bridge RtmpPlayerOC *)item->source;
//        RtmpPlayer* player = playerOC->_player;
//        CFRetain(imageBuffer);
//        player->PushVideoFrame(imageBuffer, playerOC.videoDecodeTimestamp);
        
        // for test
        FileLog("rtmpdump",
                "Callback::OnRecvVideoFrame(\t"
                "timestamp : %d "
                ")",
                item->timestamp
                );
        
        CIImage* ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgiimage = [context createCGImage:ciImage fromRect:ciImage.extent];
        UIImage* uiImage = [UIImage imageWithCGImage:cgiimage];
        
        NSString* imageName = [NSString stringWithFormat:@"%.7d.png", item->timestamp];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        NSData* dataImage = UIImagePNGRepresentation(uiImage);
        [dataImage writeToFile:filePath atomically:YES];
    }
}

#pragma mark - 音频解码AAC
- (BOOL)createAudioDecompressionSession {
    BOOL bFlag = false;
    if( !_audioFileStream ) {
        OSStatus status = AudioFileStreamOpen((__bridge void *)self, inPropertyListenerProc, inPacketsProc, kAudioFileAAC_ADTSType, &_audioFileStream);
        bFlag = (status == noErr);
        if( status != noErr ) {
            NSLog(@"RtmpPlayerOC::createAudioDecompressionSession( [Fail], status : %d )",  status);
        }
    }
    
    return bFlag;
}

- (void)destroyAudioDecompressionSession {
    if( _audioQueue ) {
        AudioQueueDispose(_audioQueue, YES);
        _audioQueue = NULL;
    }
    
    if( _audioFileStream ) {
        AudioFileStreamClose(_audioFileStream);
        _audioFileStream = NULL;
    }
}

- (void)decodeAudioFrame:(const char *)frame size:(size_t)size timestamp:(u_int32_t)timestamp {
    // 放回播放队列
    CFDataRef dataRef = CFDataCreate(NULL, (const UInt8 *)frame, size);
    self.player->PushAudioFrame((void *)dataRef, timestamp);
}

static void inPropertyListenerProc(
                                   void *							inClientData,
                                   AudioFileStreamID				inAudioFileStream,
                                   AudioFileStreamPropertyID		inPropertyID,
                                   UInt32 *						ioFlags
                                   ) {
    
    RtmpPlayerOC* client = (__bridge RtmpPlayerOC *)inClientData;
    OSStatus status = noErr;
    UInt32 size = 0;
    
    switch (inPropertyID) {
        case kAudioFileStreamProperty_ReadyToProducePackets :
        {
            // the file stream parser is now ready to produce audio packets.
            // get the stream format.
            AudioStreamBasicDescription asbd;
            size = sizeof(asbd);
            status = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &size, &asbd);
            if( status != noErr ) {
                NSLog(@"RtmpPlayerOC::AudioFileStreamGetProperty( [kAudioFileStreamProperty_DataFormat Fail], status : %d )", status);
            }
            
            // create the audio queue
            if( status == noErr ) {
                status = AudioQueueNewOutput(&asbd, audioQueueOutputCallback, (__bridge void *)client, NULL, NULL, 0, &(client->_audioQueue));
                if( status != noErr ) {
                    NSLog(@"RtmpPlayerOC::AudioQueueNewOutput( [Fail], status : %d )", status);
                } else {
                    status = AudioQueueStart(client->_audioQueue, NULL);
                    if( status != noErr ) {
                        NSLog(@"RtmpPlayerOC::AudioQueueStart( [Fail], status : %d )", status);
                    }
                }
            }
                        
            // listen for kAudioQueueProperty_IsRunning
            if( status == noErr ) {
                status = AudioQueueAddPropertyListener(client.audioQueue, kAudioQueueProperty_IsRunning, audioQueuePropertyListenerProc, (__bridge void *)client);
                if( status != noErr ) {
                    NSLog(@"RtmpPlayerOC::AudioQueueAddPropertyListener( [kAudioQueueProperty_IsRunning Fail], status : %d )", status);
                }
            }
            
        }break;

    }
    
}

static void inPacketsProc(
                   void *							inClientData,
                   UInt32							inNumberBytes,
                   UInt32							inNumberPackets,
                   const void *                     inInputData,
                   AudioStreamPacketDescription *   inPacketDescriptions
                   ) {
    RtmpPlayerOC* client = (__bridge RtmpPlayerOC *)inClientData;
    OSStatus status = noErr;
    
    for (int i = 0; i < inNumberPackets; ++i) {
        SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
        UInt32 packetSize   = inPacketDescriptions[i].mDataByteSize;
        
        // 申请音频包内存
        AudioQueueBufferRef audioBuffer;
        status = AudioQueueAllocateBuffer(client.audioQueue, kAQBufSize, &audioBuffer);
        if( status == noErr ) {
            // 复制内容
            audioBuffer->mAudioDataByteSize = packetSize;
            memcpy(audioBuffer->mAudioData, (const char *)inInputData + packetOffset, packetSize);
            
            // 放入音频包
            AudioStreamPacketDescription desc = inPacketDescriptions[i];
            desc.mStartOffset = 0;
            status = AudioQueueEnqueueBuffer(client.audioQueue, audioBuffer, 1, &desc);

            if( status == noErr ) {
                // 播放音频包
                [client playAudioBuffer];

            } else {
                NSLog(@"RtmpPlayerOC::inPacketsProc( [AudioQueueEnqueueBuffer Fail], status : %d )", status);
            }
            
        } else {
            NSLog(@"RtmpPlayerOC::inPacketsProc( [AudioQueueAllocateBuffer Fail], status : %d )", status);
        }
        
    }
}

static void audioQueueOutputCallback(
                              void * __nullable       inUserData,
                              AudioQueueRef           inAQ,
                              AudioQueueBufferRef     inBuffer
                              ) {
    
//    RtmpPlayerOC* client = (__bridge RtmpPlayerOC *)inUserData;
//    OSStatus status = noErr;
    
    // 释放内存/或者归还缓存
    AudioQueueFreeBuffer(inAQ, inBuffer);
}

static void audioQueuePropertyListenerProc(
                                    void * __nullable       inUserData,
                                    AudioQueueRef           inAQ,
                                    AudioQueuePropertyID    inID
                                    ) {
//    RtmpPlayerOC* client = (__bridge RtmpPlayerOC *)inUserData;
    OSStatus status = noErr;
    
    // 用于处理中断播放
    UInt32 running;
    UInt32 size;
    status = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &size);
    if( status == noErr ) {
        if( !running ) {
            // 播放已经停止
            NSLog(@"RtmpPlayerOC::audioQueuePropertyListenerProc( running : %d )", running);
        }
    }
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackGround == NO ) {
            _isBackGround = YES;
            
            // 销毁硬编码器
            [self destroyVideoDecompressionSession];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackGround == YES ) {
            _isBackGround = NO;
            // 重置视频编码器
            [self createVideoDecompressionSession:self.spsData pps:self.ppsData nalUnitHeaderLength:self.nalUnitHeaderLength];
        }
    }
}

#pragma mark - 私有方法
- (void)playAudioBuffer {
//    AudioQueueReset(self.audioQueue);
//    OSStatus status = noErr;
//    UInt32 outNumberOfFramesPrepared;
//    status = AudioQueuePrime(self.audioQueue, 0, &outNumberOfFramesPrepared);
////    status = AudioQueueStart(self.audioQueue, NULL);
//    if( status != noErr ) {
//        NSLog(@"RtmpPlayerOC::playAudioBuffer( [Fail], status : %d )", status);
//    }
}

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
