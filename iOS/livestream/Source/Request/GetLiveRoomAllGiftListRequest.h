//
//  GetLiveRoomAllGiftListRequest.h
//  dating
//  3.7.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomAllGiftListRequest : SessionRequest
@property (nonatomic, strong) GetLiveRoomAllGiftListFinishHandler _Nullable finishHandler;
@end
