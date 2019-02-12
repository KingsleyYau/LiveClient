//
//  LSLCGiftItemObject.m
//  dating
//
//  Created by test on 17/5/9.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSLCGiftItemObject.h"

@implementation LSLCGiftItemObject

- (LSLCGiftItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.vgid = @"";
        self.title = @"";
        self.price = @"";
    }
    return self;
}


@end
