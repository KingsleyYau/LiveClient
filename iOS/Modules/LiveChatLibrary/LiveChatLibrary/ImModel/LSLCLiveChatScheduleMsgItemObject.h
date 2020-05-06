//
//  LSLCLiveChatScheduleMsgItemObject.h
//  dating
//
//  Created by Alex on 20/4/08.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManagerEnumDef.h>

@interface LSLCLiveChatScheduleMsgItemObject : NSObject

/** 预约邀请id（不是livechat的会话邀请id）如：S38244144，http接口17.3.发送f预付费直播邀请返回值的的invite_id */
@property (nonatomic,copy) NSString *scheduleInviteId;
/** 操作方式（SCHEDULEINVITE_PENDING:发送   SCHEDULEINVITE_CONFIRMED:接受    SCHEDULEINVITE_DECLINED:拒绝） */
@property (nonatomic,assign) SCHEDULEINVITE_TYPE type;
/** 时区字符串 (HK (GMT +08:00))*/
@property (nonatomic,copy) NSString *timeZone;
/**  时区值 暂无 */
@property (nonatomic,assign) int timeZoneOffSet;
/** 会话时长  发送时的时长（注意如果对方接受时会改的就是duration）如： 30*/
@property (nonatomic,assign) int origintduration;
/** 修改后的时长 接受，拒绝 修改的会话时长 （发送可以写成0）如 45*/
@property (nonatomic,assign) int duration;
/** 预约开始时间 （本地时间戳 ）*/
@property (nonatomic,assign) NSInteger startTime;
/** 时间周期 (Mar 21, 14:00 - 15:00)*/
@property (nonatomic,copy) NSString *period;
/** 会话邀请ID */
//@property (nonatomic,copy) NSString *inviteId;
/** 操作时间 （本地时间戳 ， 接受，拒绝时的时间）*/
@property (nonatomic,assign) NSInteger statusUpdateTime;
/** 发送时间 （本地时间戳 ， 发送）*/
@property (nonatomic,assign) NSInteger sendTime;

- (LSLCLiveChatScheduleMsgItemObject *)init;


@end
