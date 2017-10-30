//
//  CancelPrivateRequest.h
//  dating
//  4.3.取消预约邀请接口
//  Created by Alex on 17/8/28
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface CancelPrivateRequest : LSSessionRequest

// 邀请ID
@property (nonatomic, copy) NSString* _Nonnull invitationId;
@property (nonatomic, strong) SendCancelPrivateLiveInviteFinishHandler _Nullable finishHandler;
@end
