//
//  LiveStreamSession.m
//  livestream
//
//  Created by Max on 2017/8/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveStreamSession.h"

#import <AVFoundation/AVFoundation.h>

static LiveStreamSession* gSession = nil;

@interface LiveStreamSession ()
@property (assign) NSInteger playingCount;
@property (assign) NSInteger capturingCount;
@end

@implementation LiveStreamSession
#pragma mark - 获取实例
+ (instancetype)session {
    if( gSession == nil ) {
        gSession = [[[self class] alloc] init];
    }
    return gSession;
}

- (id)init {
    NSLog(@"LiveStreamSession::init()");
    if( self = [super init] ) {
        self.playingCount = 0;
        self.capturingCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"LiveStreamSession::dealloc()");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - Session控制
- (void)activeSession {
    /**
     * 1.必须使用AVAudioSessionCategoryPlayAndRecord, 然后audioCaptureSession.automaticallyConfiguresApplicationAudioSession = NO
     */
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)startPlay {
    @synchronized (self) {
        self.playingCount++;
        
        if( self.capturingCount == 0 ) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if( ![self useHeadphones] ) {
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
        }
    }
}

- (void)stopPlay {
    @synchronized (self) {
        self.playingCount--;
    }
}

- (void)startCapture {
    @synchronized (self) {
        self.capturingCount++;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}

- (void)stopCapture {
    @synchronized (self) {
        self.capturingCount--;
        
        if( self.capturingCount == 0 && self.playingCount > 0 ) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if( ![self useHeadphones] ) {
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
        }
    }
}

- (BOOL)canCapture {
    __block BOOL bFlag = NO;
    
    // 检查录音权限(同步方法)
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
        if (granted) {
            bFlag = YES;
        } else {
            bFlag = NO;
        }
    }];
    
    if( bFlag ) {
        // 检查摄像头权限
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (videoAuthStatus) {
            case AVAuthorizationStatusNotDetermined:{
                // 未询问用户是否授权
            }break;
            case AVAuthorizationStatusRestricted:{
                // 已拒绝
            };
            case AVAuthorizationStatusDenied:{
                bFlag = NO;
            }break;
            case AVAuthorizationStatusAuthorized:{
                // 已授权
            }break;
            default:
                break;
        }
    }
    
    return bFlag;
}

- (BOOL)useHeadphones {
    bool bFlag = NO;
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            bFlag = YES;
            break;
        }
    }
    return bFlag;
}

- (void)handleRouteChange:(NSNotification *)notification {
//    NSDictionary *dictionary = notification.userInfo;
//    NSLog(@"LiveStreamSession::handleRouteChange( dictionary : %@ )", dictionary);
    
    if( self.capturingCount == 0 && self.playingCount > 0 ) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if( ![self useHeadphones] ) {
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        } else {
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        }
    }
}

- (void)handleInterruption:(NSNotification *)notification {
//    NSDictionary *dictionary = notification.userInfo;
//    NSLog(@"LiveStreamSession::handleInterruption( dictionary : %@ )", dictionary);
}

@end
