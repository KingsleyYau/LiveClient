//
// LMMessageItemObject.h
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ILiveMessageDef.h"
#import "LMPrivateMsgItemObject.h"
#import "LMTimeMsgItemObject.h"
#import "LMWarningItemObject.h"
#import "LMSystemNoticeItemObject.h"
#import "LMPrivateMsgContactObject.h"
#include "ImClient/IImClientDef.h"
@interface LMMessageItemObject : NSObject
/**
 * 直播message信息
 * sendMsgId     本地消息ID （用于发送时才有的，当发送成功后，返回有msgId）
 * msgId         消息ID
 * sendType      消息发送方向（LMSendType_Unknow：未知类型， LMSendType_Send：发出， LMSendType_Recv：接收）
 * fromId        发送者ID
 * toId          接收者ID
 * createTime    接收/发送时间
 * statusType    直播messageHandle的类型（LMStatusType_Unprocess： 未处理， LMStatusType_Processing： 处理中， LMStatusType_Fail： 发送失败， LMStatusType_Finish：// 发送完成/接收成功）
 * msgType       直播messge的类型（LMMT_Unknow：未知类型，LMMT_Text：私信类型信息  LMMT_SystemWarn：系统警告 LMMT_Time：时间提示 LMMT_Warning：警告提示
 * sendErr       发送错误码
 * userItem      用户item
 * privateItem   私信信息（暂时直播聊天信息只有私信信息）
 * systemItem    系统消息item（现在只有私信头消息）
 * warningItem   警告消息item（暂时只有点数不足）
 * timeMsgItem   时间分组item （1分钟分组）
 */
@property (nonatomic, assign) int sendMsgId;
@property (nonatomic, assign) int msgId;
@property (nonatomic, assign) LMSendType sendType;
@property (nonatomic, copy) NSString* _Nonnull fromId;
@property (nonatomic, copy) NSString* _Nonnull toId;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) LMStatusType statusType;
@property (nonatomic, assign) LMMessageType msgType;
@property (nonatomic, assign) LCC_ERR_TYPE sendErr;
@property (nonatomic, strong) LMPrivateMsgContactObject* _Nullable userItem;
@property (nonatomic, strong) LMPrivateMsgItemObject* _Nullable privateItem;
@property (nonatomic, strong) LMSystemNoticeItemObject* _Nullable systemItem;
@property (nonatomic, strong) LMWarningItemObject* _Nullable warningItem;
@property (nonatomic, strong) LMTimeMsgItemObject* _Nullable timeMsgItem;
@end
