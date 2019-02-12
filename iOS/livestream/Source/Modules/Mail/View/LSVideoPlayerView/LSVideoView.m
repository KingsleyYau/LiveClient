//
//  LSVideoView.m
//  dating
//
//  Created by Calvin on 17/6/29.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSVideoView.h"
#import "LSVideoProgressView.h"
#import "LSLadyVideoProgressView.h"

#define STATUS @"status"
#define BufferEmpty @"playbackBufferEmpty"
#define LikelyToKeepUp @"playbackLikelyToKeepUp"

@interface LSVideoView ()<LSVideoProgressViewDelegate, LSLadyVideoProgressViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerItem * item;
@property (nonatomic,strong) MPMoviePlayerController *movewController;
@property (nonatomic,strong) id playTimeObserver; // 观察者
@property (nonatomic,strong) LSVideoProgressView * progressView;
@property (nonatomic,strong) UIView * playView;
@property (nonatomic,assign) CGFloat maxTime;
@property (nonatomic,strong) LSLadyVideoProgressView * ladyProgressView;
/** 单击 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UILabel *shortLabel;
@end

@implementation LSVideoView

- (instancetype)initWithFrame:(CGRect)frame isShowProgress:(BOOL)isShow {
    self = [super initWithFrame:frame];
    if (self) {
        [self removeObserveAndNOtification];
        [self.playView removeFromSuperview];
        self.playView = nil;
        self.playView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, isShow?frame.size.height - 40:frame.size.height)];
        [self addSubview:self.playView];
        
        if (isShow) {
            self.progressView = [[LSVideoProgressView alloc]init];
            self.progressView.delegate = self;
            [self addSubview:self.progressView];
        }
        
        self.isFill = NO;
    }
    return self;
}

- (void)play {
    if (self.url.length > 0) {
        NSURL * url = [NSURL URLWithString:self.url];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            
            self.progressView.frame = CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40);
            self.item = [[AVPlayerItem alloc] initWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:self.item];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            if (self.isFill) {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            } else {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }
            self.playerLayer.frame =self.playView.frame;
            [self.playView.layer addSublayer:self.playerLayer];
            [self addObserveAndNOtification];
            
        } else {
            self.movewController = [[MPMoviePlayerController alloc] initWithContentURL:url];
            [self.movewController setControlStyle:MPMovieControlStyleNone];
            self.movewController.repeatMode = MPMovieRepeatModeOne;
            [self.movewController.view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self addSubview:self.movewController.view];
            [self.movewController play];
        }
    }
}

- (void)pause {
    [self.player pause];
}

- (void)addObserveAndNOtification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
    //KVO
    [self.item addObserver:self forKeyPath:STATUS options:NSKeyValueObservingOptionNew context:nil];
    [self.item addObserver:self forKeyPath:BufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    [self.item addObserver:self forKeyPath:LikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    [self monitoringPlayback:self.item]; // 监听播放
}

- (void)removeObserveAndNOtification {
    [self.item removeObserver:self forKeyPath:STATUS];
    [self.item removeObserver:self forKeyPath:BufferEmpty];
    [self.item removeObserver:self forKeyPath:LikelyToKeepUp];
    [self.player removeTimeObserver:self.playTimeObserver]; // 移除playTimeObserver
    self.playTimeObserver = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.player pause];
    self.item = nil;
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;
    self.playerLayer = nil;
    if (self.movewController) {
        [self.movewController stop];
    }
}

// 观察播放进度
- (void)monitoringPlayback:(AVPlayerItem *)item {
    __weak typeof(self)WeakSelf = self;
    // 播放进度, 每秒执行30次， CMTime 为30分之一秒
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前播放秒
        float currentPlayTime = (double)item.currentTime.value/ item.currentTime.timescale;
        // 更新slider
        [WeakSelf updateVideoSlider:currentPlayTime];
        [WeakSelf updateLadyVideoSlider:currentPlayTime];
        
    }];
}

// 更新滑动条
- (void)updateVideoSlider:(CGFloat)currentTime {
    self.progressView.progressView.progress = currentTime/self.maxTime;
    self.progressView.beginLabel.text = [self convertTime:currentTime];
}

// 设置最大时间
- (void)setMaxDuration:(CGFloat)duration {
    self.maxTime = duration;
    self.progressView.endLabel.text = [self convertTime:duration];
    
    if (self.ladyProgressView) {
        self.ladyProgressView.ladyEndLabel.text = [self convertTime:duration];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    AVPlayerItem *items = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:STATUS]) {
        AVPlayerItemStatus status = _item.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [_player play];
                CMTime duration = items.duration; // 获取视频长度
                NSLog(@"%.2f", CMTimeGetSeconds(duration));
                // 设置视频时间
                if (!(self.playTime > 0)) {
                    [self setMaxDuration:CMTimeGetSeconds(duration)];
                }
            }
                break;
            case AVPlayerItemStatusUnknown: {
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusFailed: {
                NSLog(@"AVPlayerItemStatusFailed");
                NSLog(@"%@",_item.error);
                [self removeObserveAndNOtification];
                if ([self.delegate respondsToSelector:@selector(onRecvVideoViewPlayFailed)]) {
                    [self.delegate onRecvVideoViewPlayFailed];
                }
            }
                break;
                
            default:
                break;
        }
    } else if ([keyPath isEqualToString:BufferEmpty]) {
        if ([self.delegate respondsToSelector:@selector(onRecvVideoViewBufferEmpty)]) {
            [self.delegate onRecvVideoViewBufferEmpty];
        }
    } else if ([keyPath isEqualToString:LikelyToKeepUp]) {
        if ([self.delegate respondsToSelector:@selector(onRecvVideoViewLikelyToKeepUp)]) {
            [self.delegate onRecvVideoViewLikelyToKeepUp];
        }
    }
}


- (void)playbackFinished:(NSNotification *)notification {
    if (self.isPlayContant) {
        [self.player seekToTime:CMTimeMake(0, 1)];
        [self.player play];
    } else {
        [self removeObserveAndNOtification];
        // 播放完成
        if ([self.delegate respondsToSelector:@selector(onRecvVideoViewPlayDone)]) {
            [self.delegate onRecvVideoViewPlayDone];
        }
    }
}

- (void)videoProgressViewIsPlaying:(BOOL)isPause {
    if (isPause) {
        [self pause];
    } else {
        [self.player play];
    }
}

- (NSString *)convertTime:(CGFloat)second {
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark - LadyVideoShow
// 女士详情播放视频模式
- (instancetype)initWithFrame:(CGRect)frame isSlider:(BOOL)isShow {
    self = [super initWithFrame:frame];
    if (self) {
        [self removeObserveAndNOtification];
        self.playView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.playView];
        if (isShow) {
            self.ladyProgressView = [[LSLadyVideoProgressView alloc] init];
            self.ladyProgressView.delegate = self;
            [self addSubview:self.ladyProgressView];
            [self showLadyVideoProgress:NO];
            [self createGesture];
        } else {
            self.shortLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 46, frame.size.width - 10, 46)];
            self.shortLabel.textAlignment = NSTextAlignmentRight;
            self.shortLabel.font = [UIFont systemFontOfSize:16];
            self.shortLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.shortLabel];
        }
    }
    return self;
}

// 播放女士视频
- (void)playLadyVideo {
    if (self.url.length > 0) {
        NSURL * url = [NSURL URLWithString:self.url];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            self.ladyProgressView.frame = CGRectMake(0, self.frame.size.height - 46, self.frame.size.width, 46);
            self.item = [[AVPlayerItem alloc] initWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:self.item];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            if (self.isFill) {
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            } else {
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }
            
            if (self.playTime > 0) {
                int time = floor(self.playTime);
                self.maxTime = self.playTime;
                if (self.ladyProgressView) {
                    self.ladyProgressView.ladyEndLabel.text = [self timeFormatted:time];
                }
            }
            
            playerLayer.frame =self.playView.frame;
            [self.playView.layer addSublayer:playerLayer];
            [self addObserveAndNOtification];
        } else {
            self.movewController =[[MPMoviePlayerController alloc] initWithContentURL:url];
            [self.movewController setControlStyle:MPMovieControlStyleNone];
            self.movewController.repeatMode = MPMovieRepeatModeOne;
            [self.movewController.view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self addSubview:self.movewController.view];
            [self.movewController play];
        }
    }
}

// 更新滑动条
- (void)updateLadyVideoSlider:(CGFloat)currentTime {
    if (self.shortLabel && self.playTime > 0) {
        self.shortLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:currentTime] ,[self timeFormatted:floor(self.playTime)]];
    }
    [self.ladyProgressView.videoSiider setValue:currentTime/self.maxTime];
    if (self.ladyProgressView) {
        self.ladyProgressView.ladyBeginLabel.text = [self convertTime:currentTime];
    }
}

#pragma mark - LadyVideoProgress
/**
 *  创建手势
 */
- (void)createGesture {
    // 单击
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:self.singleTap];
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
}

/**
 *   轻拍方法
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)singleTapAction:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        BOOL isShow = self.ladyProgressView.hidden;
        [self showLadyVideoProgress:isShow];
    }
}

- (void)showLadyVideoProgress:(BOOL)isShow {
    self.ladyProgressView.hidden = !isShow;
    if (isShow) {
        [self playerCancelAutoHideLadyControlView];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideLadyControlView) object:nil];
        [self performSelector:@selector(hideLadyControlView) withObject:nil afterDelay:3.0];
    }
}

- (void)hideLadyControlView {
    [self playerCancelAutoHideLadyControlView];
    self.ladyProgressView.hidden = YES;
}

/**
 *  取消延时隐藏controlView的方法
 */
- (void)playerCancelAutoHideLadyControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - LadyVideoProgressViewDelegate
- (void)ladyVideoProgressViewIsPlaying:(BOOL)isPause {
    if (isPause) {
        [self pause];
    } else {
        [self.player play];
    }
}

// 开始滑动
- (void)ladyVideoProgressViewTouchBegan:(UISlider *)sender {
    if (!self.ladyProgressView.hidden) {
        [self playerCancelAutoHideLadyControlView];
    }
    [self.player pause];
}

// 滑动中
- (void)ladyVideoProgressViewTouchChanged:(UISlider *)sender {
    
    if (self.item.status == AVPlayerItemStatusReadyToPlay) {
        CGFloat totalTime = (CGFloat)self.item.duration.value / self.item.duration.timescale;
        //计算出拖动的当前秒数
        CGFloat dragedSeconds = floorf(totalTime * sender.value);
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime   = CMTimeMake(dragedSeconds, 1);
        [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
            
        }];
    }
}

// 结束滑动
- (void)ladyVideoProgressViewTouchEnded:(UISlider *)sender {
    if (!self.ladyProgressView.hidden) {
        [self showLadyVideoProgress:YES];
    }
//    [self.ladyProgressView setPlayButtonSelected];
    [self.player play];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

@end
