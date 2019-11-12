//
//  LSCheckOutCartGiftRequest.h
//  dating
//  15.11.Checkout商品
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSCheckOutCartGiftRequest : LSSessionRequest

/**
 * 15.11.Checkout商品接口
 *
 * anchorId         主播ID
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) CheckOutCartGiftFinishHandler _Nullable finishHandler;
@end
