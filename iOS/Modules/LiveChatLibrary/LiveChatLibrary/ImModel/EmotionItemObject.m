//
//  EmotionItemObject.m
//  dating
//
//  Created by alex on 16/9/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "EmotionItemObject.h"

@implementation EmotionItemObject


- (EmotionItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.emotionId = @"";
        self.price    = 0.0;
        self.isNew    = NO;
        self.isSale   = NO;
        self.sortId   = 0;
        self.typeId   = @"";
        self.tagId    = @"";
        self.title    = @"";
    }
    return self;
}

@end
