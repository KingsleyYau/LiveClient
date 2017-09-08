//
//  VoucherInfoObject.h
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoucherInfoObject : NSObject
/* 试用劵ID */
@property (nonatomic, copy) NSString * _Nonnull voucherId;
/* 试用劵图标url */
@property (nonatomic, copy) NSString * _Nonnull photoUrl;
/* 试用劵描述 */
@property (nonatomic, copy) NSString * _Nonnull desc;

@end
