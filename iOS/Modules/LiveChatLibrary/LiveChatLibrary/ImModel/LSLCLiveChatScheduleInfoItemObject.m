//
//  LSLCLiveChatScheduleInfoItemObject.m
//  dating
//
//  Created by Calvin on 20/4/08.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatScheduleInfoItemObject.h"

@implementation LSLCLiveChatScheduleInfoItemObject

- (LSLCLiveChatScheduleInfoItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.manId = @"";
        self.womanId = @"";
        self.msg = NULL;
    }
    return self;
}
@end
