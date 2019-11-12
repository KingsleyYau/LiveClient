//
//  GetBackPackUnreadNumItemObject.h
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GetBackPackUnreadNumItemObject : NSObject
/**
 * 背包未读数量结构体
 * total                 以下参数数量总和
 * voucherUnreadNum      试用劵未读的数量
 * giftUnreadNum         背包礼物的未读数量
 * rideUnreadNum         座驾的未读数量
 * livechatVoucherUnreadNum live试用劵未读的数量
 */
@property (nonatomic, assign) int total;
@property (nonatomic, assign) int voucherUnreadNum;
@property (nonatomic, assign) int giftUnreadNum;
@property (nonatomic, assign) int rideUnreadNum;
@property (nonatomic, assign) int livechatVoucherUnreadNum;

@end
