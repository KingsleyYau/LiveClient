//
//  LSGetScheduleInviteDetailRequest.h
//  dating
//  17.8.获取预付费直播邀请详情
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetScheduleInviteDetailRequest : LSSessionRequest

/**
*  17.8.获取预付费直播邀请详情接口
*
*  inviteId         邀请ID
*  finishHandler            接口回调
*
*/
@property (nonatomic, copy) NSString* _Nullable inviteId;
@property (nonatomic, strong) GetScheduleInviteDetailFinishHandler _Nullable finishHandler;
@end
