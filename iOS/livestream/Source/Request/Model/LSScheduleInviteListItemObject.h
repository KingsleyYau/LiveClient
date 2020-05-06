//
//  LSScheduleInviteListItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSScheduleAnchorInfoItemObject.h"

@interface LSScheduleInviteListItemObject : NSObject
{

}
/**
 * 预付费邀请列表结构体
 * anchorInfo                   主播信息
 * inviteId                         邀请ID(S94921659)
 * sendFlag                     发起方(LSSCHEDULESENDFLAGTYPE_MAN)
 * isSummerTime            选中的时区是否夏令时(0)
 * startTime                    开始时间(GMT时间戳)(1588734000)
 * endTime                     结束时间(GMT时间戳)(1588737600)
 * timeZoneValue           时区差值(-03:00)
 * timeZoneCity             时区城市(UYST)
 * duration                     分钟时长(30)
 * stats                          邀请状态（LSSCHEDULEINVITESTATUS_CONFIRMED）
 * type                          邀请来源类型（LSSCHEDULEINVITETYPE_LIVECHAT）
 * refId                          关联的ID(信件ID、livechat邀请ID、场次ID等)(1587612114-4100058)
 * hasRead                   是否已读（YES）
 * isActive                    是否激活（NO）
 */
@property (nonatomic, strong) LSScheduleAnchorInfoItemObject* anchorInfo;
@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, assign) LSScheduleSendFlagType sendFlag;
@property (nonatomic, assign) BOOL isSummerTime;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, assign) NSString* timeZoneValue;
@property (nonatomic, copy) NSString* timeZoneCity;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) LSScheduleInviteStatus status;
@property (nonatomic, assign) LSScheduleInviteType type;
@property (nonatomic, copy) NSString* refId;
@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) BOOL isActive;
@end
