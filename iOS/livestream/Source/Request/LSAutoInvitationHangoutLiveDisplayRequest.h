//
//  LSAutoInvitationHangoutLiveDisplayRequest.h
//  dating
//  8.9.自动邀请Hangout直播邀請展示條件
//  Created by Alex on 19/1/22
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSAutoInvitationHangoutLiveDisplayRequest : LSSessionRequest
/**
 * anchorId                         主播ID
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
/**
 * isAuto 是否自动（1：自动  0：手动）
 */
@property (nonatomic, assign) BOOL isAuto;
@property (nonatomic, strong) AutoInvitationHangoutLiveDisplayFinishHandler _Nullable finishHandler;
@end
