//
//  GiftNumItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GiftNumItemObject.h"
@interface GiftNumItemObject () <NSCoding>
@end


@implementation GiftNumItemObject

- (id)init {
    if( self = [super init] ) {
        self.num = 0;
        self.isDefault = NO;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.num = [coder decodeIntForKey:@"num"];
        self.isDefault = [coder decodeBoolForKey:@"isDefault"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.num forKey:@"num"];
    [coder encodeBool:self.isDefault forKey:@"isDefault"];
}

@end
