//
//  LSFlowerGiftItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSFlowerGiftItemObject : NSObject
{

}
/**
 * 鲜花礼品结构体
 * typeId                分类ID
 * giftId               礼品ID
 * giftName             礼品名称
 * giftImg              礼品图片
 * priceShowType        显示何种价格（LSPRICESHOWTYPE_WEEKDAY：平日价，LSPRICESHOWTYPE_HOLIDAY：节日价，LSPRICESHOWTYPE_DISCOUNT：优惠价）
 * giftWeekdayPrice     平日价
 * giftDiscountPrice    优惠价
 * giftPrice            显示价格
 * isNew                是否NEW
 * deliverableCountry   配送国家
 * giftDescription      描述
 */
@property (nonatomic, copy) NSString* typeId;
@property (nonatomic, copy) NSString* giftId;
@property (nonatomic, copy) NSString* giftName;
@property (nonatomic, copy) NSString* giftImg;
@property (nonatomic, assign) LSPriceShowType priceShowType;
@property (nonatomic, assign) double giftWeekdayPrice;
@property (nonatomic, assign) double giftDiscountPrice;
@property (nonatomic, assign) double giftPrice;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, strong) NSMutableArray<NSString *>* deliverableCountry;
@property (nonatomic, copy) NSString* giftDescription;
@end
