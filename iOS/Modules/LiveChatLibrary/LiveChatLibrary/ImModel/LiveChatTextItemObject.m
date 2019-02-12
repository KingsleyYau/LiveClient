//
//  LiveChatTextItemObject.m
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat文本消息item类

#import "LiveChatTextItemObject.h"

@implementation LiveChatTextItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatTextItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.message = @"";
        self.illegal = NO;
    }
    return self;
}

@end
