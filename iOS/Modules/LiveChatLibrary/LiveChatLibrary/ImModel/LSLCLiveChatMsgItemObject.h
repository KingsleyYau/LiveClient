//
//  LSLCLiveChatMsgItemObject.h
//  dating
//
//  Created by test on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  LiveChat消息item类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManagerEnumDef.h>
#import "LSLCLiveChatTextItemObject.h"
#import "LSLCLiveChatWarningItemObject.h"
#import "LSLCLiveChatSystemItemObject.h"
#import "LSLCLiveChatCustomItemObject.h"
#import "LSLCLiveChatMsgProcResultObject.h"
#import "LSLCLiveChatMsgPhotoItem.h"
#import "LSLCLiveChatEmotionItemObject.h"
#import "LSLCLiveChatMagicIconItemObject.h"
#import "LSLCLiveChatMsgVoiceItem.h"
#import "LSLCLiveChatMsgVideoItem.h"
#import "LSLCLiveChatScheduleMsgItemObject.h"
#import "LSLCLiveChatScheduleReplyItemObject.h"

typedef enum {
    IniviteTypeChat		= 0,		     // livechat
    IniviteTypeCamshare    = 1,		     // camshare
} IniviteType;

@interface LSLCLiveChatMsgItemObject : NSObject

/** 消息ID */
@property (nonatomic,assign) NSInteger msgId;
/** 消息发送方向 */
@property (nonatomic,assign) SendType sendType;
/** 消息发送方向 */
@property (nonatomic,strong) NSString *fromId;
/** 接收 */
@property (nonatomic,strong) NSString *toId;
/** 邀请ID */
@property (nonatomic,strong) NSString *inviteId;
/** 接收/发送时间 */
@property (nonatomic,assign) NSInteger createTime;
/** 处理状态 */
@property (nonatomic,assign) StatusType statusType;
/** 处理结果 */
@property (nonatomic,strong) LSLCLiveChatMsgProcResultObject* procResult;
/** 消息类型 */
@property (nonatomic,assign) MessageType msgType;
/** 文本消息 */
@property (nonatomic,strong) LSLCLiveChatTextItemObject* textMsg;
/** 警告消息 */
@property (nonatomic,strong) LSLCLiveChatWarningItemObject* warningMsg;
/** 系统消息 */
@property (nonatomic,strong) LSLCLiveChatSystemItemObject* systemMsg;
/** 自定义消息 **/
@property (nonatomic,strong) LSLCLiveChatCustomItemObject* customMsg;
/** 私密照 */
@property (nonatomic,strong) LSLCLiveChatMsgPhotoItem* secretPhoto;
/** 语音消息 */
@property (nonatomic,strong) LSLCLiveChatMsgVoiceItem* voiceMsg;
/** 视频消息 */
@property (nonatomic,strong) LSLCLiveChatMsgVideoItem* videoMsg;
/** 私密照下载成功状态 */
@property (nonatomic,assign,getter=isDownloadSuccess) BOOL downloadSuccess;
/** 私密照下载成功状态 */
@property (nonatomic,assign,getter=isLoadingImage) BOOL loadingImage;
// ** 高级表情消息  alex添加 */
@property (nonatomic,strong) LSLCLiveChatEmotionItemObject* emotionMsg;
// ** 小高级表情消息 alex添加 */
@property (nonatomic,strong) LSLCLiveChatMagicIconItemObject* magicIconMsg;
// ** 预付费邀请消息 alex添加 */
@property (nonatomic,strong) LSLCLiveChatScheduleMsgItemObject* scheduleMsg;
// ** 预付费回复消息 alex添加 */
@property (nonatomic,strong) LSLCLiveChatScheduleReplyItemObject* scheduleReplyMsg;
/** 邀请类型 */
@property (nonatomic, assign) IniviteType inviteType;
/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatMsgItemObject*)init;

@end
