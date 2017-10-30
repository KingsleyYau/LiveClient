//
//  GetGiftDetailRequest.h
//  dating
//  3.7.获取指定礼物详情（用于观众端／主播端在直播间收到《获取礼物列表》没有礼物时，获取指定礼物详情来显示）接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetGiftDetailRequest : LSSessionRequest
// 礼物ID
@property (nonatomic, copy) NSString* _Nonnull giftId;
@property (nonatomic, strong) GetGiftDetailFinishHandler _Nullable finishHandler;
@end
