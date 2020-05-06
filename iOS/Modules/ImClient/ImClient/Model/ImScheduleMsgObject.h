
//
//  ImScheduleMsgObject.h
//  livestream
//
//  Created by Max on 2020/4/3.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"
#import <httpcontroller/HttpRequestEnum.h>

/**
  私密直播预付费信息
 */
@interface ImScheduleMsgObject : NSObject

/**
 * 为客服端交互信息
 * scheduleInviteId           预约邀请id
 * status           预付费状态 （IMSCHEDULESENDSTATUS_PENDING ： pending， IMSCHEDULESENDSTATUS_CONFIRMED：接受， IMSCHEDULESENDSTATUSE_DECLINED：拒绝）
 * sendFlag        发送方 （LSSCHEDULESENDFLAGTYPE_MAN：男士， LSSCHEDULESENDFLAGTYPE_ANCHOR：女士）
 * duration         时长（分钟）
 * origintduration     原有时长（分钟），发起时候与duration一致
 * period    时区字符串（如 Mar 21， 11:00 - 12:00 HK(GMT +08:00)）
 * startTime         预约时间段开始时间戳
 * actionGmtTime        状态变更时间戳
 * sendTime        发送时间戳
 * nickName        发送方昵称
 * fromId        发送方id
 * toNickName       接收方昵称
 */
@property (nonatomic, copy) NSString* scheduleInviteId;
@property (nonatomic, assign) IMScheduleSendStatus status;
@property (nonatomic, assign) LSScheduleSendFlagType sendFlag;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int origintduration;
@property (nonatomic, copy) NSString* period;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger statusUpdateTime;
@property (nonatomic, assign) NSInteger sendTime;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* fromId;
@property (nonatomic, copy) NSString* toNickName;

@end
