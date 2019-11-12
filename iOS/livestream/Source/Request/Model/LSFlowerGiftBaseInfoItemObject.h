//
//  LSFlowerGiftBaseInfoItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSFlowerGiftBaseInfoItemObject : NSObject
{

}
/**
 * 鲜花礼品基本信息结构体
 * giftId               礼品ID
 * giftName             礼品名称
 * giftImg              礼品图片
 * giftNumber           礼品数量
 * giftPrice            礼品价格
 */
@property (nonatomic, copy) NSString* giftId;
@property (nonatomic, copy) NSString* giftName;
@property (nonatomic, copy) NSString* giftImg;
@property (nonatomic, assign) int giftNumber;
@property (nonatomic, assign) double giftPrice;
@end
