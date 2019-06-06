//
//  LSAppPushConfigItemObject.h
//  dating
//
//  Created by Alex on 19/4/22.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * App推送设置
 * isPriMsgAppPush             是否接收私信推送通知（1：YES，0：NO）
 * isMailAppPush               是否接收私信推送通知（1：YES，0：NO）
 * isSayHiAppPush              是否接收SayHi推送通知（1：YES，0：NO）
 */
@interface LSAppPushConfigItemObject : NSObject
@property (nonatomic, assign) BOOL isPriMsgAppPush;
@property (nonatomic, assign) BOOL isMailAppPush;
@property (nonatomic, assign) BOOL isSayHiAppPush;

@end
