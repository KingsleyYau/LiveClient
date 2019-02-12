//
//  LSLCLiveChatSystemItemObject.m
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat系统消息item类

#import "LSLCLiveChatSystemItemObject.h"

@implementation LSLCLiveChatSystemItemObject
/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatSystemItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.message = @"";
    }
    return self;
}
@end
