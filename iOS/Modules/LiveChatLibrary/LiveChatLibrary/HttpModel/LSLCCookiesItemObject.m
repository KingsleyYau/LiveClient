//
//  LSLCCookiesItemObject.m
//  dating
//
//  Created by alex on 16/9/29.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLCCookiesItemObject.h"

@implementation LSLCCookiesItemObject


- (LSLCCookiesItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
       self.domain = @"";
        self.accessOtherWeb = @"";
        self.symbol = @"";
        self.isSend = @"";
        self.expiresTime = @"";
        self.cName = @"";
        self.value = @"";
    }
    return self;
}

@end
