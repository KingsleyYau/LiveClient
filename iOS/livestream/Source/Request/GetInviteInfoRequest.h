//
//  GetInviteInfoRequest.h
//  dating
//  3.9.获取指定立即私密邀请信息接口(已废弃)
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetInviteInfoRequest : SessionRequest
// 邀请ID
@property (nonatomic, copy) NSString* _Nonnull inviteId;
@property (nonatomic, strong) GetInviteInfoFinishHandler _Nullable finishHandler;
@end
