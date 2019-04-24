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
//进行跳转后有数据可以播放
- (void)onRecvVideoViewLikelyToKeepUp;
//播放失败
- (void)onRecvVideoViewPlayFailed;
//播放完成
- (void)onRecvVideoViewPlayDone;
//是否显示进度条
- (void)isShowLadyProgressView:(BOOL)isShow;
//是否正在播放
- (void)videoIsPlayOrSuspeng:(BOOL)isSuspend;
//视频准备播放
- (void)videoIsReadyToPlay;
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
- (instancetype)initWithFrame:(CGRect)frame isSlider:(BOOL)isShow isShowPlayTime:(BOOL)isShowPlayTime;
// 聊天视频播放视频模式
- (instancetype)initWithFrame:(CGRect)frame isSlider:(BOOL)isShow isShowPlayTime:(BOOL)isShowPlayTime isPerformShow:(BOOL)isPerformShow;
// 播放女士视频
- (void)playLadyVideo;
// 播放LiveChat视频
- (void)playChatVideo;
// 设置进度条暂停/播放
- (void)setProgressPlaySuspendOrStart:(BOOL)isSuspend;
@end
