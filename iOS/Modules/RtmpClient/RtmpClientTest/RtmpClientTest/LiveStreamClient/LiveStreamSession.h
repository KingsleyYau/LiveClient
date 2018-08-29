//
//  LiveStreamSession.h
//  livestream
//
//  Created by Max on 2017/8/30.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveStreamSession : NSObject

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)session;

/**
 开启后台播放
 */
- (void)activeSession;

/**
 停止后台播放
 */
- (void)inactiveSession;

/**
 开始播放
 */
- (void)startPlay;

/**
 停止播放
 */
- (void)stopPlay;

/**
 开始采集
 */
- (void)startCapture;

/**
 停止采集
 */
- (void)stopCapture;

/**
 检测摄像头/麦克风是否开启

 @param granted 是否开启
 */
typedef void (^CheckHandler)(BOOL granted);

/**
 检查是否能使用麦克风

 @param handler 回调
 */
- (void)checkAudio:(_Nullable CheckHandler)handler;

/**
 检查是否能使用摄像头

 @param handler <#handler description#>
 */
- (void)checkVideo:(_Nullable CheckHandler)handler;

@end
