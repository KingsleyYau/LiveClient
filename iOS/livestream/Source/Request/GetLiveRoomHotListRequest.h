//
//  GetLiveRoomHotListRequest.h
//  dating
//  3.6.获取Hot列表
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomHotListRequest : SessionRequest
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetLiveRoomHotListFinishHandler _Nullable finishHandler;
@end
