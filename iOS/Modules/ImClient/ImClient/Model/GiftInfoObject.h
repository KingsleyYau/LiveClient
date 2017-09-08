//
//  GiftInfoObject.h
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftInfoObject : NSObject
/* 礼物ID */
@property (nonatomic, copy) NSString * _Nonnull giftId;
/* 礼物名称 */
@property (nonatomic, copy) NSString * _Nonnull name;
/* 礼物数量 */
@property (nonatomic, assign) int num;

@end
