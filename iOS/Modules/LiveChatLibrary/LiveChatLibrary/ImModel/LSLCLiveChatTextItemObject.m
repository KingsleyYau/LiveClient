//
//  LSLCLiveChatTextItemObject.m
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat文本消息item类

#import "LSLCLiveChatTextItemObject.h"

@implementation LSLCLiveChatTextItemObject

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatTextItemObject*)init
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
