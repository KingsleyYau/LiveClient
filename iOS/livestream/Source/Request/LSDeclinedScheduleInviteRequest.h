//
//  LSDeclinedScheduleInviteRequest.h
//  dating
//  17.5.拒绝预付费直播邀请
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSDeclinedScheduleInviteRequest : LSSessionRequest

/**
*  17.5.拒绝预付费直播邀请接口
*
*  @param inviteId         邀请ID
*  @param finishHandler            接口回调
*
*  @return 成功请求Id
*/
@property (nonatomic, copy) NSString* _Nullable inviteId;
@property (nonatomic, strong) DeclinedScheduleInviteFinishHandler _Nullable finishHandler;
@end
