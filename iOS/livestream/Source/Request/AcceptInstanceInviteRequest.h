//
//  AcceptInstanceInviteRequest.h
//  dating
//  4.7.观众处理立即私密邀请
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface AcceptInstanceInviteRequest : SessionRequest
// 邀请ID
@property (nonatomic, copy) NSString *_Nonnull inviteId;
// 是否同意（0: 否， 1: 是）
@property (nonatomic, assign) BOOL isConfirm;
@property (nonatomic, strong) AcceptInstanceInviteFinishHandler _Nullable finishHandler;
@end
