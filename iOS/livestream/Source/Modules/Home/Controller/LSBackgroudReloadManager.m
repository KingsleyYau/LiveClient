//
//  LSBackgroudReloadManager.m
//  livestream
//
//  Created by Calvin on 2018/8/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSBackgroudReloadManager.h"
#import "LSLoginManager.h"
static LSBackgroudReloadManager* backgroudReloadManager = nil;

@interface LSBackgroudReloadManager ()

@property (nonatomic, assign) int time;
@property (nonatomic, strong) NSTimer * timer;
@end

@implementation LSBackgroudReloadManager

+ (instancetype)manager {
    if( backgroudReloadManager == nil ) {
        backgroudReloadManager = [[[self class] alloc] init];
    }
    return backgroudReloadManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

//进入前台
- (void)willEnterForeground {
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.time >= 60 && [LSLoginManager manager].status == LOGINED) {
        if ([self.delegate respondsToSelector:@selector(WillEnterForegroundReloadData)]) {
            [self.delegate WillEnterForegroundReloadData];
        }
    }
}

//进入后台
- (void)didEnterBackground {
    self.time = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
}

- (void)countdown {
    self.time++;
}

@end
