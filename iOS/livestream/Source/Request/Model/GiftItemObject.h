//
//  GiftItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftNumItemObject.h"
@interface GiftItemObject : NSObject
/**
 * 礼物结构体
 * giftId		礼物ID
 * giftNumList   可选礼物数量列表
 */
@property (nonatomic, copy) NSString* _Nonnull giftId;
@property (nonatomic, strong) NSArray<GiftNumItemObject*>* _Nonnull giftNumList;


@end
