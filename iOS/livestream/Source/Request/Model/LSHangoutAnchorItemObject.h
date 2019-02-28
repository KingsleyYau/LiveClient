//
// LSHangoutAnchorItemObject.h
//  dating
//
//  Created by Alex on 18/4/12.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSHangoutAnchorItemObject : NSObject
#import <httpcontroller/HttpRequestEnum.h>
/**
 * 多人互动的主播列表结构体
 * anchorId         主播ID
 * nickName         昵称
 * photoUrl         主播封面url
 * avatarImg        主播头像url
 * age              年龄
 * country          国家
 * onlineStatus     在线状态（ONLINE_STATUS_OFFLINE：离线，ONLINE_STATUS_LIVE：在线）
 */
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, copy) NSString* _Nonnull photoUrl;
@property (nonatomic, copy) NSString* _Nonnull avatarImg;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString* _Nonnull country;
@property (nonatomic, assign) OnLineStatus onlineStatus;

@end
