//
// LSSendinvitationHangoutRequest.h
//  dating
//  8.2.发起多人互动邀请
//  Created by Max on 18/04/12.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSendinvitationHangoutRequest : LSSessionRequest
/**
 *  8.2.发起多人互动邀请接口
 *
 *  roomId           当前发起的直播间ID
 *  anchorId         主播ID
 *  recommendId      推荐ID（可无，无则表示不是因推荐导致观众发起邀请）
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable roomId;
@property (nonatomic, copy) NSString * _Nullable anchorId;
@property (nonatomic, copy) NSString * _Nullable recommendId;
@property (nonatomic, strong) SendInvitationHangoutFinishHandler _Nullable finishHandler;
@end
