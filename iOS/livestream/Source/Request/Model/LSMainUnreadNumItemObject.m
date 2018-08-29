//
//  LSMainUnreadNumItemObject.m
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSMainUnreadNumItemObject.h"
@interface LSMainUnreadNumItemObject () <NSCoding>
@end


@implementation LSMainUnreadNumItemObject

- (id)init {
    if( self = [super init] ) {
        self.showTicketUnreadNum = 0;
        self.loiUnreadNum = 0;
        self.emfUnreadNum = 0;
        self.privateMessageUnreadNum = 0;
        self.bookingUnreadNum = 0;
        self.backpackUnreadNum = 0;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.showTicketUnreadNum = [coder decodeIntForKey:@"showTicketUnreadNum"];
        self.loiUnreadNum = [coder decodeIntForKey:@"loiUnreadNum"];
        self.emfUnreadNum = [coder decodeIntForKey:@"emfUnreadNum"];
        self.privateMessageUnreadNum = [coder decodeIntForKey:@"privateMessageUnreadNum"];
        self.bookingUnreadNum = [coder decodeIntForKey:@"bookingUnreadNum"];
        self.backpackUnreadNum = [coder decodeIntForKey:@"backpackUnreadNum"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.showTicketUnreadNum forKey:@"showTicketUnreadNum"];
    [coder encodeInt:self.loiUnreadNum forKey:@"loiUnreadNum"];
    [coder encodeInt:self.emfUnreadNum forKey:@"emfUnreadNum"];
    [coder encodeInt:self.privateMessageUnreadNum forKey:@"privateMessageUnreadNum"];
    [coder encodeInt:self.bookingUnreadNum forKey:@"bookingUnreadNum"];
    [coder encodeInt:self.backpackUnreadNum forKey:@"backpackUnreadNum"];
}

@end
