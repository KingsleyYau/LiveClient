//
// LSCancelInviteHangoutRequest.h
//  dating
//  8.3.取消多人互动邀请
//  Created by Max on 18/04/13.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSCancelInviteHangoutRequest : LSSessionRequest
/**
 *  8.3.取消多人互动邀请接口
 *
 *  inviteId         邀请ID
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable inviteId;
@property (nonatomic, strong) CancelInviteHangoutFinishHandler _Nullable finishHandler;
@end
