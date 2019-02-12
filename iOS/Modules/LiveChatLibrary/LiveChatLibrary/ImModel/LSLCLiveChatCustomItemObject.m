//
//  LSLCLiveChatCustomItemObject.m
//  dating
//
//  Created by  Samson on 5/28/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat自定义消息item类

#import "LSLCLiveChatCustomItemObject.h"

@implementation LSLCLiveChatCustomItemObject
/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatCustomItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.param = 0;
    }
    return self;
}
@end
