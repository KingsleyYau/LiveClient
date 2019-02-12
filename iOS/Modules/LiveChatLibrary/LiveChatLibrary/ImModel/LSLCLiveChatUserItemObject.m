//
//  LSLCLiveChatUserItemObject.m
//  dating
//
//  Created by lance on 16/4/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  LiveChat用户item类

#import "LSLCLiveChatUserItemObject.h"

@implementation LSLCLiveChatUserItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatUserItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.userId = @"";
        self.userName = @"";
        self.sexType = USER_SEX_UNKNOW;
        self.clientType = CLIENT_UNKNOW;
        self.statusType = USTATUS_UNKNOW;
        self.chatType = LC_CHATTYPE_OTHER;
        self.inviteId = @"";
        self.tryingSend = NO;
        self.order = -1;
        self.isOpenCam = NO;
    }
    return self;
}

@end
