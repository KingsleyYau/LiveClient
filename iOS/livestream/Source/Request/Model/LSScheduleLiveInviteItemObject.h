//
//  LSScheduleLiveInviteItemObject.h
//  dating
//
//  Created by Alex on 20/03/30.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LSScheduleLiveInviteItemObject : NSObject
{

}
/**
 * 直播预付费邀请结构体
 * inviteId                         邀请ID
 * sendFlag                     发起方
 * isSummerTime             选中的时区是否夏令时
 * startTime                    开始时间(GMT时间戳)
 * endTime                    结束时间(GMT时间戳)
 * timeZoneCity             时区城市
 * duration                     分钟时长
 * stats                         邀请状态
 * addTime                   添加时间(GMT时间戳)
 * timeZoneValue           时区差值
 */
@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, assign) LSScheduleSendFlagType sendFlag;
@property (nonatomic, assign) BOOL isSummerTime;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, copy) NSString* timeZoneValue;
@property (nonatomic, copy) NSString* timeZoneCity;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) LSScheduleInviteStatus status;
@property (nonatomic, assign) NSInteger addTime;
@property (nonatomic, assign) NSInteger statusUpdateTime;
@end
