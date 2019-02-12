//
//  EMFAdmirerItemObject.m
//  dating
//
//  Created by test on 17/5/9.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftItemObject.h"

@implementation GiftItemObject

- (GiftItemObject *)init
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
