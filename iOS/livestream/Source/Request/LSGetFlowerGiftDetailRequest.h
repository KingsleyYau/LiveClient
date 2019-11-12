//
//  LSGetFlowerGiftDetailRequest.h
//  dating
//  15.2.获取鲜花礼品详情
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetFlowerGiftDetailRequest : LSSessionRequest

/**
 * 15.2.获取鲜花礼品详情接口
 *
 * giftId           礼物ID
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable giftId;
@property (nonatomic, strong) GetFlowerGiftDetailFinishHandler _Nullable finishHandler;
@end
