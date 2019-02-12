//
//  MagicIconItemObject.m
//  dating
//
//  Created by alex on 16/9/12.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MagicIconItemObject.h"

@implementation MagicIconItemObject


- (MagicIconItemObject *)init
{
    self = [super init];
    if (nil != self)
    {
        self.iconId      = @"";
        self.iconTitle   = @"";
        self.price       = 0.0;
        self.hotflog     = 0;
        self.typeId      = @"";
        self.updatetime  = 0;
    }
    return self;
}

@end
