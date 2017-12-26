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
 是否有采集权限

 @return YES:允许/NO:拒绝
 */
- (BOOL)canCapture;
@end
