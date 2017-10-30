//
//  LiveGobalManager.m
//  livestream
//
//  Created by Max on 2017/10/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveGobalManager.h"
#import "LSImManager.h"
#import "LiveModule.h"

static LiveGobalManager *gManager = nil;
@interface LiveGobalManager () {
}
#pragma mark - 前后台切换逻辑
@property (assign) BOOL isBackground;
@property (strong) NSDate *enterBackgroundTime;
@property (strong) NSDate *startTime;
@property (strong) dispatch_queue_t backgroundQueue;
@property (assign) UIBackgroundTaskIdentifier bgTask;

@end
;

@implementation LiveGobalManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    NSLog(@"LiveGobalManager::init()");

    if (self = [super init]) {
        if (!self.backgroundQueue) {
            self.backgroundQueue = dispatch_queue_create("backgroundQueue", DISPATCH_QUEUE_SERIAL);
        }

        // 注册前后台切换通知
        _isBackground = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"LiveGobalManager::dealloc()");

    // 注销前后台切换通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 后台处理
- (void)willEnterBackground:(NSNotification *)notification {
    if (_isBackground == NO) {
        _isBackground = YES;

        NSLog(@"LiveGobalManager::willEnterBackground()");

        // 进入后台时间
        self.enterBackgroundTime = [NSDate date];

        UIApplication *app = [UIApplication sharedApplication];
        self.bgTask = [app beginBackgroundTaskWithName:@"BackgroundTask"
                                     expirationHandler:^{
                                         // Clean up any unfinished task business by marking where you
                                         // stopped or ending the task outright.
                                         [self stopLive];

                                         [app endBackgroundTask:self.bgTask];
                                         self.bgTask = UIBackgroundTaskInvalid;
                                     }];

        dispatch_async(self.backgroundQueue, ^{
            // Do the work associated with the task, preferably in chunks.

            while (self.isBackground) {
                //            NSTimeInterval left = [application backgroundTimeRemaining];

                NSDate *now = [NSDate date];
                NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.enterBackgroundTime];
                NSUInteger bgTime = timeInterval;
                NSTimeInterval enterRoomTimeInterval = 0;
                if (self.enterRoomBackgroundTime) {
                    enterRoomTimeInterval = [now timeIntervalSinceDate:self.enterRoomBackgroundTime];
                }
                NSUInteger enterRoomBgTime = enterRoomTimeInterval;

                NSLog(@"LiveGobalManager::willEnterBackground( bgTime : %lu, enterRoomBgTime : %lu )", (unsigned long)bgTime, (unsigned long)enterRoomBgTime);

                // 后台进入直播间超过60秒
                if (enterRoomBgTime > BACKGROUND_TIMEOUT) {
                    [self stopLive];
                }

                sleep(1);
            }

            [app endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        });
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (_isBackground == YES) {
        _isBackground = NO;

        NSLog(@"LiveGobalManager::willEnterForeground()");
    }
}

- (void)stopLive {
    @synchronized(self) {
        if (self.liveRoom) {
            // 发送IM退出直播间命令
            [[LSImManager manager] leaveRoom:self.liveRoom.roomId];
            self.liveRoom = nil;
        }
        if (self.player) {
            // 停止播放器
            [self.player stop];
            self.player = nil;
        }
        if (self.publisher) {
            // 停止推流器
            [self.publisher stop];
            self.publisher = nil;
        }
    }
}
@end
