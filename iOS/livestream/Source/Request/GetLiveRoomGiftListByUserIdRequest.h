//
//  GetLiveRoomGiftListByUserIdRequest.h
//  dating
//  3.8.获取直播间可发送的礼物列表（观众端获取已进入的直播间可发送的礼物列表）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomGiftListByUserIdRequest : SessionRequest
@property (nonatomic, strong) NSString* roomId;
@property (nonatomic, strong) GetLiveRoomGiftListByUserIdFinishHandler _Nullable finishHandler;
@end
