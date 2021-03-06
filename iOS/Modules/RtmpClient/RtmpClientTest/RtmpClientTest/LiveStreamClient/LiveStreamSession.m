//
//  LiveStreamSession.m
//  livestream
//
//  Created by Max on 2017/8/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveStreamSession.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

static LiveStreamSession *gSession = nil;

@interface LiveStreamSession ()
@property (assign) NSInteger playingCount;
@property (assign) NSInteger capturingCount;
@property (strong) dispatch_queue_t sessionQueue;
@end

@implementation LiveStreamSession
#pragma mark - 获取实例
+ (instancetype)session {
    if (gSession == nil) {
        gSession = [[[self class] alloc] init];
    }
    return gSession;
}

- (id)init {
    NSLog(@"LiveStreamSession::init()");
    if (self = [super init]) {
        self.playingCount = 0;
        self.capturingCount = 0;

        self.sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];

        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProximityStateDidChangeNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"LiveStreamSession::dealloc()");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - Session控制
- (void)activeSession:(BOOL)isPlayAndRecord {
    NSLog(@"LiveStreamSession::activeSession(), isPlayAndRecord: %d", isPlayAndRecord);

    dispatch_async(self.sessionQueue, ^{
        /**
         * 1.必须使用AVAudioSessionCategoryPlayAndRecord, 然后audioCaptureSession.automaticallyConfiguresApplicationAudioSession = NO
         */
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ( isPlayAndRecord ) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                          withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetoothA2DP
                                error:nil];
        } else {
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        }

        NSError *error = nil;
        [audioSession setActive:YES error:&error];
        if (error) {
            NSLog(@"LiveStreamSession::activeSession( error : %@ )", error);
        }
    });
}

- (void)inactiveSession {
    NSLog(@"LiveStreamSession::inactiveSession()");

    dispatch_async(self.sessionQueue, ^{
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *error = nil;
        [audioSession setActive:NO error:&error];
        if (error) {
            NSLog(@"LiveStreamSession::inactiveSession( error : %@ )", error);
        }
    });
}

- (void)startPlay {
    NSLog(@"LiveStreamSession::startPlay()");

    @synchronized(self) {
        if (self.playingCount == 0 && self.capturingCount == 0) {
            // 开启后台播放
            [[LiveStreamSession session] activeSession:NO];
        }
        self.playingCount++;

        if (self.capturingCount == 0) {
            [self handleRouteChange:nil];
        }
    }
}

- (void)stopPlay {
    NSLog(@"LiveStreamSession::stopPlay()");

    @synchronized(self) {
        if (self.playingCount > 0) {
            self.playingCount--;

            if (self.capturingCount == 0 && self.playingCount == 0) {
                // 禁止后台播放
                [[LiveStreamSession session] inactiveSession];
            }
        }
    }
}

- (void)startCapture {
    NSLog(@"LiveStreamSession::startCapture()");

    @synchronized(self) {
//        if (self.playingCount == 0 && self.capturingCount == 0) {
        if (self.capturingCount == 0) {
            // 开启后台播放
            [[LiveStreamSession session] activeSession:YES];
        }

        self.capturingCount++;

        [self handleRouteChange:nil];
    }
}

- (void)stopCapture {
    NSLog(@"LiveStreamSession::stopCapture()");

    @synchronized(self) {
        self.capturingCount--;

        if (self.capturingCount == 0 && self.playingCount > 0) {
            [self handleRouteChange:nil];
        }

        if (self.capturingCount == 0 && self.playingCount == 0) {
            // 禁止后台播放
            [[LiveStreamSession session] inactiveSession];
        }
        else if ( self.capturingCount == 0 && self.playingCount > 0 ) {
            [[LiveStreamSession session] activeSession:NO];
        }
    }
}

#pragma mark - 检查权限
- (void)checkAudio:(_Nullable CheckHandler)handler {
    __block BOOL bFlag = NO;
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined: {
            // 未询问用户是否授权
            [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
                                                  withObject:^(BOOL granted) {
                                                      handler(granted);
                                                  }];
        } break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 已拒绝
            bFlag = NO;
            handler(bFlag);
        } break;
        case AVAuthorizationStatusAuthorized: {
            // 已授权
            bFlag = YES;
            handler(bFlag);
        } break;
        default:
            break;
    }
}

- (void)checkVideo:(_Nullable CheckHandler)handler {
    __block BOOL bFlag = NO;
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined: {
            // 未询问用户是否授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         handler(granted);
                                     }];
        } break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 已拒绝
            bFlag = NO;
            handler(bFlag);
        } break;
        case AVAuthorizationStatusAuthorized: {
            // 已授权
            bFlag = YES;
            handler(bFlag);
        } break;
        default:
            break;
    }
}

- (BOOL)canCapture {
    __block BOOL bFlag = NO;

    // 检查录音权限(同步方法)
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession performSelector:@selector(requestRecordPermission:)
                       withObject:^(BOOL granted) {
                           if (granted) {
                               bFlag = YES;
                           } else {
                               bFlag = NO;
                           }
                       }];

    if (bFlag) {
        // 检查摄像头权限
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (videoAuthStatus) {
            case AVAuthorizationStatusNotDetermined: {
                // 未询问用户是否授权
            } break;
            case AVAuthorizationStatusRestricted: {
                // 已拒绝
            };
            case AVAuthorizationStatusDenied: {
                bFlag = NO;
            } break;
            case AVAuthorizationStatusAuthorized: {
                // 已授权
            } break;
            default:
                break;
        }
    }

    return bFlag;
}

- (BOOL)hasHeadphones {
    bool bFlag = NO;
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *outputs = [route outputs];
    for (AVAudioSessionPortDescription *desc in outputs) {
        NSString *portType = [desc portType];
//        NSLog(@"LiveStreamSession::hasHeadphones( portType : %@ )", portType);
        if (
            // 耳机
            [portType isEqualToString:AVAudioSessionPortHeadphones]
            // 蓝牙设备
            || [portType isEqualToString:AVAudioSessionPortBluetoothA2DP]
            //            // 贴近耳朵
            //            || [portType isEqualToString:AVAudioSessionPortBuiltInReceiver]
            ) {
            bFlag = YES;
            break;
        }
    }

    if (bFlag) {
        NSLog(@"LiveStreamSession::hasHeadphones( [Headphones or Bluetooth Output] )");
    } else {
        NSLog(@"LiveStreamSession::hasHeadphones( [Speaker] )");
    }

    return bFlag;
}

- (void)handleRouteChange:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    NSLog(@"LiveStreamSession::handleRouteChange( AVAudioSessionRouteChangeReasonKey : %@ )", dictionary[AVAudioSessionRouteChangeReasonKey]);

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.capturingCount == 0 && self.playingCount > 0) {
        if (![self hasHeadphones]) {
            if ([UIDevice currentDevice].proximityState) {
                NSLog(@"LiveStreamSession::handleRouteChange(), [Near ear, using earphone]");
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            } else {
                NSLog(@"LiveStreamSession::handleRouteChange(), [Away from ear, using speaker]");
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
        } else {
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        }
    }
}

- (void)handleInterruption:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    NSLog(@"LiveStreamSession::handleInterruption( dictionary : %@ )", dictionary);
}

- (void)handleProximityStateDidChangeNotification:(NSNotification *)notification {
    [self handleRouteChange:nil];
}

@end
