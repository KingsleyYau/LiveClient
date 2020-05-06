//
//  LSSendScheduleInviteRequest.h
//  dating
//  17.3.发送预付费直播邀请
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSendScheduleInviteRequest : LSSessionRequest

/**
*  17.3.发送预付费直播邀请接口
*
*  @type             邀请来源类型（LSSCHEDULEINVITETYPE_EMF.emf  LSSCHEDULEINVITETYPE_LIVECHAT.livechat  LSSCHEDULEINVITETYPE_PUBLICLIVE.公开直播间  LSSCHEDULEINVITETYPE_PRIVATELIVE.私密直播间）
*  @refId            关联的ID(信件ID、livechat邀请ID、场次ID等)
*  @anchorId         主播ID
*  @timeZoneId       时区ID
*  @startTime        邀请开始时间(格式：yyyy-mm-dd hh:00:00)
*  @duration         分钟时长
*  @finishHandler            接口回调
*
*  @return 成功请求Id
*/
@property (nonatomic, assign)  LSScheduleInviteType type;
@property (nonatomic, copy) NSString* _Nullable refId;
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable timeZoneId;
@property (nonatomic, copy) NSString* _Nullable startTime;
@property (nonatomic, assign)  int duration;
@property (nonatomic, strong) SendScheduleInviteFinishHandler _Nullable finishHandler;
@end
