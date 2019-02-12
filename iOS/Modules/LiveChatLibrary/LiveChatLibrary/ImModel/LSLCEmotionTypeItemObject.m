//
//  LSLCEmotionTypeItemObject.m
//  dating
//
//  Created by alex on 16/9/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLCEmotionTypeItemObject.h"

@implementation LSLCEmotionTypeItemObject


- (LSLCEmotionTypeItemObject *)init
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
