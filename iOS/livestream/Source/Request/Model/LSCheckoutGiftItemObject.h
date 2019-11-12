//
//  LSCheckoutGiftItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSCheckoutGiftItemObject : NSObject
{

}
/**
 * checkout鲜花礼品结构体
 * giftId               礼品ID
 * giftName             礼品名称
 * giftImg              礼品图片
 * giftNumber           礼品数量
 * giftPrice            礼品价格
 * giftstatus           是否可用
 * isGreetingCard       是否是贺卡
 */
@property (nonatomic, copy) NSString* giftId;
@property (nonatomic, copy) NSString* giftName;
@property (nonatomic, copy) NSString* giftImg;
@property (nonatomic, assign) int giftNumber;
@property (nonatomic, assign) double giftPrice;
@property (nonatomic, assign) BOOL giftstatus;
@property (nonatomic, assign) BOOL isGreetingCard;
@end
