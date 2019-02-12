//
//  MagicIconTypeItemObject.m
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MagicIconTypeItemObject.h"

@implementation MagicIconTypeItemObject


- (MagicIconTypeItemObject *)init
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
