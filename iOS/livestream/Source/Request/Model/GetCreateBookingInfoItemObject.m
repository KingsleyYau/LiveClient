//
//  GetCreateBookingInfoItemObject.m
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "GetCreateBookingInfoItemObject.h"
@interface GetCreateBookingInfoItemObject () <NSCoding>
@end


@implementation GetCreateBookingInfoItemObject

- (id)init {
    if( self = [super init] ) {
        self.bookDeposit = 0.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.bookDeposit = [coder decodeDoubleForKey:@"bookDeposit"];
        self.bookTime = [coder decodeObjectForKey:@"bookTime"];
        self.bookGift = [coder decodeObjectForKey:@"bookGift"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.bookDeposit forKey:@"bookDeposit"];
    [coder encodeObject:self.bookTime forKey:@"bookTime"];
    [coder encodeObject:self.bookGift forKey:@"bookGift"];
}

@end
