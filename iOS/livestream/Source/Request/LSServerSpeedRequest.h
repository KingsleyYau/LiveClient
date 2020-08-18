//
//  LSServerSpeedRequest.h
//  dating
//  6.8.提交流媒体服务器测速结果
//  Created by Alex on 17/10/13
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSServerSpeedRequest : LSSessionRequest

@property (nonatomic, copy) NSString *_Nonnull sid;
@property (nonatomic, assign) int res;
// liveRoomId直播间ID可无
@property (nonatomic, copy) NSString *_Nullable liveRoomId;

@property (nonatomic, strong) ServerSpeedFinishHandler _Nullable finishHandler;
@end
