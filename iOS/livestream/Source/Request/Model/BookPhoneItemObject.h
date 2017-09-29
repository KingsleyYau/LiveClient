//
//  BookPhoneItemObject.h
//  dating
//
//  Created by Alex on 17/9/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BookPhoneItemObject : NSObject
/**
 * 验证的电话号码信息结构体
 * country      国家
 * areaCode     电话区号
 * phoneNo      电话号码
 */
@property (nonatomic, copy) NSString* _Nonnull country;
@property (nonatomic, copy) NSString* _Nonnull areaCode;
@property (nonatomic, copy) NSString* _Nonnull phoneNo;


@end
