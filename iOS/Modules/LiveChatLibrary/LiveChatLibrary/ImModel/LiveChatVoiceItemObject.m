//
//  LiveChatVoiceItemObject.m
//  dating
//
//  Created by alex on 17/5/2.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LiveChatVoiceItemObject.h"

@implementation LiveChatVoiceItemObject


- (LiveChatVoiceItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.voiceId = @"";
        self.filePath = @"";
        self.timeLength = 0;
        self.fileType = @"";
        self.checkCode = @"";
        self.charge = NO;
        self.processing = NO;
    }
    return self;
}

@end
