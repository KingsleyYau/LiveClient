//
//  LSCheckDiscountRequest.h
//  dating
//  15.13.检测优惠折扣
//  Created by Alex on 19/11/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSCheckDiscountRequest : LSSessionRequest

/**
 * 15.13.检测优惠折扣接口
 *
 * anchorId         主播ID
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) CheckDiscountFinishHandler _Nullable finishHandler;
@end
