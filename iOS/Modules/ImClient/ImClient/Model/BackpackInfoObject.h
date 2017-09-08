//
//  BackpackInfoObject.h
//  dating
//
//  Created by Alex on 17/8/15.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftInfoObject.h"
#import "VoucherInfoObject.h"
#import "RideInfoObject.h"

// 返点信息队列
@interface BackpackInfoObject : NSObject
/* 新增的背包礼物 */
@property (nonatomic, strong) GiftInfoObject* gift;
/* 新增的试用劵 */
@property (nonatomic, strong) VoucherInfoObject* voucher;
/* 新增的座驾 */
@property (nonatomic, strong) RideInfoObject* ride;

@end
