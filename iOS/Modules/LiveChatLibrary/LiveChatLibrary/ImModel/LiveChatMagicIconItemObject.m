//
//  LiveChatMagicIconItemObject.m
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LiveChatMagicIconItemObject.h"

@implementation LiveChatMagicIconItemObject


- (LiveChatMagicIconItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.magicIconId = @"";
        self.thumbPath = @"";
        self.sourcePath = @"";

    }
    return self;
}

@end
