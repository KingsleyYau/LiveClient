//
//  LSLCLiveChatMsgVoiceItem.m
//  dating
//
//  Created by Calvin on 17/4/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatMsgVoiceItem.h"

@implementation LSLCLiveChatMsgVoiceItem

- (LSLCLiveChatMsgVoiceItem *)init
{
    self = [super init];
    if (nil != self)
    {
        self.voiceId = @"";
        self.filePath = @"";
        self.fileType = @"";
        self.checkCode = @"";
        self.timeLength = 0;
        self.charge = NO;
        self.processing = NO;
        self.isRead = NO;
        self.isPalying = NO;
    }
    return self;
}
@end
