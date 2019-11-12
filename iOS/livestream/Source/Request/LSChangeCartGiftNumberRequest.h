//
//  LSChangeCartGiftNumberRequest.h
//  dating
//  15.9.修改购物车商品数量
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSChangeCartGiftNumberRequest : LSSessionRequest

/**
 * 15.9.修改购物车商品数量接口
 *
 * anchorId         主播ID
 * giftId           礼品ID
 * giftNumber       礼品数量
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable giftId;
@property (nonatomic, assign) int giftNumber;
@property (nonatomic, strong) ChangeCartGiftNumberFinishHandler _Nullable finishHandler;
@end
