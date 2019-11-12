//
//  LSUpQnInviteIdRequest.h
//  dating
//  6.23.qn邀请弹窗更新邀请id
//  Created by Alex on 19/7/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSUpQnInviteIdRequest : LSSessionRequest

/**
 *  6.23.qn邀请弹窗更新邀请id接口
 *
 *  manId                         用户ID
 *  anchorId                      主播id
 *  inviteId                      邀请id
 *  roomId                        直播间id
 *  inviteType                    邀請類型(LSBUBBLINGINVITETYPE_ONEONONE:one-on-one LSBUBBLINGINVITETYPE_HANGOUT:Hangout LSBUBBLINGINVITETYPE_LIVECHAT:Livechat)
 *  finishHandler    接口回调s
 */
@property (nonatomic, copy) NSString* _Nonnull manId;
@property (nonatomic, copy) NSString* _Nonnull anchorId;
@property (nonatomic, copy) NSString* _Nonnull inviteId;
@property (nonatomic, copy) NSString* _Nonnull roomId;
@property (nonatomic, assign) LSBubblingInviteType inviteType;
@property (nonatomic, strong) UpQnInviteIdFinishHandler _Nullable finishHandler;
@end
