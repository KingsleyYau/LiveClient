//
//  EmotionTypeItemObject.m
//  dating
//
//  Created by alex on 16/9/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "EmotionTypeItemObject.h"

@implementation EmotionTypeItemObject


- (EmotionTypeItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.toflag   = 0;
        self.typeId   = @"";
        self.typeName = @"";
    }
    return self;
}

@end
