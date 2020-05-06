//
//  LSCheckDiscountItemObject.h
//  dating
//
//  Created by Alex on 19/11/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSCheckDiscountItemObject : NSObject
{

}
/**
 * 优惠折扣结构体
 * type                 优惠折扣类型(LSDISCOUNTTYPE_BIRTHDAY:主播生日, LSDISCOUNTTYPE_HOLIDAY:节日活动, LSDISCOUNTTYPE_COMMON:常规活动)
 * name                 优惠折扣名称
 * discount             折扣
 * imgUrl               图标图片地址
 */
@property (nonatomic, assign) LSDiscountType type;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) double discount;
@property (nonatomic, copy) NSString* imgUrl;
@end
