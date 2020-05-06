//
//  LSMinLiveManager.m
//  livestream
//
//  Created by Calvin on 2019/11/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMinLiveManager.h"
#import "LiveGobalManager.h"
#import "LSImManager.h"
@interface LSMinLiveManager () <LSMinLiveViewDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate>
@property (nonatomic, weak) UIViewController *mainVC;
@property (nonatomic, assign) CGRect minViewRect;
@end

@implementation LSMinLiveManager

+ (instancetype)manager {
    static LSMinLiveManager *minLiveManager = nil;
    if (minLiveManager == nil) {
        minLiveManager = [[LSMinLiveManager alloc] init];
    }
    return minLiveManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minViewRect = CGRectMake(SCREEN_WIDTH - 132, SCREEN_HEIGHT - 173, 122, 163);
        [[LSImManager manager] addDelegate:self];
        [[LSImManager manager].client addDelegate:self];
        self.userId = @"";
    }
    return self;
}

- (void)setMinViewAddVC:(UIViewController *)vc {
    NSLog(@"LSMinLiveManager::setMinViewAddVC( [初始化最小化直播间View] )");

    self.mainVC = vc;
    self.minView = [[LSMinLiveView alloc] initWithFrame:self.minViewRect];
    self.minView.backgroundColor = [UIColor blackColor];
    self.minView.delegate = self;
    self.minView.hidden = YES;
    //  一开始添加到window上,进入直播间,播放流绘制图会导致内存暴增,添加到首页view防止minview释放
    //    [[UIApplication sharedApplication].keyWindow addSubview:self.minView];
    [self.mainVC.view addSubview:self.minView];
    self.minView.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}

- (void)showMinLive {
    // 移除首页最小化的view添加到window上
    NSLog(@"LSMinLiveManager::showMinLive( [显示最小化直播间View] )");
    [self.minView removeFromSuperview];
    self.minView.hidden = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:self.minView];
}

- (void)hidenMinLive {
    NSLog(@"LSMinLiveManager::hidenMinLive( [隐藏最小化直播间View] )");
    self.minView.hidden = YES;
    self.liveVC = nil;
    self.userId = @"";
}

- (void)removeVC {
    NSLog(@"LSMinLiveManager::removeVC( [移除最小化直播间VC] )");
    self.mainVC = nil;
    self.liveVC = nil;
    [self.minView removeFromSuperview];
    self.minView = nil;
    self.userId = @"";
}

- (void)minLiveViewDidCloseBtn {

    [self.minView removeFromSuperview];
    self.minView = nil;
    self.minView = [[LSMinLiveView alloc] initWithFrame:self.minViewRect];
    self.minView.backgroundColor = [UIColor blackColor];
    self.minView.delegate = self;
    [self.mainVC.view addSubview:self.minView];
    //  关闭最小化还原初始状态添加到首页view防止minview释放,进入直播间,播放流绘制图会导致内存暴增,
    //    [[UIApplication sharedApplication].keyWindow addSubview:self.minView];
    self.minView.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self hidenMinLive];
}

- (void)minLiveViewDidVideo {
    NSLog(@"LSMinLiveManager::minLiveViewDidVideo( [点击最小化直播间View] )");
    if ([self.delegate respondsToSelector:@selector(pushMaxLive)]) {
        [self.delegate pushMaxLive];
    }
}

#pragma mark - 直播间回调

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"LSMinLiveManager::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveVC && errType != LCC_ERR_SUCCESS) {
            [self hidenMinLive];
        }
    });
}
- (void)onRecvRoomCloseNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSMinLiveManager::onRecvRoomCloseNotice( [接收关闭直播间回调], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasOneOnOneAuth: %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveVC) {
            [self hidenMinLive];
        }
    });
}

- (void)onRecvRoomKickoffNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg credit:(double)credit priv:(ImAuthorityItemObject *)priv {
    NSLog(@"LSMinLiveManager::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ credit:%f, isHasOneOnOneAuth :%d, isHasBookingAuth : %d", roomId, credit, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveVC) {
            [self hidenMinLive];
        }
    });
}

#pragma mark - 吸附动画
- (void)minLiveViewPan:(UIPanGestureRecognizer *)recognizer {
    CGFloat videoViewW = recognizer.view.tx_width + 15;
    CGFloat videoViewH = recognizer.view.tx_height + 15;

    //移动状态
    UIGestureRecognizerState recState = recognizer.state;

    switch (recState) {
        case UIGestureRecognizerStateBegan: {

        } break;

        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self.mainVC.view];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        } break;

        case UIGestureRecognizerStateEnded: {
            CGFloat viewH = SCREEN_HEIGHT;
            CGPoint stopPoint = CGPointMake(0, viewH - ((IS_IPHONE_X) == YES ? 88 : 64) / 2.0);

            if (recognizer.view.center.x < SCREEN_WIDTH / 2.0) {
                if (recognizer.view.center.y <= viewH / 2.0) {
                    stopPoint = CGPointMake(videoViewW / 2.0, recognizer.view.center.y);
                } else {
                    stopPoint = CGPointMake(videoViewW / 2.0, recognizer.view.center.y);
                }
            } else {
                if (recognizer.view.center.y <= viewH / 2.0) {
                    //右上
                    stopPoint = CGPointMake(SCREEN_WIDTH - videoViewW / 2.0, recognizer.view.center.y);
                } else {
                    //右下
                    stopPoint = CGPointMake(SCREEN_WIDTH - videoViewW / 2.0, recognizer.view.center.y);
                }
            }

            if (stopPoint.x - videoViewW / 2.0 <= 0) {
                stopPoint = CGPointMake(videoViewW / 2.0, stopPoint.y);
            }

            if (stopPoint.x + videoViewW / 2.0 >= SCREEN_WIDTH) {
                stopPoint = CGPointMake(SCREEN_WIDTH - videoViewW / 2.0, stopPoint.y);
            }

            if (stopPoint.y - videoViewW / 2.0 <= 0) {
                stopPoint = CGPointMake(stopPoint.x, videoViewH / 2.0);
            }

            if (stopPoint.y + videoViewH / 2.0 >= viewH) {
                stopPoint = CGPointMake(stopPoint.x, viewH - videoViewH / 2.0);
            }

            [UIView animateWithDuration:0.5
                             animations:^{
                                 recognizer.view.center = stopPoint;
                             }];
        }break;
            
        default:{
        }break;
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.mainVC.view];
    
    self.minViewRect = recognizer.view.frame;
}

@end
