//
//  BookingPrivateInviteListObject.m
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "BookingPrivateInviteListObject.h"
@interface BookingPrivateInviteListObject () <NSCoding>
@end


@implementation BookingPrivateInviteListObject

- (id)init {
    if( self = [super init] ) {
        self.total = 0;
        self.noReadCount = 0;
        self.list = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.total = [coder decodeIntForKey:@"total"];
        self.noReadCount = [coder decodeIntForKey:@"noReadCount"];
        self.list = [coder decodeObjectForKey:@"list"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.total forKey:@"total"];
    [coder encodeInt:self.noReadCount forKey:@"noReadCount"];
    [coder encodeObject:self.list forKey:@"list"];
}

@end
