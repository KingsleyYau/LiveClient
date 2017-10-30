//
//  GetCreateBookingInfoItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookTimeItemObject.h"
#import "LSGiftItemObject.h"
#import "BookPhoneItemObject.h"

@interface GetCreateBookingInfoItemObject : NSObject
/**
 * 新建预约邀请信息结构体
 * bookDeposit	预约定金数
 * bookTime      预约时间表
 * bookGift      预约礼物
 */
@property (nonatomic, assign) double bookDeposit;
@property (nonatomic, strong) NSArray<BookTimeItemObject*>* bookTime;
@property (nonatomic, strong) NSArray<LSGiftItemObject*>* bookGift;
@property (nonatomic, strong) BookPhoneItemObject * bookPhone;

@end
