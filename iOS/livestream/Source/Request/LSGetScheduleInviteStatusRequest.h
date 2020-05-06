//
//  LSGetScheduleInviteStatusRequest.h
//  dating
//  17.10.获取预付费直播邀请状态
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetScheduleInviteStatusRequest : LSSessionRequest

/**
*  17.10.获取预付费直播邀请状态接口
*
*  @param finishHandler            接口回调
*
*  @return 成功请求Id
*/
@property (nonatomic, strong) GetScheduleInviteStatusFinishHandler _Nullable finishHandler;
@end
