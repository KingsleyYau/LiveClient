//
//  LSScheduleDurationItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSScheduleDurationItemObject : NSObject
{

}
/**
 * 预约时间价格结构体
 * duration               分钟时长(30)
 * isDefault              是否默认选中(1)
 * credit                   优惠价格(13.5)
 * originalCredit       原价(15)
 */
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, assign) double credit;
@property (nonatomic, assign) double originalCredit;
@end
