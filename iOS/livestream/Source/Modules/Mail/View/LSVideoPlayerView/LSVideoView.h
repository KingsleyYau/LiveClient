//
//  LSVideoView.h
//  dating
//
//  Created by Calvin on 17/6/29.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol LSVideoViewDelegate <NSObject>
@optional
//缓冲加载中
- (void)onRecvVideoViewBufferEmpty;
//缓冲可以播放
- (void)onRecvVideoViewLikelyToKeepUp;
//播放失败
- (void)onRecvVideoViewPlayFailed;
//播放完成
- (void)onRecvVideoViewPlayDone;
@end

@interface LSVideoView : UIView
@property (nonatomic,copy) NSString * url;
@property (nonatomic,weak) id<LSVideoViewDelegate> delegate;
@property (nonatomic, assign) BOOL isFill;
@property (nonatomic, assign) BOOL isPlayContant;
@property (nonatomic, assign) CGFloat playTime;

- (instancetype)initWithFrame:(CGRect)frame isShowProgress:(BOOL)isShow;
- (void)play;
- (void)pause;
- (void)removeObserveAndNOtification;
// 女士详情播放视频模式
- (instancetype)initWithFrame:(CGRect)frame isSlider:(BOOL)isShow;
// 播放女士视频
- (void)playLadyVideo;
@end
