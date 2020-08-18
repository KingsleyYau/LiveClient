//
//  LSMainUnreadNumItemObject
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LSMainUnreadNumItemObject : NSObject
/**
 * 获取主界面未读数量
 * showTicketUnreadNum          节目未读数量
 * loiUnreadNum                 意向信未读数量
 * emfUnreadNum                 EMF未读数量
 * privateMessageUnreadNum      私信未读数量
 * bookingUnreadNum             预约未读数量
 * backpackUnreadNum            背包未读数量
 * sayHiResponseUnreadNum       sayHi回复未读数量
 * livechatVocherUnreadNum      livechat试聊劵未读数量
 * schedulePendingUnreadNum     预付费直播-男士待确定未读数
 * scheduleConfirmedUnreadNum   预付费直播-男主播接受未读数
 * scheduleStatus           预付费直播状态（LSSCHEDULESTATUS_NOSCHEDULE：无预约 LSSCHEDULESTATUS_SHOWED：可开播 LSSCHEDULESTATUS_SHOWING：在30分钟内即将开播
 * requestReplyUnreadNum   解锁码请求回复未读数
 */
@property (nonatomic, assign) int showTicketUnreadNum;
@property (nonatomic, assign) int loiUnreadNum;
@property (nonatomic, assign) int emfUnreadNum;
@property (nonatomic, assign) int privateMessageUnreadNum;
@property (nonatomic, assign) int bookingUnreadNum;
@property (nonatomic, assign) int backpackUnreadNum;
@property (nonatomic, assign) int sayHiResponseUnreadNum;
@property (nonatomic, assign) int livechatVocherUnreadNum;
@property (nonatomic, assign) int schedulePendingUnreadNum;
@property (nonatomic, assign) int scheduleConfirmedUnreadNum;
@property (nonatomic, assign) LSScheduleStatus scheduleStatus;
@property (nonatomic, assign) int requestReplyUnreadNum;

@end
