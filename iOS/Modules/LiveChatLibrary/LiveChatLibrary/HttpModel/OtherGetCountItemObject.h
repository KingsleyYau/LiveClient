//
//  OtherGetCountItemObject.h
//  dating
//
//  Created by Max on 16/6/2.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherGetCountItemObject : NSObject

/**
 *  余额
 */
@property (nonatomic, assign) double money;

/**
 *  优惠券数量
 */
@property (nonatomic, assign) NSInteger	coupon;

/**
 *  积分数量
 */
@property (nonatomic, assign) NSInteger	integral;

/**
 *  注册步骤
 */
@property (nonatomic, assign) NSInteger regstep;

/**
 *  相册权限
 */
@property (nonatomic, assign) BOOL allowAlbum;

/**
 *  未读意向信数量
 */
@property (nonatomic, assign) NSInteger	admirerUr;

@end
