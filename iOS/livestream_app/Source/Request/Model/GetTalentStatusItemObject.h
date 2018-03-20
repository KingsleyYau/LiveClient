//
//  GetTalentStatusItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface GetTalentStatusItemObject : NSObject
/**
 * 才艺信息结构体
 * talentInviteId     才艺邀请ID
 * talentId           才艺ID
 * name               才艺名称
 * credit             发送礼物所需的信用点
 * status             状态（0:未回复 1:已接受 2:拒绝）
 */
@property (nonatomic, copy) NSString *_Nonnull talentInviteId;
@property (nonatomic, copy) NSString *_Nonnull talentId;
@property (nonatomic, copy) NSString *_Nonnull name;
@property (nonatomic, assign) double credit;
@property (nonatomic, assign) HTTPTalentStatus status;

@end
