//
//  LSPremiumVideoView.m
//  livestream
//
//  Created by Calvin on 2020/8/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoView.h"
#import "LSImageViewLoader.h"
#define STATUS @"status"
#define BufferEmpty @"playbackBufferEmpty"
#define LikelyToKeepUp @"playbackLikelyToKeepUp"

@interface LSPremiumVideoView ()
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerItem * item;
@property (nonatomic,strong) id playTimeObserver; // 观察者
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic,assign) CGFloat maxTime;
@property (nonatomic,copy) NSString * url;
@property (nonatomic, strong) LSPremiumVideoDetailItemObject * datailItem;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) NSInteger time;
@end

@implementation LSPremiumVideoView

- (void)deleteVideo {
    [self removeObserveAndNOtification];
    [self showDefaultUI];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self removeObserveAndNOtification];
        self = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
        
    self.freePlayBtn.layer.cornerRadius = self.freePlayBtn.tx_height/2;
    self.freePlayBtn.layer.masksToBounds = YES;
    
    self.silderBGView.layer.cornerRadius = self.silderBGView.tx_height/2;
    self.silderBGView.layer.masksToBounds = YES;
    
    self.colorView.layer.cornerRadius = self.colorView.tx_height/2;
    self.colorView.layer.masksToBounds = YES;
    
    [self.videoSiider setThumbImage:[UIImage imageNamed:@"LS_PremiumVideo_Slider"] forState:UIControlStateNormal];
    self.videoSiider.continuous = YES;
    // slider开始滑动事件
    [self.videoSiider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.videoSiider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.videoSiider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}

- (void)addTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.time = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(downloadHidenToolView) userInfo:nil repeats:YES];
}

- (void)setUI:(LSPremiumVideoDetailItemObject *)item {
    
    self.datailItem = item;
    
    [[LSImageViewLoader loader]loadImageWithImageView:self.coverImage options:0 imageUrl:item.coverUrlPng placeholderImage:nil finishHandler:nil];
    
    if (item.isInterested) {
        [self.followBtn setImage:[UIImage imageNamed:@"Ls_Video_Followed"] forState:UIControlStateNormal];
    }else {
        [self.followBtn setImage:[UIImage imageNamed:@"Ls_Video_Follow"] forState:UIControlStateNormal];
    }
    
 
    self.endLabel.text = [self convertTime:self.datailItem.duration];
    
    
    if (item.lockStatus == LSLOCKSTATUS_UNLOCK) {
        self.bigPlayBtn.hidden = NO;
         self.maxTime = self.datailItem.duration;        
        [self.colorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.silderBGView);
        }];
    }else {
        self.freePlayBtn.hidden = NO;
        self.freeIcon.hidden = NO;
        self.maxTime = 5;
        if (item.duration == 0) {
         self.colorViewW.constant = 0;
        }else {
         self.colorViewW.constant = (self.silderBGView.tx_width/item.duration)*5;
        }
    }
}

//默认播放界面
- (void)showDefaultUI {
    if (self.datailItem.lockStatus == LSLOCKSTATUS_UNLOCK) {
         self.bigPlayBtn.hidden = NO;
    }else {
         self.freePlayBtn.hidden = NO;
         self.freeIcon.hidden = NO;
    }
    self.alphaBGView.hidden = NO;
    self.coverImage.hidden = NO;
    self.freeTipLabel.hidden = YES;
    self.videoSiider.hidden = YES;
    self.videoSiider.value = 0;
    self.playButton.selected = !self.playButton.selected;
    [self.playButton setImage:[UIImage imageNamed:@"Mail_Video_Progress_Start"] forState:UIControlStateNormal];
    
    self.showToolBtn.hidden = YES;
    if (self.videoBottomView.hidden) {
        [self playViewDid:self.showToolBtn];
    }
    
    [self.timer invalidate];
    self.timer = nil;
    self.time = 0;
}

//播放中界面
- (void)showPlayingUI {
    // 已解锁
    if (self.datailItem.lockStatus == LSLOCKSTATUS_UNLOCK) {
        self.url = self.datailItem.videoUrlFull;
        self.freeTipLabel.hidden = YES;
    }else {
        self.url = self.datailItem.videoUrlShort;
        self.freeTipLabel.hidden = NO;
    }
    self.bigPlayBtn.hidden = YES;
    self.freePlayBtn.hidden = YES;
    self.freeIcon.hidden = YES;
    self.alphaBGView.hidden = YES;
    self.coverImage.hidden = YES;
    self.videoSiider.hidden = NO;
    self.showToolBtn.hidden = NO;
    [self addTimer];
}

- (void)play {
    [self showPlayingUI];
    NSURL *url = [NSURL URLWithString:self.url];
    self.item = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity =AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.frame =self.frame;
    [self.palyView.layer addSublayer:self.playerLayer];
    [self addObserveAndNOtification];
}
#pragma mark 添加播放监听
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
    }];
}

// 更新滑动条
- (void)updateVideoSlider:(CGFloat)currentTime {
    [self.videoSiider setValue:currentTime/self.maxTime];
    self.beginLabel.text = [self convertTime:currentTime];
}

 
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    //AVPlayerItem *items = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:STATUS]) {
        AVPlayerItemStatus status = _item.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [_player play];
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
                [self showDefaultUI];
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

// 播放完成
- (void)playbackFinished:(NSNotification *)notification {
        [self removeObserveAndNOtification];
       
        if ([self.delegate respondsToSelector:@selector(onRecvVideoViewPlayDone)]) {
           [self.delegate onRecvVideoViewPlayDone];
        }

    [self showDefaultUI];
}

- (NSString *)convertTime:(CGFloat)second {
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}

#pragma mark - 点击播放界面
- (IBAction)playViewDid:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.videoBottomViewB.constant = -30;
        self.followBtn.hidden = YES;
        self.videoBottomView.hidden = YES;
        [self addTimer];
    }else {
        self.videoBottomViewB.constant = 0;
        self.followBtn.hidden = NO;
        self.videoBottomView.hidden = NO;
    }
}

- (void)downloadHidenToolView {
    self.time++;
    if (self.time == 3) {
        [self.timer invalidate];
        self.timer = nil;
        if (!self.videoBottomView.hidden) {
           [self playViewDid:self.showToolBtn];
        }
    }
}

- (void)replay {
    self.playButton.selected = YES;
    [self.playButton setImage:[UIImage imageNamed:@"Mail_Video_Progress_Suspend"] forState:UIControlStateNormal];
    if (self.alphaBGView.hidden) {
      [self.player play];
    }else {
        [self play];
    }
}

#pragma mark - 点击播放按钮
- (IBAction)didPlayButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"Mail_Video_Progress_Suspend"] forState:UIControlStateNormal];
        if (self.alphaBGView.hidden) {
          [self.player play];
        }else {
            [self play];
        }
    } else {
        [sender setImage:[UIImage imageNamed:@"Mail_Video_Progress_Start"] forState:UIControlStateNormal];
         [self.player pause];
    }
}

- (IBAction)freePlayBtnDid:(id)sender {
    [self didPlayButton:self.playButton];
}

- (IBAction)bigPlayBtnDid:(id)sender {
    [self didPlayButton:self.playButton];
}

#pragma mark - 滑动动作
- (void)progressSliderTouchBegan:(UISlider *)sender {
    [self.timer invalidate];
    self.timer = nil;
    [self.player pause];
}

- (void)progressSliderValueChanged:(UISlider *)sender {
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

- (void)progressSliderTouchEnded:(UISlider *)sender {
     [self.player play];
     [self addTimer];
}

#pragma mark - 收藏按钮点击事件
- (IBAction)followBtnDid:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"Ls_Video_Followed"] forState:UIControlStateNormal];
    }else {
        [sender setImage:[UIImage imageNamed:@"Ls_Video_Follow"] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(premiumVideoViewDidFollowBtn)]) {
        [self.delegate premiumVideoViewDidFollowBtn];
    }
}

@end
