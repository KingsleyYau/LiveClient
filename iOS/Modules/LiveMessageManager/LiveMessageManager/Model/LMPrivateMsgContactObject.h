//
// LMPrivateMsgContactObject.h
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LMPrivateMsgContactObject : NSObject
/**
 * 私信联系人信息
 * userId           用户ID
 * nickName         昵称
 * avatarImg        头像URL
 * onlineStatus     在线状态（0：离线，1：在线）
 * lastMsg          最近一条私信（包括自己及对方）
 * updateTime       最近一条私信服务器处理时间戳（1970年起的秒数）
 * unreadNum        未读条数
 * anchorType       是否主播（NO：否，YES：是）
 */
@property (nonatomic, copy) NSString* _Nonnull userId;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, copy) NSString* _Nonnull avatarImg;
@property (nonatomic, assign) OnLineStatus onlineStatus;
@property (nonatomic, copy) NSString* _Nonnull lastMsg;
@property (nonatomic, assign) NSInteger updateTime;
@property (nonatomic, assign) int unreadNum;
@property (nonatomic, assign) BOOL isAnchor;

@end
