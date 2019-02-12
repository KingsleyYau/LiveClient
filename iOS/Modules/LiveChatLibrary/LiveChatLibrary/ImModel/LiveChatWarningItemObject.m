//
//  LiveChatWarningItemObject.m
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat警告消息item类

#import "LiveChatWarningItemObject.h"


@implementation LiveChatWarningLinkItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatWarningLinkItemObject*)init
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


@implementation LiveChatWarningItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatWarningItemObject*)init
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
