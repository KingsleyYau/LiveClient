//
//  GetRoomInfoRequest.h
//  dating
//  3.3.获取本人有效直播间或邀请信息接口(已废弃)
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetRoomInfoRequest : SessionRequest

@property (nonatomic, strong) GetRoomInfoFinishHandler _Nullable finishHandler;
@end
