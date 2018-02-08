//
//  LSUserInfoModel.h
//  livestream
//
//  Created by randy on 2017/11/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSAnchorInfoItemObject.h"


@interface LSUserInfoModel : NSObject

/**
 * 指定观众/主播信息结构体
 * userId           观众ID/主播ID
 * nickName         昵称
 * photoUrl         头像url
 * age              年龄
 * country          国籍
 * isOnline         是否在线（0：否，1：是）
 * isAnchor         是否主播（0：否，1：是）
 * leftCredit       观众剩余信用点
 * userLevel        观众/主播等级
 * anchorInfo       主播信息
 * riderId          座驾ID
 * riderName        座驾名称
 * riderUrl         座驾url
 */
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString * photoUrl;
@property (nonatomic, assign) int age;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isAnchor;
@property (nonatomic, assign) double leftCredit;
@property (nonatomic, assign) int userLevel;
@property (nonatomic, strong) LSAnchorInfoItemObject *anchorInfo;
@property (nonatomic, copy) NSString *riderId;
@property (nonatomic, copy) NSString *riderName;
@property (nonatomic, copy) NSString *riderUrl;

@end
