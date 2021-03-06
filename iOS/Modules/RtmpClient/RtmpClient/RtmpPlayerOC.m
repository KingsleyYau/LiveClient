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

#pragma mark - 渲染器
#include <rtmpdump/iOS/VideoRendererImp.h>
#include <rtmpdump/iOS/AudioRendererImp.h>

#pragma mark - 软解码器
#include <rtmpdump/video/VideoDecoderH264.h>
#include <rtmpdump/audio/AudioDecoderAAC.h>

#pragma mark - 硬解码器
#include <rtmpdump/iOS/VideoHardDecoder.h>

#pragma mark - 硬渲染器
#include <rtmpdump/iOS/VideoHardRendererImp.h>

#pragma mark - 播放控制器
#include <rtmpdump/PlayerController.h>

using namespace coollive;

class PlayerStatusCallbackImp;

@interface RtmpPlayerOC () <VideoRendererDelegate, VideoHardRendererDelegate> {
    BOOL _useHardDecoder;
}

#pragma mark - 播放器
@property (assign) PlayerController* player;
#pragma mark - 状态回调
@property (assign) PlayerStatusCallbackImp* statusCallback;

#pragma mark - 软渲染器
@property (assign) VideoRenderer* videoRenderer;
@property (assign) AudioRenderer* audioRenderer;

#pragma mark - 解码器
@property (assign) VideoDecoder* videoDecoder;
@property (assign) AudioDecoder* audioDecoder;

#pragma mark - 后台处理
@property (nonatomic) BOOL isBackground;

@end

#pragma mark - PlayerStatusCallback回调
class PlayerStatusCallbackImp : public PlayerStatusCallback {
public:
    PlayerStatusCallbackImp(RtmpPlayerOC* rtmpPlayerOC) {
        mpRtmpPlayerOC = rtmpPlayerOC;
    }
    
    ~PlayerStatusCallbackImp() {
        
    }
    
    void OnPlayerConnect(PlayerController* pc) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnConnect:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnConnect:mpRtmpPlayerOC];
        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            int num = 300 + arc4random() % 100;
//            NSString *user = [NSString stringWithFormat:@"MM%d", num];
//            mpRtmpPlayerOC.player->SendCmdLogin([user UTF8String], "123456", "4");
//            mpRtmpPlayerOC.player->SendCmdMakeCall("WW0", "PC4", "4");
//            mpRtmpPlayerOC.player->SendCmdReceive();
//        });
    }
    
    void OnPlayerDisconnect(PlayerController* pc) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnDisconnect:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnDisconnect:mpRtmpPlayerOC];
        }
    }
    
    void OnPlayerOnDelayMaxTime(PlayerController* pc) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnPlayerOnDelayMaxTime:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnPlayerOnDelayMaxTime:mpRtmpPlayerOC];
        }
    }
    
    void OnPlayerInfoChange(PlayerController *pc, int videoDisplayWidth, int vieoDisplayHeight) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnInfoChange:videoDisplayWidth:vieoDisplayHeight:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnInfoChange:mpRtmpPlayerOC videoDisplayWidth:videoDisplayWidth vieoDisplayHeight:vieoDisplayHeight];
        }
    }
    
    void OnPlayerStats(PlayerController *pc, unsigned int fps, unsigned int bitrate) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnStats:fps:bitrate:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnStats:mpRtmpPlayerOC fps:fps bitrate:bitrate];
        }
    }
    
    void OnPlayerError(PlayerController *pc, const string& code, const string& description) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnError:code:description:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnError:mpRtmpPlayerOC code:[NSString stringWithUTF8String:code.c_str()] description:[NSString stringWithUTF8String:description.c_str()]];
        }
    }
    
    void OnPlayerFinish(PlayerController *pc) {
        if( [mpRtmpPlayerOC.delegate respondsToSelector:@selector(rtmpPlayerOnFinish:)] ) {
            [mpRtmpPlayerOC.delegate rtmpPlayerOnFinish:mpRtmpPlayerOC];
        }
    }
    
private:
    __weak typeof(RtmpPlayerOC) *mpRtmpPlayerOC;
};

@implementation RtmpPlayerOC

#pragma mark - 获取实例
+ (instancetype)instance {
    RtmpPlayerOC *obj = [[[self class] alloc] init];
    return obj;
}

- (instancetype)init {
    NSLog(@"RtmpPlayerOC::init( self : %p )", self);
    
    if(self = [super init] ) {
        // 默认在前台
        _isBackground = NO;

        // 创建播放控制器
        self.player = new PlayerController();
        self.statusCallback = new PlayerStatusCallbackImp(self);
        self.player->SetStatusCallback(self.statusCallback);
        self.player->SetCacheMS(2000);
        
#if TARGET_OS_SIMULATOR
        // 模拟器, 默认使用软解码
        _useHardDecoder = NO;
#else
        // 真机, 默认使用硬解码
        _useHardDecoder = YES;
#endif
        
        // 创建解码器和渲染器
        [self createDecoders];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"RtmpPlayerOC::dealloc( self : %p )", self);
    
    if( self.statusCallback ) {
        delete self.statusCallback;
        self.statusCallback = NULL;
    }
    
    if( self.player ) {
        delete self.player;
        self.player = NULL;
    }
    
    [self destroyDecoders];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - 对外接口
- (BOOL)playUrl:(NSString * _Nonnull)url recordFilePath:(NSString *)recordFilePath recordH264FilePath:(NSString *)recordH264FilePath recordAACFilePath:(NSString * _Nullable)recordAACFilePath {
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPlayerOC::playUrl( self : %p, url : %@, recordFilePath : %@, recordH264FilePath : %@, recordAACFilePath : %@ )", self, url, recordFilePath, recordH264FilePath, recordAACFilePath);
    
    bFlag = self.player->PlayUrl([url UTF8String], [recordFilePath UTF8String], [recordH264FilePath UTF8String], [recordAACFilePath UTF8String]);
    
    if( bFlag ) {
    }
    
    return bFlag;
}

- (BOOL)playFilePath:(NSString * _Nonnull)filePath {
    BOOL bFlag = YES;
    
    NSLog(@"RtmpPlayerOC::playFilePath( self : %p, filePath : %@ )", self, filePath);
    
    bFlag = self.player->PlayFile([filePath UTF8String]);
    
    if( bFlag ) {
    }
    
    return bFlag;
}

- (void)stop {
    NSLog(@"RtmpPlayerOC::stop( self : %p )", self);
    
    self.player->Stop();
    
    NSLog(@"RtmpPlayerOC::stop( [Finish], self : %p )", self);
}

+ (void)combine:(NSArray<NSString *> *)srcFilePaths dstFilePath:(NSString *)dstFilePath {
    vector<string> cSrcFilesPath;
    if (srcFilePaths.count > 0) {
        for(int i = 0; i < srcFilePaths.count; i++) {
            cSrcFilesPath.push_back([srcFilePaths[i] UTF8String]);
        }
        MediaFileReader::CombineFile(cSrcFilesPath, [dstFilePath UTF8String]);
    }
}

#pragma mark - 私有方法
- (NSInteger)cacheMS {
    return self.player->CacheMS();
}

- (void)setCacheMS:(NSInteger)cacheMS {
    self.player->SetCacheMS((int)cacheMS);
}

- (BOOL)mute {
    BOOL bMute = NO;
    if( self.audioRenderer ) {
        bMute = self.audioRenderer->GetMute();
    }
    return bMute;
}

- (void)setMute:(BOOL)mute {
    if( self.audioRenderer ) {
        self.audioRenderer->SetMute(mute);
    }
}

- (void)setPlaybackRate:(float)playbackRate {
    self.player->SetPlaybackRate(playbackRate);
}

- (BOOL)useHardDecoder {
    return _useHardDecoder;
}

- (void)setUseHardDecoder:(BOOL)useHardDecoder {
    if( _useHardDecoder != useHardDecoder ) {
        [self destroyDecoders];
        
        _useHardDecoder = useHardDecoder;
    
        [self createDecoders];
    }
}

- (void)renderVideoFrame:(CVPixelBufferRef _Nonnull)buffer {
    [self.delegate rtmpPlayerRenderVideoFrame:self buffer:buffer];
}

- (void)createDecoders {
    if( _useHardDecoder ) {
        // 硬解码
        
        // 创建硬渲染器
        self.videoRenderer = new VideoHardRendererImp(self);
        self.audioRenderer = new AudioRendererImp();
        
        // 创建硬解码器
        self.videoDecoder = new VideoHardDecoder();
        self.audioDecoder = new AudioDecoderAAC();
        
    } else {
        // 软解码
        
        // 创建软渲染器
        self.videoRenderer = new VideoRendererImp(self);
        self.audioRenderer = new AudioRendererImp();

        // 创建解码器
        self.videoDecoder = new VideoDecoderH264();
        self.audioDecoder = new AudioDecoderAAC();

    }
    
    // 替换解码器
    self.player->SetVideoRenderer(self.videoRenderer);
    self.player->SetAudioRenderer(self.audioRenderer);
    
    // 替换渲染器
    self.player->SetVideoDecoder(self.videoDecoder);
    self.player->SetAudioDecoder(self.audioDecoder);
}

- (void)destroyDecoders {
    if( self.videoRenderer ) {
        delete self.videoRenderer;
        self.videoRenderer = nil;
    }
    
    if( self.audioRenderer ) {
        delete self.audioRenderer;
        self.audioRenderer = nil;
    }
    
    if( self.videoDecoder ) {
        delete self.videoDecoder;
        self.videoDecoder = nil;
    }
    
    if( self.audioDecoder ) {
        delete self.audioDecoder;
        self.audioDecoder = nil;
    }
}

#pragma mark - 视频采集后台
- (void)willEnterBackground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackground == NO ) {
            _isBackground = YES;
            
            // 销毁硬解码器
            if( self.videoDecoder ) {
                self.videoDecoder->Pause();
            }
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    @synchronized (self) {
        if( _isBackground == YES ) {
            _isBackground = NO;
            
            // 重置硬视频解码器
            if( self.videoDecoder ) {
                self.videoDecoder->Reset();
            }
        }
    }
}

@end
