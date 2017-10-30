//
//  GiftComboView.m
//  LiveSendGift
//
//  Created by Calvin on 17/5/23.
//  Copyright © 2017年 com.wujh. All rights reserved.
//

#import "GiftComboView.h"
#import "LiveBundle.h"

static NSInteger const kTimeOut = 3;             /**< 超时移除时长 */
static CGFloat const kRemoveAnimationTime = 0.5; /**< 移除动画时长 */
static CGFloat const kNumberAnimationTime = 0.1; /**< 数字改变动画时长 */
static CGFloat const kNumberChangeTime = 1.0;    /**< 计时器时长 */

//static CGFloat const kNumberAnimationScaleStart = 2.0;
//static CGFloat const kNumberAnimationScale = 0.5;

@interface GiftComboView ()

@property (nonatomic, strong) NSTimer *liveTimer; /**< 定时器控制自身移除 */
@property (nonatomic, assign) NSInteger liveTimerForSecond;
@property (nonatomic, assign) BOOL isSetNumber;
@property (nonatomic, strong) NSTimer *playTimer;
@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSRunLoop *playLoop;

@property (nonatomic, assign) BOOL isPlayTimerStop;

@property (atomic, assign) BOOL isPlayGiftCombo;

@end

@implementation GiftComboView

#pragma mark - 初始化
+ (instancetype)giftComboView:(id)owner {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"GiftComboView" owner:owner options:nil];
    GiftComboView *view = [nibs objectAtIndex:0];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)dealloc {
    NSLog(@"GiftComboView::dealloc()");
    
    self.isPlayTimerStop = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSLog(@"GiftComboView::awakeFromNib()");
    
    self.liveTimerForSecond = 0;
    self.playTime = kNumberChangeTime;

    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2;
    self.iconImageView.layer.masksToBounds = YES;

    self.backView.layer.cornerRadius = self.backView.frame.size.height / 2;
    self.backView.layer.masksToBounds = YES;
    self.isPlayTimerStop = YES;
    self.isPlayGiftCombo = NO;

    self.serialQueue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
    
//    WeakObject(self, weakSelf);
    
    dispatch_async(self.serialQueue, ^{
        self.playLoop = [NSRunLoop currentRunLoop];
        @synchronized(self) {
            if (!self.playTimer) {
                self.playTimer = [NSTimer scheduledTimerWithTimeInterval:self.playTime
                                                                      target:self
                                                                    selector:@selector(play)
                                                                    userInfo:nil
                                                                     repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.playTimer forMode:NSDefaultRunLoopMode];
            }
        }
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    NSLog(@"GiftComboView::removeFromSuperview()");
}

- (void)setEndNum:(NSInteger)endNum {
    _endNum = endNum;

    if (endNum > 1 && self.isPlayTimerStop && _playing) {
        self.isPlayTimerStop = NO;
        [self playGiftCombo];
    }
}

/**
 礼物数量自增1使用该方法
 
 num  从多少开始计数
 */
- (void)addGiftNumberFrom {
    //    if (!self.isSetNumber) {
    //        self.numberView.number = number;
    //        self.isSetNumber = YES;
    //    }
    //每调用一次self.numberView.number get方法 自增1

    NSInteger num = self.numberView.number + 1;
    [self.numberView changeNumber:num];
    [self handleNumber:num];
}

- (void)play {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isPlayGiftCombo) {
            [self addGiftNumberFrom];
        }
    });
}

- (void)reset {
    self.alpha = 1.0;
    self.transform = CGAffineTransformIdentity;
    [self.numberView changeNumber:self.beginNum];
}

- (void)start {
    _playing = YES;
}

- (void)playGiftCombo {
    self.isPlayGiftCombo = YES;
}

- (void)stopGiftCombo {
    self.serialQueue = nil;

    @synchronized(self) {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }

    if ([self.playLoop getCFRunLoop]) {
        CFRunLoopStop([self.playLoop getCFRunLoop]);
    }
}

#pragma mark - Private
/**
 处理显示数字 开启定时器
 
 @param number 显示数字的值
 */
- (void)handleNumber:(NSInteger)number {

    self.liveTimerForSecond = 0;

    [self.numberView.layer removeAllAnimations];
    self.numberView.transform = CGAffineTransformIdentity;
    self.numberView.alpha = 0.0;
    [self.numberView layoutIfNeeded];

    [UIView animateWithDuration:0.01
        animations:^{
            self.numberView.transform = CGAffineTransformMakeScale(2.2, 2.2);
            self.numberView.alpha = 0.1;

        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.03
                animations:^{
                    self.numberView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                    self.numberView.alpha = 0.3;

                }
                completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.05
                        animations:^{
                            self.numberView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                            self.numberView.alpha = 0.5;

                        }
                        completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.1
                                animations:^{
                                    self.numberView.transform = CGAffineTransformMakeScale(0.6, 0.6);
                                    self.numberView.alpha = 0.7;

                                }
                                completion:^(BOOL finished) {
                                    [UIView animateWithDuration:0.2
                                        animations:^{
                                            self.numberView.transform = CGAffineTransformIdentity;
                                            self.numberView.alpha = 1.0;
                                        }
                                        completion:^(BOOL finished) {
                                            if (number >= self.endNum) {
                                                self.isPlayGiftCombo = NO;
                                                self.isPlayTimerStop = YES;
                                            }
                                        }];
                                }];
                        }];
                }];
        }];

    [self.liveTimer setFireDate:[NSDate date]];

    /*
    self.liveTimerForSecond = 0;
    [self.numberView.layer removeAllAnimations];
    
    self.numberView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    self.numberView.alpha = 0.0;
    
    __block CGFloat time = 0;
    [UIView animateKeyframesWithDuration:kNumberAnimationTime * 2 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        [UIView addKeyframeWithRelativeStartTime:time relativeDuration:kNumberAnimationTime * 2 animations:^{
            self.numberView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.numberView.alpha = 1.0;
        }];
        
        time += kNumberAnimationTime * 2;
        
        [UIView addKeyframeWithRelativeStartTime:time relativeDuration:kNumberAnimationTime animations:^{
            self.numberView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            self.numberView.alpha = 1.0;
        }];
        
        time += kNumberAnimationTime * 1;
        
        [UIView addKeyframeWithRelativeStartTime:time relativeDuration:kNumberAnimationTime animations:^{
            self.numberView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.numberView.alpha = 1.0;
        }];
        
    } completion:^(BOOL finished) {

    }];
    
//    [UIView animateWithDuration:kNumberAnimationTime animations:^{
//        self.numberView.transform = CGAffineTransformMakeScale(kNumberAnimationScale, kNumberAnimationScale);
//        self.numberView.alpha = 1.0;
//    } completion:^(BOOL finished) {
//        if (finished) {
////            self.numberView.transform = CGAffineTransformIdentity;
////            self.numberView.transform = CGAffineTransformMakeScale(kNumberAnimationScaleStart, kNumberAnimationScaleStart);
//        }
//    }];
    
    [self.liveTimer setFireDate:[NSDate date]];
     */
}

- (void)liveTimerRunning {

    self.liveTimerForSecond += 1;

    if (self.liveTimerForSecond > kTimeOut) {
        if (self.isAnimation == YES) {
            self.isAnimation = NO;
            return;
        }
        self.isAnimation = YES;
        self.isLeavingAnimation = YES;
        [UIView animateWithDuration:kRemoveAnimationTime
            delay:kNumberAnimationTime
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                self.transform = CGAffineTransformTranslate(self.transform, 0, -self.frame.size.height * 1.5);
                self.alpha = 0;

            }
            completion:^(BOOL finished) {
                self.endNum = 0;
                self.beginNum = 0;
                self.isLeavingAnimation = NO;
                self.numberView.number = 0;

                _playing = NO;

                // 回调
                if ([self.delegate respondsToSelector:@selector(playComboFinish:)]) {
                    [self.delegate playComboFinish:self];
                }
            }];

        [self stopTimer];
    }
}

- (NSTimer *)liveTimer {
    if (!_liveTimer) {
        _liveTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(liveTimerRunning)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_liveTimer forMode:NSRunLoopCommonModes];
    }
    return _liveTimer;
}

- (void)stopTimer {
    if (_liveTimer) {
        [_liveTimer invalidate];
        _liveTimer = nil;
    }
}

@end

