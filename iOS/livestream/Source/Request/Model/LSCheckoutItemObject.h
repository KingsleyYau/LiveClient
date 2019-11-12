//
//  LSCheckoutItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSCheckoutGiftItemObject.h"
#import "LSGreetingCardItemObject.h"

@interface LSCheckoutItemObject : NSObject
{

}
/**
 * Checkout商品结构体
 * giftList                   礼品列表
 * greetingCard               免费贺卡
 * deliveryPrice              邮费价格
 * holidayPrice               优惠价格
 * totalPrice                 总额
 * greetingmessage            文本信息
 * specialDeliveryRequest     文本信息
 */
@property (nonatomic, strong) NSMutableArray<LSCheckoutGiftItemObject *>* giftList;
@property (nonatomic, strong) LSGreetingCardItemObject* greetingCard;
@property (nonatomic, assign) double deliveryPrice;
@property (nonatomic, assign) double holidayPrice;
@property (nonatomic, assign) double totalPrice;
@property (nonatomic, copy) NSString* greetingmessage;
@property (nonatomic, copy) NSString* specialDeliveryRequest;
@end
