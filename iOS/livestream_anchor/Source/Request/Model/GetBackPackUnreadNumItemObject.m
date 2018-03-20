//
//  GetBackPackUnreadNumItemObject.m
//  dating
//
//  Created by Alex on 17/8/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetBackPackUnreadNumItemObject.h"
@interface GetBackPackUnreadNumItemObject () <NSCoding>
@end


@implementation GetBackPackUnreadNumItemObject

- (id)init {
    if( self = [super init] ) {
        self.total = 0;
        self.voucherUnreadNum = 0;
        self.giftUnreadNum = 0;
        self.rideUnreadNum = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.total = [coder decodeIntForKey:@"total"];
        self.voucherUnreadNum = [coder decodeIntForKey:@"voucherUnreadNum"];
        self.giftUnreadNum = [coder decodeIntForKey:@"giftUnreadNum"];
        self.rideUnreadNum = [coder decodeIntForKey:@"rideUnreadNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.total forKey:@"total"];
    [coder encodeInt:self.voucherUnreadNum forKey:@"voucherUnreadNum"];
    [coder encodeInt:self.giftUnreadNum forKey:@"giftUnreadNum"];
    [coder encodeInt:self.rideUnreadNum forKey:@"rideUnreadNum"];
}

@end
