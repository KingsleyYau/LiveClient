//
//  LSUserInfoItemObject
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSAnchorInfoItemObject.h"
@interface LSUserInfoItemObject : NSObject
/**
 * 指定观众/主播信息结构体
 * userId           观众ID/主播ID
 * nickName         昵称
 * photoUrl		    头像url
 * age              年龄
 * country          国籍
 * userLevel        观众/主播等级
 * isOnline         是否在线（0：否，1：是）
 * isAnchor         是否主播（0：否，1：是）
 * leftCredit       观众剩余信用点
 * anchorInfo       主播信息
 */
@property (nonatomic, copy) NSString* _Nonnull userId;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, copy) NSString* _Nonnull photoUrl;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString* _Nonnull country;
@property (nonatomic, assign) int userLevel;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isAnchor;
@property (nonatomic, assign) double leftCredit;
@property (nonatomic, strong) LSAnchorInfoItemObject * _Nullable anchorInfo;

@end
