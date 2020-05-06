//
//  LSLCLiveChatScheduleReplyItemObject.m
//  dating
//
//  Created by Calvin on 20/4/15.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatScheduleReplyItemObject.h"

@implementation LSLCLiveChatScheduleReplyItemObject

- (LSLCLiveChatScheduleReplyItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.scheduleId = @"";
        self.isScheduleAccept = false;
        self.isScheduleFromMe = false;
    }
    return self;
}
@end
