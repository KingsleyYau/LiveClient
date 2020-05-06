//
//  LSLCLiveChatScheduleReplyItemObject.h
//  dating
//
//  Created by Alex on 20/4/15.
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManagerEnumDef.h>

@interface LSLCLiveChatScheduleReplyItemObject : NSObject

/** 预约邀请id（不是livechat的会话邀请id）如：S38244144，http接口17.3.发送f预付费直播邀请返回值的的invite_id */
@property (nonatomic,copy) NSString *scheduleId;
/** 是否接受 */
@property (nonatomic,assign) BOOL isScheduleAccept;
/** 是否是男士回复 */
@property (nonatomic,assign) BOOL isScheduleFromMe;

- (LSLCLiveChatScheduleReplyItemObject *)init;


@end
