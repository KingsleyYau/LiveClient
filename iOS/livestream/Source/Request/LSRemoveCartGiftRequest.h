//
//  LSRemoveCartGiftRequest.h
//  dating
//  15.10.删除购物车商品
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSRemoveCartGiftRequest : LSSessionRequest

/**
 * 15.10.删除购物车商品接口
 *
 * anchorId         主播ID
 * giftId           礼品ID
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable giftId;
@property (nonatomic, strong) RemoveCartGiftFinishHandler _Nullable finishHandler;
@end
