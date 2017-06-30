//
//  GetLiveRoomGiftDetailRequest.h
//  dating
//  3.9.获取指定礼物详情（用于观众端／主播端在直播间收到《3.7.》没有礼物时，获取指定礼物详情来显示）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomGiftDetailRequest : SessionRequest
@property (nonatomic, strong) NSString* giftId;
@property (nonatomic, strong) GetLiveRoomGiftDetailFinishHandler _Nullable finishHandler;
@end
