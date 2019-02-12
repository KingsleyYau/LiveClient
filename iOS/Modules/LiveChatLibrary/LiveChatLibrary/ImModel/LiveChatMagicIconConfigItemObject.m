//
//  LiveChatMagicIconConfigItemObject.m
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LiveChatMagicIconConfigItemObject.h"

@implementation LiveChatMagicIconConfigItemObject


- (LiveChatMagicIconConfigItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.path          = @"";
        self.maxupdatetime = 0;
    }
    return self;
}

@end
