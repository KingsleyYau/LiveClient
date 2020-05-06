//
//  LSGetScheduleInviteListRequest.h
//  dating
//  17.7.获取预付费直播邀请列表
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetScheduleInviteListRequest : LSSessionRequest

/**
*  17.7.获取预付费直播邀请列表接口
*
*  @param status           邀请状态(    LSSCHEDULEINVITESTATUS_PENDING: Pending
LSSCHEDULEINVITESTATUS_CONFIRMED :  Confirmed
LSSCHEDULEINVITESTATUS_CANCELED :  Canceled
LSSCHEDULEINVITESTATUS_EXPIRED: Expired
LSSCHEDULEINVITESTATUS_COMPLETED:  Completed
LSSCHEDULEINVITESTATUS_DECLINED:  Declined
LSSCHEDULEINVITESTATUS_MISSED : Missed)
*  @param sendFlag     发起方(LSSCHEDULESENDFLAGTYPE_ALL:全部(默认) LSSCHEDULESENDFLAGTYPE_MAN:男士 LSSCHEDULESENDFLAGTYPE_ANCHOR:主播)
*  @param anchorId         主播ID
*  @param start            起始数
*  @param step             步长
*  @param finishHandler            接口回调
*
*  @return 成功请求Id
*/
@property (nonatomic, assign)  LSScheduleInviteStatus status;
@property (nonatomic, assign) LSScheduleSendFlagType sendFlag;
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetScheduleInviteListFinishHandler _Nullable finishHandler;
@end
