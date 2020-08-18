//
//  LSVideoPlayManager.h
//  dating
//
//  Created by Calvin on 17/6/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSVideoView.h"

@protocol LSVideoPlayManagerDelegate <NSObject>
//下载成功
- (void)onRecvVideoDownloadSucceed:(NSString * _Nonnull)path;
//下载失败
- (void)onRecvVideoDownloadFail;
//播放失败
- (void)onRecvVideoPlayFailed;
//播放完成
- (void)onRecvVideoPlayDone;
// 缓冲加载中
- (void)onRecvVideoPlayBufferEmpty;
// 进行跳转后有数据可以播放
- (void)onRecvVideoPlayLikelyToKeepUp;
// 缓冲可以播放
- (void)onRecvVideoIsReadyToPlay;
// 是否显示进度条
- (void)onRecvShowLadyProgressView:(BOOL)isShow;
// 视频是否播放中
- (void)onRecvVideoPlayOrSuspend:(BOOL)isSuspend;
@end

@interface LSVideoPlayManager : NSObject

@property (nonatomic,copy) NSString * _Nullable url;//下载url，下载视频必须传
@property (nonatomic,weak) id<LSVideoPlayManagerDelegate>_Nullable delegate;
//播放视频
- (void)playVideo:(NSString*_Nonnull)path forView:(UIView *_Nonnull)view playTime:(CGFloat)playTime isShowProgress:(BOOL)isShow;
//开始下载视频
- (void)loadVideo:(NSString *_Nonnull)vId;
//停止下载
- (void)stop;
//移除视频通知
-(void)removeNotification;
//移除视频界面
- (void)removeVideoView;
/** 是否继续播放 */
@property (nonatomic, assign) BOOL isPlayConstant;
//暂停/播放视频
- (void)setVideoPlayAndSuspend:(BOOL)isSuspend;

/*
 *  女士详情使用的到函数
 *
 */
// 设置播放视频屏幕
- (void)setVideoAspectFill:(BOOL)isAspectFill;
// 女士详情播放视频模式
- (void)playLdayVideo:(NSString*_Nonnull)path forView:(UIView *_Nonnull)view playTime:(CGFloat)playTime isShowSlider:(BOOL)isShow isShowPlayTime:(BOOL)isShowPlayTime;

// 播放LiveChat视频
- (void)playChatVideo:(NSString*_Nonnull)path forView:(UIView *_Nonnull)view playTime:(CGFloat)playTime isShowSlider:(BOOL)isShow isShowPlayTime:(BOOL)isShowPlayTime isUrlPlay:(BOOL)isUrlPlay;

////生成图片路径
//+ (NSString *_Nonnull)getGiftPhotoURLPath:(NSString *_Nonnull)path vgId:(NSString *_Nonnull)vgId;
////生成视频路径
//+ (NSString *_Nonnull)getGiftVideoURLPath:(NSString *_Nonnull)path vgId:(NSString *_Nonnull)vgId;
@end
