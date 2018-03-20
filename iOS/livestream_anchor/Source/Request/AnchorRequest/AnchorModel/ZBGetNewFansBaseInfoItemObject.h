//
//  ZBGetNewFansBaseInfoItemObject.h
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBGetNewFansBaseInfoItemObject : NSObject
/**
 * 指定观众信息结构体
 * userId           用户Id
 * nickName         观众昵称
 * photoUrl		    观众头像url
 * riderId          座驾ID
 * riderName        座驾名称
 * riderUrl         座驾图片url
 * level            用户等级
 */
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, copy) NSString *_Nonnull riderId;
@property (nonatomic, copy) NSString *_Nonnull riderName;
@property (nonatomic, copy) NSString *_Nonnull riderUrl;
@property (nonatomic, assign) int level;

@end
