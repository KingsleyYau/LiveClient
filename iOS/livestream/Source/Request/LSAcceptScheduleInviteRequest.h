//
//  LSAcceptScheduleInviteRequest.h
//  dating
//  17.4.接受预付费直播邀请
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSAcceptScheduleInviteRequest : LSSessionRequest

/**
*  17.4.接受预付费直播邀请接口
*
*  @param inviteId         邀请ID
*  @param duration         分钟时长
*  @param finishHandler            接口回调
*
*  @return 成功请求Id
*/
@property (nonatomic, copy) NSString* _Nullable inviteId;
@property (nonatomic, assign)  int duration;
@property (nonatomic, strong) AcceptScheduleInviteFinishHandler _Nullable finishHandler;
@end
