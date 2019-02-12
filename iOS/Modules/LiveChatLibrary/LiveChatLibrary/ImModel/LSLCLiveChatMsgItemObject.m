//
//  LSLCLiveChatMsgItemObject.m
//  dating
//
//  Created by test on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  LiveChat消息item类

#import "LSLCLiveChatMsgItemObject.h"

@implementation LSLCLiveChatMsgItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatMsgItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.msgId = -1;
        self.sendType = SendType_Unknow;
        self.fromId = @"";
        self.toId = @"";
        self.inviteId = @"";
        self.createTime = 0;
        self.statusType = StatusType_Unprocess;
        self.msgType = MT_Unknow;
        self.procResult = [[LSLCLiveChatMsgProcResultObject alloc] init];
        self.textMsg = nil;
        self.warningMsg = nil;
        self.systemMsg = nil;
        self.customMsg = nil;
        self.voiceMsg = nil;
        self.downloadSuccess = NO;
        self.loadingImage = NO;
        self.emotionMsg = nil;
        self.magicIconMsg = nil;
        self.inviteType = IniviteTypeChat;
    }
    return self;
}

@end
