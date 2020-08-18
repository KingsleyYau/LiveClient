//
//  LSStreamSpeedManager.h
//  livestream
//
//  Created by randy on 2017/11/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSStreamSpeedManager : NSObject
+ (instancetype)manager;
/**
 进入直播间成功上传测速度结果
 @param roomId 直播间Id
 */
- (void)requestSpeedResult:(NSString *)roomId;

/**
 连接流媒体服务器成功通知服务器
 */
- (void)requestPushPullLogs:(NSString *)roomId;

@end
