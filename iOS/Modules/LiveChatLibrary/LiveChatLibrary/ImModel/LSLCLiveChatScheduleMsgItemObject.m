//
//  LSLCLiveChatScheduleMsgItemObject.m
//  dating
//
//  Created by Calvin on 20/4/08.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatScheduleMsgItemObject.h"

@implementation LSLCLiveChatScheduleMsgItemObject

- (LSLCLiveChatScheduleMsgItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.scheduleInviteId = @"";
        self.type = SCHEDULEINVITE_PENDING;
        self.timeZone = @"";
        self.timeZoneOffSet = 0;
        self.origintduration = 0;
        self.duration = 0;
        self.startTime = 0;
        self.period = @"";
        self.statusUpdateTime = 0;
        self.sendTime = 0;
    }
    return self;
}
@end
