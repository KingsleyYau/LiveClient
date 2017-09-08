//
//  BackpackInfoObject.m
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BackpackInfoObject.h"
@interface BackpackInfoObject () <NSCoding>
@end


@implementation BackpackInfoObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.gift = [coder decodeObjectForKey:@"gift"];
        self.voucher = [coder decodeObjectForKey:@"voucher"];
        self.ride = [coder decodeObjectForKey:@"ride"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.gift forKey:@"gift"];
    [coder encodeObject:self.voucher forKey:@"voucher"];
    [coder encodeObject:self.ride forKey:@"ride"];
}

@end
