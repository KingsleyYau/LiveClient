//
//  LSLCMagicIconTypeItemObject.m
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLCMagicIconTypeItemObject.h"

@implementation LSLCMagicIconTypeItemObject


- (LSLCMagicIconTypeItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.typeId   = @"";
        self.typeTitle = @"";
    }
    return self;
}

@end
