//
//  LSScheduleInviteItem.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/2.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSSendScheduleInviteRequest.h"
#import "LSTimeZoneItemObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSScheduleInviteItem : NSObject

/* 邀请来源类型（LSSCHEDULEINVITETYPE_EMF.emf  LSSCHEDULEINVITETYPE_LIVECHAT.livechat  LSSCHEDULEINVITETYPE_PUBLICLIVE.公开直播间  LSSCHEDULEINVITETYPE_PRIVATELIVE.私密直播间） */
@property (nonatomic, assign)  LSScheduleInviteType type;
/* 关联的ID(信件ID、livechat邀请ID、场次ID等) */
@property (nonatomic, copy) NSString *refId;
/* 主播ID */
@property (nonatomic, copy) NSString *anchorId;
/* 邀请开始时间(格式：yyyy-mm-dd hh:00:00) */
@property (nonatomic, copy) NSString *startTime;
/* 分钟时长 */
@property (nonatomic, assign)  int duration;
/* 记录选择时间Item */
@property (nonatomic, strong) LSTimeZoneItemObject *timeZoneItem;

/*********  接收预付费邀请用  ********/
/* 原有时长 */
@property (nonatomic, assign) int origintduration;
/* 时区字符串（如 Mar 21， 11:00 - 12:00 HK(GMT +08:00)） */
@property (nonatomic, copy) NSString* period;
/* 预约时间段开始时间戳 */
@property (nonatomic, assign) NSInteger gmtStartTime;
/* 发送时间戳 */
@property (nonatomic, assign) NSInteger sendTime;

@end

NS_ASSUME_NONNULL_END
