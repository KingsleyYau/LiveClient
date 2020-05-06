//
//  LSAnchorPrivItemObject
//  dating
//
//  Created by Alex on 20/04/10.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSAnchorPrivItemObject : NSObject
/**
 * 主播权限结构体
 * scheduleOneOnOneRecvPriv              是否有接收邀请权限
 * scheduleOneOnOneRecvSend           是否有发送邀请权限
 */

@property (nonatomic, assign) BOOL scheduleOneOnOneRecvPriv;
@property (nonatomic, assign) BOOL scheduleOneOnOneSendPriv;

@end
