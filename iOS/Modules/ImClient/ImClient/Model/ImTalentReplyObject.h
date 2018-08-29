//
//  ImTalentReplyObject.h
//  dating
//
//  Created by Alex on 17/09/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

/**
 * 才艺回复通知结构体
 * roomId                 直播间ID
 * talentInviteId         才艺邀请ID
 * talentId               才艺ID
 * name                   才艺名称
 * credit                 信用点
 * status                 状态（1:已接受 2:拒绝）
 * rebateCredit           返点
 * giftId                 礼物ID
 * giftName               礼物名称
 * giftNum                礼物数量
 */
@interface ImTalentReplyObject : NSObject
@property (nonatomic, copy) NSString* _Nullable roomId;
@property (nonatomic, copy) NSString* _Nullable talentInviteId;
@property (nonatomic, copy) NSString* _Nullable talentId;
@property (nonatomic, copy) NSString* _Nullable name;
@property (nonatomic, assign) double credit;
@property (nonatomic, assign) TalentStatus status;
@property (nonatomic, assign) double rebateCredit;
@property (nonatomic, copy) NSString* _Nullable giftId;
@property (nonatomic, copy) NSString* _Nullable giftName;
@property (nonatomic, assign) int giftNum;

@end
