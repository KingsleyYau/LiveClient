//
//  CheckLiveRoomRequest.h
//  dating
//  3.2.获取本人正在直播的直播间信息
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface CheckLiveRoomRequest : SessionRequest
@property (nonatomic, strong) CheckLiveRoomFinishHandler _Nullable finishHandler;
@end
