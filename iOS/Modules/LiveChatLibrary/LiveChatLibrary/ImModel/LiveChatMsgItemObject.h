//
//  LiveChatMsgItemObject.h
//  dating
//
//  Created by test on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  LiveChat消息item类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILiveChatManManagerEnumDef.h>
#import "LiveChatTextItemObject.h"
#import "LiveChatWarningItemObject.h"
#import "LiveChatSystemItemObject.h"
#import "LiveChatCustomItemObject.h"
#import "LiveChatMsgProcResultObject.h"
#import "LiveChatMsgPhotoItem.h"
#import "LiveChatEmotionItemObject.h"
#import "LiveChatMagicIconItemObject.h"
#import "LiveChatMsgVoiceItem.h"

typedef enum {
    IniviteTypeChat		= 0,		     // livechat
    IniviteTypeCamshare    = 1,		     // camshare
} IniviteType;

@interface LiveChatMsgItemObject : NSObject

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
@property (nonatomic,strong) LiveChatMsgProcResultObject* procResult;
/** 消息类型 */
@property (nonatomic,assign) MessageType msgType;
/** 文本消息 */
@property (nonatomic,strong) LiveChatTextItemObject* textMsg;
/** 警告消息 */
@property (nonatomic,strong) LiveChatWarningItemObject* warningMsg;
/** 系统消息 */
@property (nonatomic,strong) LiveChatSystemItemObject* systemMsg;
/** 自定义消息 **/
@property (nonatomic,strong) LiveChatCustomItemObject* customMsg;
/** 私密照 */
@property (nonatomic,strong) LiveChatMsgPhotoItem* secretPhoto;
/** 语音消息 */
@property (nonatomic,strong) LiveChatMsgVoiceItem* voiceMsg;
/** 私密照下载成功状态 */
@property (nonatomic,assign,getter=isDownloadSuccess) BOOL downloadSuccess;
/** 私密照下载成功状态 */
@property (nonatomic,assign,getter=isLoadingImage) BOOL loadingImage;
// ** 高级表情消息  alex添加 */
@property (nonatomic,strong) LiveChatEmotionItemObject* emotionMsg;
// ** 小高级表情消息 alex添加 */
@property (nonatomic,strong) LiveChatMagicIconItemObject* magicIconMsg;
/** 邀请类型 */
@property (nonatomic, assign) IniviteType inviteType;
/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatMsgItemObject*)init;

@end
