//
//  LSGetCartGiftTypeNumRequest.h
//  dating
//  15.6.获取购物车礼品种类数
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetCartGiftTypeNumRequest : LSSessionRequest

/**
 * 15.6.获取购物车礼品种类数接口
 *
 * anchorId         主播ID
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) GetCartGiftTypeNumFinishHandler _Nullable finishHandler;
@end
