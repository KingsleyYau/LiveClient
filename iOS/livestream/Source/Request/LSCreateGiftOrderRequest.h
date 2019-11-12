//
//  LSCreateGiftOrderRequest.h
//  dating
//  15.12.生成订单
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSCreateGiftOrderRequest : LSSessionRequest

/**
 * 15.12.生成订单接口
 *
 * anchorId                 主播ID
 * greetingMessage          文本信息
 * specialDeliveryRequest   文本信息
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable greetingMessage;
@property (nonatomic, copy) NSString* _Nullable specialDeliveryRequest;
@property (nonatomic, strong) CreateGiftOrderFinishHandler _Nullable finishHandler;
@end
