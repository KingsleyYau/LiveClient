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

#define BACKGROUND_TIMEOUT 60

@class LiveGobalManager;
@protocol LiveGobalManagerDelegate <NSObject>
@optional

- (void)enterBackgroundTimeOut:(NSDate * _Nullable)time;

@end


@interface LiveGobalManager : NSObject

/**
 当前直播间信息
 */
@property (strong) LiveRoom * _Nullable liveRoom;

/**
 当前拉流器
 */
@property (strong) LiveStreamPlayer * _Nullable player;

/**
 当前推流器
 */
@property (strong) LiveStreamPublisher * _Nullable publisher;

/**
 进入房间时间
 */
@property (strong) NSDate * _Nullable enterRoomBackgroundTime;

/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;

/**
 能否显示立即邀请

 @param uesrId 主播Id
 @return 能否
 */
- (BOOL)canShowInvite:(NSString * _Nonnull)uesrId;

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
- (void)addDelegate:(id<LiveGobalManagerDelegate> _Nonnull)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LiveGobalManagerDelegate> _Nonnull)delegate;

@end
