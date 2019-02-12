//
//  LSLCLiveChatWarningItemObject.m
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat警告消息item类

#import "LSLCLiveChatWarningItemObject.h"


@implementation LSLCLiveChatWarningLinkItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatWarningLinkItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.linkMsg = @"";
        self.linkOptType = Unknow;
    }
    return self;
}

@end


@implementation LSLCLiveChatWarningItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatWarningItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.message = @"";
        self.link = nil;
    }
    return self;
}

@end
