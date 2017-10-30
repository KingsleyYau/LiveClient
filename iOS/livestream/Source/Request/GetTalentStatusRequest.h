//
//  GetTalentStatusRequest.h
//  dating
//  3.11.获取才艺点播邀请状态接口
//  Created by Alex on 17/8/30
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetTalentStatusRequest : LSSessionRequest
// 直播间ID
@property (nonatomic, copy) NSString * _Nullable  roomId;
// 才艺点播邀请ID
@property (nonatomic, copy) NSString * _Nullable  talentInviteId;
@property (nonatomic, strong) GetTalentStatusFinishHandler _Nullable finishHandler;
@end
