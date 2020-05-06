//
//  LSScheduleInviteDetailItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSScheduleInviteDetailItemObject : NSObject
{

}
/**
 * 预付费邀请详情结构体
 * inviteId                         邀请ID(S94921659)
 * anchorId                     主播ID(G304568)
 * sendFlag                     发起方(1)
 * isSummerTime             选中的时区是否夏令时(0)
 * startTime                    开始时间(GMT时间戳)(1588734000)
 * endTime                    结束时间(GMT时间戳)(1588737600)
 * addTime                   添加时间(GMT时间戳)(1587612365)
 * timeZoneValue           时区差值(-03:00)
 * timeZoneCity             时区城市(UYST)
 * duration                     分钟时长(30)
 * stats                         邀请状态(2)
 * cancelerName         取消者昵称
 * type                         邀请来源类型(2)
 * refId                        关联的ID(信件ID、livechat邀请ID、场次ID等)(1587612114-4100058)
 * isActive                    是否激活(0)
 */
@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, assign) LSScheduleSendFlagType sendFlag;
@property (nonatomic, assign) BOOL isSummerTime;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, assign) NSInteger addTime;
@property (nonatomic, assign) NSInteger statusUpdateTime;
@property (nonatomic, copy) NSString* timeZoneValue;
@property (nonatomic, copy) NSString* timeZoneCity;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) LSScheduleInviteStatus status;
@property (nonatomic, copy) NSString* cancelerName;
@property (nonatomic, assign) LSScheduleInviteType type;
@property (nonatomic, copy) NSString* refId;
@property (nonatomic, assign) BOOL isActive;
@end
