//
//  LSLCLiveChatEmotionConfigItemObject.m
//  dating
//
//  Created by alex on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatEmotionConfigItemObject.h"

@implementation LSLCLiveChatEmotionConfigItemObject


- (LSLCLiveChatEmotionConfigItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.version = 0;
        self.path = @"";
    }
    return self;
}

@end
