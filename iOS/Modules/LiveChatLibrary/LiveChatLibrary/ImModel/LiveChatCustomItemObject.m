//
//  LiveChatCustomItemObject.m
//  dating
//
//  Created by  Samson on 5/28/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat自定义消息item类

#import "LiveChatCustomItemObject.h"

@implementation LiveChatCustomItemObject
/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatCustomItemObject*)init
{
    self = [super init];
    if (nil != self)
    {
        self.param = 0;
    }
    return self;
}
@end
