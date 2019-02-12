//
//  LiveChatMsgEmotionItem.m
//  dating
//
//  Created by alex on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LiveChatEmotionItemObject.h"

@implementation LiveChatEmotionItemObject


- (LiveChatEmotionItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.emotionId = @"";
        self.imagePath = @"";
        self.playBigPath = @"";
        self.playBigImages = NULL;
    }
    return self;
}

@end
