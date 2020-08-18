//
//  LSPremiumVideoView.h
//  livestream
//
//  Created by Calvin on 2020/8/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LSPremiumVideoDetailItemObject.h"
#import "LSVideoSlider.h"
@protocol LSPremiumVideoViewDelegate <NSObject>
@optional
//缓冲加载中
- (void)onRecvVideoViewBufferEmpty;
//进行跳转后有数据可以播放
- (void)onRecvVideoViewLikelyToKeepUp;
//播放失败
- (void)onRecvVideoViewPlayFailed;
//播放完成
- (void)onRecvVideoViewPlayDone;
//视频准备播放
- (void)videoIsReadyToPlay;
 
- (void)premiumVideoViewDidFreePlay;

- (void)premiumVideoViewDidBigPlay;

- (void)premiumVideoViewDidPlay;

- (void)premiumVideoViewDidFollowBtn;
@end

@interface LSPremiumVideoView : UIView
@property (weak, nonatomic) id<LSPremiumVideoViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *palyView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *beginLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet LSVideoSlider *videoSiider;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *bigPlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *freePlayBtn;
@property (weak, nonatomic) IBOutlet UIImageView *freeIcon;
@property (weak, nonatomic) IBOutlet UIView *alphaBGView;
@property (weak, nonatomic) IBOutlet UILabel *freeTipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoBottomViewB;
@property (weak, nonatomic) IBOutlet UIView *videoBottomView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIView *silderBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewW;
@property (weak, nonatomic) IBOutlet UIButton *showToolBtn;
- (void)setUI:(LSPremiumVideoDetailItemObject *)item;
- (void)play;
- (void)deleteVideo;
- (void)replay;
@end

