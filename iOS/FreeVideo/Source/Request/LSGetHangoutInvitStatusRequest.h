//
// LSGetHangoutInvitStatusRequest.h
//  dating
//  8.4.获取多人互动邀请状态
//  Created by Max on 18/04/13.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetHangoutInvitStatusRequest : LSSessionRequest
/**
 *  8.4.获取多人互动邀请状态接口
 *
 *  inviteId         邀请ID
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable inviteId;
@property (nonatomic, strong) GetHangoutInvitStatusFinishHandler _Nullable finishHandler;
@end
