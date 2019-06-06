//
//  RideItemObject.h
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface RideItemObject : NSObject
/**
 * 坐驾结构体
 * rideId          座驾ID
 * photoUrl        座驾图片url
 * name            座驾名称
 * grantedDate     获取时间
 * startValidDate  有效开始时间
 * expDate         过期时间
 * read            已读状态（0:未读 1:已读）
 * isUse           是否使用中（0:否 1:是）
 */
@property (nonatomic, copy) NSString* _Nonnull rideId;
@property (nonatomic, copy) NSString* _Nonnull photoUrl;
@property (nonatomic, copy) NSString* _Nonnull name;
@property (nonatomic, assign) NSInteger grantedDate;
@property (nonatomic, assign) NSInteger startValidDate;
@property (nonatomic, assign) NSInteger expDate;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) BOOL isUse;

@end
