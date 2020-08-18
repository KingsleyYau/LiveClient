//
//  LSCancelScheduleInviteRequest.h
//  dating
//  17.6.取消预付费直播邀请
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSCancelScheduleInviteRequest : LSSessionRequest

/**
*  17.6.取消预付费直播邀请接口
*
*  inviteId         邀请ID
*  finishHandler            接口回调
*
*/
@property (nonatomic, copy) NSString* _Nullable inviteId;
@property (nonatomic, strong) CancelScheduleInviteFinishHandler _Nullable finishHandler;
@end
