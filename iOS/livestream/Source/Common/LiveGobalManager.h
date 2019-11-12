//
//  LiveGobalManager.h
//  livestream
//
//  Created by Max on 2017/10/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LiveRoom.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"
#import "HangoutDialogViewController.h"
#import "HangOutViewController.h"
#import "LiveViewController.h"
#import "LSVIPLiveViewController.h"
#define BACKGROUND_TIMEOUT 60

@class LiveGobalManager;
@protocol LiveGobalManagerDelegate <NSObject>
@optional

- (void)enterBackgroundTimeOut:(NSDate *)time;

@end

@interface LiveGobalManager : NSObject

/**
 是否正在hangout
 */
@property (assign, nonatomic) BOOL isHangouting;

/**
 当前直播间信息
 */
@property (strong) LiveRoom *liveRoom;

/**
 进入房间时间
 */
@property (strong) NSDate *enterRoomBackgroundTime;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

/**
 能否显示立即邀请

 @param uesrId 主播Id
 @return 能否
 */
- (BOOL)canShowInvite:(NSString *)uesrId;

/**
 设置能否立即显示邀请

 @param canShowInvite 能否立即显示邀请
 */
- (void)setCanShowInvite:(BOOL)canShowInvite;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LiveGobalManagerDelegate>)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LiveGobalManagerDelegate>)delegate;

#pragma mark - 统一导航栏跳转
- (void)presentLiveRoomVCFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC;
- (void)dismissLiveRoomVC;
- (void)pushAndPopVCWithNVCFromVC:(UIViewController *)fromVC toVC:(LSViewController *)toVC;
- (void)pushWithNVCFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC;
- (void)popToRootVC;

#pragma mark - Hangout
- (HangoutDialogViewController *)addDialogVc;
- (void)removeDialogVc;


#pragma mark - 开启/关闭直播间声音
- (void)setupLiveVC:(LiveViewController *)liveVC orHangOutVC:(HangOutViewController *)hangoutVC;
- (void)openOrCloseLiveSound:(BOOL)isClose;


- (void)setupVIPLiveVC:(LSVIPLiveViewController *)liveVC orHangOutVC:(HangOutViewController *)hangoutVC;

@end
