//
//  VoucherInfoObject.m
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "VoucherInfoObject.h"
@interface  VoucherInfoObject () <NSCoding>
@end


@implementation  VoucherInfoObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.voucherId = [coder decodeObjectForKey:@"voucherId"];
        self.photoUrl = [coder decodeObjectForKey:@"photoUrl"];
        self.desc = [coder decodeObjectForKey:@"desc"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.voucherId forKey:@"voucherId"];
    [coder encodeObject:self.photoUrl forKey:@"photoUrl"];
    [coder encodeObject:self.desc forKey:@"desc"];
}

@end
