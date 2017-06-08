//
//  GetLiveRoomModifyInfoRequest.h
//  dating
//  3.4.获取直播间观众头像列表
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomModifyInfoRequest : SessionRequest
@property (nonatomic,strong) GetLiveRoomModifyInfoFinishHandler _Nullable finishHandler;
@end
